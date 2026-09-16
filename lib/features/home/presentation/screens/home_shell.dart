import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../booking/application/booking_providers.dart';
import '../../../booking/presentation/screens/pending_settlement_gate.dart';
import '../../../categories/presentation/screens/all_categories_screen.dart';
import '../../../notifications/application/notifications_providers.dart';
import 'business_home_screen.dart';
import 'customer_home_screen.dart';
import 'my_services_screen.dart';

/// The persistent bottom-nav shell for every signed-in account — Home /
/// Categories / My Services, icon-only (no labels, so the Home tab's own
/// icon can be the account's own avatar instead of a generic house — the
/// bar tells you which account is signed in at a glance). Only the Home
/// tab's content differs by account type (the business dashboard vs the
/// category feed); Categories (browsing + cross-category search, now
/// inline instead of its own tab) and My Services (a person's own activity
/// — bookings, orders, wallet, ...) are the same for both, since neither is
/// a business-vs-customer concern. Account editing and settings stay in
/// AppDrawer (its own header IS the door to the account) — not a fourth tab
/// — since jumping to your own account isn't a "destination" the way these
/// three are.
///
/// Categories opens by default (index 1, not 0): browsing what's on the
/// platform is the first thing a person does right after signing in, more
/// than checking a feed that's empty until they follow someone.
///
/// An [IndexedStack] keeps all three tabs mounted so switching tabs never
/// re-fetches — the tradeoff is that all three start loading as soon as the
/// shell mounts, which is fine at this scale (a handful of lightweight
/// requests, not a heavy screen).
///
/// Same shell at every width, including desktop: the account drawer stays
/// behind each tab's own hamburger icon rather than a persistent sidebar —
/// a persistent sidebar was tried and the owner asked to drop it back to a
/// menu button.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with WidgetsBindingObserver {
  int _index = 1;
  /// One key per tab, so switching tabs can close whichever tab we're
  /// LEAVING own drawer first — each tab's `Scaffold` stays mounted inside
  /// the `IndexedStack` below (that's the whole point: switching tabs never
  /// re-fetches), so a drawer left open on tab A is still open, unclosed,
  /// the next time tab A comes back on screen unless something closes it
  /// first.
  final _scaffoldKeys = List.generate(3, (_) => GlobalKey<ScaffoldState>());

  /// Real push isn't live yet (no Firebase project configured), and neither
  /// `unreadNotificationCountProvider` nor `notificationsControllerProvider`
  /// is `autoDispose` — once fetched they never refresh on their own, so a
  /// notification created while the app sits open (e.g. a staff invitation)
  /// only ever appeared after a full app-process restart. A light poll here,
  /// only while the app is actually in the foreground, closes that gap
  /// without inventing a bigger realtime mechanism.
  Timer? _notificationPollTimer;
  static const _notificationPollInterval = Duration(seconds: 30);

  void _selectTab(int value) {
    _scaffoldKeys[_index].currentState?.closeDrawer();
    setState(() => _index = value);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingSettlements());
    _startNotificationPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationPollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingSettlements();
      _refreshNotificationBadge();
      _startNotificationPolling();
    } else if (state == AppLifecycleState.paused) {
      _notificationPollTimer?.cancel();
    }
  }

  void _startNotificationPolling() {
    _notificationPollTimer?.cancel();
    _notificationPollTimer = Timer.periodic(_notificationPollInterval, (_) => _refreshNotificationBadge());
  }

  void _refreshNotificationBadge() {
    if (!mounted) return;
    ref.invalidate(unreadNotificationCountProvider);
    // Also refreshes the list screen itself for whenever it's next opened —
    // same "start over from page 1" behaviour its own pull-to-refresh
    // already has, just triggered on a timer instead of a manual pull.
    ref.invalidate(notificationsControllerProvider);
  }

  /// The mandatory settlement prompt (PendingSettlementGate) — checked right
  /// when the app opens and every time it comes back to the foreground, so a
  /// completed booking's frozen deposit never just sits there unresolved.
  Future<void> _checkPendingSettlements() async {
    try {
      final pending = await ref.read(bookingApiProvider).pendingSettlements();
      if (pending.isNotEmpty && mounted) {
        await showPendingSettlementGate(context, pending);
      }
    } catch (_) {
      // No connection or a transient error — the gate simply reappears next
      // time the app opens or resumes; not worth surfacing as an error here.
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;
    final avatarUrl = authState is AuthSignedIn
        ? (authState.user.logoUrl ?? authState.user.imageUrl)
        : null;

    final tabs = [
      isBusiness
          ? BusinessHomeScreen(scaffoldKey: _scaffoldKeys[0])
          : CustomerHomeScreen(scaffoldKey: _scaffoldKeys[0]),
      AllCategoriesScreen(scaffoldKey: _scaffoldKeys[1]),
      MyServicesScreen(scaffoldKey: _scaffoldKeys[2]),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(
            icon: _HomeTabIcon(avatarUrl: avatarUrl, selected: _index == 0),
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(Icons.category_outlined, size: 28),
            selectedIcon: Icon(Icons.category_rounded, size: 28),
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, size: 28),
            selectedIcon: Icon(Icons.grid_view_rounded, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }
}

/// The Home tab's own icon: the signed-in account's avatar when it has one,
/// a ring around it while selected — same "this is you" affordance a house
/// icon can't give.
class _HomeTabIcon extends StatelessWidget {
  final String? avatarUrl;
  final bool selected;
  const _HomeTabIcon({required this.avatarUrl, required this.selected});

  @override
  Widget build(BuildContext context) {
    // Blended against white rather than the tab bar's own background so the
    // navy icon's contrast stays the same in both themes — see the matching
    // note on profile_cover_header.dart's _Avatar.
    final placeholderFill = Color.alphaBlend(
      AppColors.accentGold.withValues(alpha: 0.15),
      Colors.white,
    );
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: selected
            ? Border.all(color: AppColors.accentGold, width: 2)
            : null,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? CachedNetworkImage(imageUrl: avatarUrl!, fit: BoxFit.cover)
            : Container(
                color: placeholderFill,
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.primaryNavy,
                ),
              ),
      ),
    );
  }
}
