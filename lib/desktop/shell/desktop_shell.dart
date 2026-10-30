import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../desktop_app.dart';
import '../screens/attendance_page.dart';
import '../screens/dashboard_page.dart';
import '../screens/devices_page.dart';
import '../screens/items_page.dart';
import '../screens/payroll_page.dart';
import '../screens/pos_page.dart';
import '../screens/purchases_page.dart';
import '../screens/receive_page.dart';
import '../screens/recipes_page.dart';
import '../screens/settings_page.dart';
import '../screens/stocktake_page.dart';
import '../sync/desktop_sync.dart';

/// The desktop suite's screens. What a computer shows is what its ROLE allows (set by the owner on «الأجهزة») AND what
/// the person signed in may do — the server checks the second again on every call.
enum SuiteScreen { dashboard, items, recipes, purchases, receive, stocktake, pos, attendance, payroll, devices, settings }

const _roleScreens = {
  'main': SuiteScreen.values,
  'manager': [SuiteScreen.dashboard, SuiteScreen.items, SuiteScreen.recipes, SuiteScreen.purchases, SuiteScreen.receive, SuiteScreen.stocktake, SuiteScreen.pos, SuiteScreen.attendance, SuiteScreen.payroll, SuiteScreen.settings],
  'warehouse': [SuiteScreen.dashboard, SuiteScreen.items, SuiteScreen.receive, SuiteScreen.stocktake, SuiteScreen.settings],
  'purchases': [SuiteScreen.dashboard, SuiteScreen.items, SuiteScreen.purchases, SuiteScreen.receive, SuiteScreen.settings],
  'cashier': [SuiteScreen.pos, SuiteScreen.settings],
};

Set<SuiteScreen> _byPerson(InvSettings s) {
  final out = <SuiteScreen>{SuiteScreen.settings};
  if (s.isOwner) return {...SuiteScreen.values};
  if (s.can('inventory')) out.addAll([SuiteScreen.dashboard, SuiteScreen.items, SuiteScreen.recipes, SuiteScreen.stocktake]);
  if (s.can('purchases') || s.can('purchase_approval')) out.addAll([SuiteScreen.dashboard, SuiteScreen.purchases]);
  if (s.can('purchases')) out.addAll([SuiteScreen.receive, SuiteScreen.items]);
  if (s.can('pos')) out.add(SuiteScreen.pos);
  if (s.can('attendance')) out.add(SuiteScreen.attendance);
  if (s.can('payroll')) out.addAll([SuiteScreen.attendance, SuiteScreen.payroll]);
  return out;
}

Set<SuiteScreen> _byFeature(InvSettings s) => {
      for (final screen in SuiteScreen.values)
        if (switch (screen) {
          SuiteScreen.recipes => s.has('sales_link'),
          SuiteScreen.purchases || SuiteScreen.receive => s.has('purchases'),
          SuiteScreen.pos => s.has('pos'),
          _ => true,
        })
          screen,
    };

/// The role this computer was given (null = not registered: it works by its user's permissions alone).
final thisDeviceProvider = FutureProvider.autoDispose<InvDevice?>((ref) async {
  final store = ref.watch(suiteStoreProvider);
  try {
    final devices = await ref.watch(inventoryApiProvider).devices();
    return devices.where((d) => d.uuid == store.deviceUuid).firstOrNull;
  } catch (_) {
    return null;
  }
});

final currentScreenProvider = StateProvider<SuiteScreen?>((ref) => null);

class DesktopShell extends ConsumerStatefulWidget {
  const DesktopShell({super.key});

  @override
  ConsumerState<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends ConsumerState<DesktopShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sync = ref.read(suiteSyncProvider.notifier);
      final business = ref.read(suiteBusinessProvider);
      if (sync.wantsHub && business != null) {
        await sync.startHub(businessId: business.id, businessName: business.name);
      }
      sync.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(invSettingsProvider);

    return AsyncValueView<InvSettings>(
      value: settings,
      onRetry: () => ref.invalidate(invSettingsProvider),
      builder: (context, s) {
        final device = ref.watch(thisDeviceProvider).valueOrNull;
        final role = device?.screens != null
            ? device!.screens!.map((k) => SuiteScreen.values.where((v) => v.name == k).firstOrNull).whereType<SuiteScreen>().toSet()
            : (device == null ? SuiteScreen.values.toSet() : _roleScreens[device.role]!.toSet());
        // attendance and payroll serve every business; the inventory screens only once inventory is switched on
        final inventoryOn = s.available && s.enabled;
        const hrScreens = {SuiteScreen.attendance, SuiteScreen.payroll, SuiteScreen.settings};
        final allowed = SuiteScreen.values
            .where((v) => role.contains(v) && _byPerson(s).contains(v) && (hrScreens.contains(v) || (inventoryOn && _byFeature(s).contains(v))))
            .toList();
        final chosen = ref.watch(currentScreenProvider);
        final current = (chosen != null && allowed.contains(chosen)) ? chosen : allowed.first;

        return Scaffold(
          body: Row(
            children: [
              _Sidebar(allowed: allowed, current: current),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(settings: s),
                    Expanded(child: _page(current)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _page(SuiteScreen screen) => switch (screen) {
        SuiteScreen.dashboard => const DashboardPage(),
        SuiteScreen.items => const ItemsPage(),
        SuiteScreen.recipes => const RecipesPage(),
        SuiteScreen.purchases => const PurchasesPage(),
        SuiteScreen.receive => const ReceivePage(),
        SuiteScreen.stocktake => const StocktakePage(),
        SuiteScreen.pos => const PosPage(),
        SuiteScreen.attendance => const AttendancePage(),
        SuiteScreen.payroll => const PayrollPage(),
        SuiteScreen.devices => const DevicesPage(),
        SuiteScreen.settings => const SettingsPage(),
      };
}

String suiteScreenLabel(AppLocalizations l10n, SuiteScreen s) => switch (s) {
      SuiteScreen.dashboard => l10n.suiteNavDashboard,
      SuiteScreen.items => l10n.suiteNavItems,
      SuiteScreen.recipes => l10n.suiteNavRecipes,
      SuiteScreen.purchases => l10n.suiteNavPurchases,
      SuiteScreen.receive => l10n.suiteNavReceive,
      SuiteScreen.stocktake => l10n.suiteNavStocktake,
      SuiteScreen.pos => l10n.suiteNavPos,
      SuiteScreen.attendance => l10n.hrAttendanceTitle,
      SuiteScreen.payroll => l10n.hrNavPayroll,
      SuiteScreen.devices => l10n.suiteNavDevices,
      SuiteScreen.settings => l10n.suiteNavSettings,
    };

IconData _icon(SuiteScreen s) => switch (s) {
      SuiteScreen.dashboard => Icons.space_dashboard_outlined,
      SuiteScreen.items => Icons.inventory_2_outlined,
      SuiteScreen.recipes => Icons.restaurant_menu_outlined,
      SuiteScreen.purchases => Icons.shopping_cart_outlined,
      SuiteScreen.receive => Icons.move_to_inbox_outlined,
      SuiteScreen.stocktake => Icons.fact_check_outlined,
      SuiteScreen.pos => Icons.point_of_sale_outlined,
      SuiteScreen.attendance => Icons.badge_outlined,
      SuiteScreen.payroll => Icons.payments_outlined,
      SuiteScreen.devices => Icons.lan_outlined,
      SuiteScreen.settings => Icons.settings_outlined,
    };

class _Sidebar extends ConsumerWidget {
  final List<SuiteScreen> allowed;
  final SuiteScreen current;
  const _Sidebar({required this.allowed, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final business = ref.watch(suiteBusinessProvider);

    return Container(
      width: 230,
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.suiteBrand, style: const TextStyle(color: AppColors.accentGold, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(business?.name ?? '', style: const TextStyle(color: Color(0xFFC9D1DE), fontSize: 13)),
          const SizedBox(height: 20),
          for (final s in allowed)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: s == current ? AppColors.accentGold : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  leading: Icon(_icon(s), color: s == current ? AppColors.primaryNavy : const Color(0xFFE3E8F0), size: 20),
                  title: Text(suiteScreenLabel(l10n, s),
                      style: TextStyle(color: s == current ? AppColors.primaryNavy : const Color(0xFFE3E8F0), fontWeight: FontWeight.w700)),
                  onTap: () => ref.read(currentScreenProvider.notifier).state = s,
                ),
              ),
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              ref.read(suiteBusinessProvider.notifier).state = null;
              ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout, color: Color(0xFFC9D1DE)),
            label: Text(l10n.authLogout, style: const TextStyle(color: Color(0xFFC9D1DE))),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final InvSettings settings;
  const _TopBar({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sync = ref.watch(suiteSyncProvider);
    final (label, bg, fg) = switch (sync.link) {
      SuiteLink.online => (l10n.suiteLinkOnline, const Color(0xFFE7F3EC), const Color(0xFF1F7A44)),
      SuiteLink.office => (l10n.suiteLinkOffice, const Color(0xFFFBF0D9), const Color(0xFF7A5200)),
      SuiteLink.offline => (l10n.suiteLinkOffline, const Color(0xFFF9E4DF), const Color(0xFFB93A22)),
      SuiteLink.checking => (l10n.suiteLinkChecking, const Color(0xFFF1EEE6), const Color(0xFF5B6474)),
    };

    return Column(
      children: [
        // only a business that switched inventory on has a subscription to warn about
        if (settings.enabled && !settings.subscription.writable)
          MaterialBanner(
            backgroundColor: const Color(0xFFF9E4DF),
            content: Text(l10n.suiteReadOnlyBanner, style: const TextStyle(color: Color(0xFFB93A22))),
            actions: [TextButton(onPressed: () => ref.read(currentScreenProvider.notifier).state = SuiteScreen.settings, child: Text(l10n.suiteRenew))],
          )
        else if (settings.subscription.status == 'grace')
          MaterialBanner(
            backgroundColor: const Color(0xFFFBF0D9),
            content: Text(l10n.suiteGraceBanner, style: const TextStyle(color: Color(0xFF7A5200))),
            actions: [TextButton(onPressed: () => ref.read(currentScreenProvider.notifier).state = SuiteScreen.settings, child: Text(l10n.suiteRenew))],
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
          child: Row(
            children: [
              const Spacer(),
              if (sync.pending > 0)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Chip(label: Text(l10n.suitePending(sync.pending))),
                ),
              if (sync.rejected > 0)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ActionChip(
                    label: Text(l10n.suiteRejected(sync.rejected)),
                    onPressed: () => ref.read(currentScreenProvider.notifier).state = SuiteScreen.settings,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              IconButton(
                tooltip: l10n.suiteSyncNow,
                icon: const Icon(Icons.sync),
                onPressed: () async {
                  await ref.read(suiteSyncProvider.notifier).tick();
                  ref.invalidate(invSettingsProvider);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
