import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../features/data_import/presentation/screens/data_import_hub_screen.dart';
import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../features/settings/application/locale_controller.dart';
import '../../features/settings/application/theme_mode_controller.dart';
import '../../features/staff/application/staff_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../desktop_app.dart';
import '../print/suite_print.dart';
import '../shell/desktop_shell.dart';
import '../sync/desktop_sync.dart';
import 'common.dart';
import 'devices_page.dart';

/// «الإعدادات والاشتراك» — switching the suite on (the first month from the wallet), the parts of it this business uses
/// (what its category allows), the owner's approval limit for purchase orders, the subscription's state, and the writes
/// the server refused after an offline spell.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _limit = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  Future<void> _update(Future<InvSettings> Function() call) async {
    await suiteRun(context, call, queueable: false);
    ref.invalidate(invSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(inventoryApiProvider);
    final store = ref.watch(suiteStoreProvider);

    return SuitePage(
      title: l10n.suiteNavSettings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AppPrefs(),
          AsyncValueView<InvSettings>(
            value: ref.watch(invSettingsProvider),
            onRetry: () => ref.invalidate(invSettingsProvider),
            builder: (context, s) {
              if (!_seeded) {
                _limit.text = s.poApprovalThreshold == null ? '' : invNum(s.poApprovalThreshold!);
                _seeded = true;
              }
              if (!s.available) return Text(l10n.stkNotAvailable);

              final sub = s.subscription;
              final rejected = store.rejected();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (kSuiteTestRoleSwitch && s.isOwner) const _TestDeviceRole(),
                  SuiteSection(
                    title: l10n.suiteSubscription,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub.price > 0 ? l10n.stkSubscriptionPrice(InvLabels.money(sub.price)) : l10n.stkSubscriptionFree),
                        Text(l10n.suiteSubscriptionStatus(_status(l10n, sub.status))),
                        if (sub.paidUntil != null) Text(l10n.suitePaidUntil(MaterialLocalizations.of(context).formatMediumDate(sub.paidUntil!))),
                        const SizedBox(height: 6),
                        Text(l10n.suiteSubscriptionRules, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 10),
                        if (s.isOwner && !s.enabled) FilledButton(onPressed: () => _update(() => api.updateSettings(enabled: true)), child: Text(l10n.stkEnableAction)),
                        if (s.isOwner && s.enabled && sub.status != 'active') FilledButton(onPressed: () => _update(api.renew), child: Text(l10n.suiteRenew)),
                        if (!s.isOwner && !s.enabled) Text(l10n.stkOwnerEnables),
                      ],
                    ),
                  ),
                  if (s.enabled)
                    SuiteSection(
                      title: l10n.suiteParts,
                      child: Column(
                        children: [
                          Text(l10n.suitePartsHint, style: Theme.of(context).textTheme.bodySmall),
                          for (final f in s.features)
                            SwitchListTile(
                              title: Text(f.label),
                              subtitle: f.optional ? Text(l10n.suiteOptional) : null,
                              value: f.on,
                              onChanged: !s.isOwner || f.key == 'units'
                                  ? null
                                  : (v) => _update(
                                      () => api.updateSettings(
                                        features: [
                                          for (final x in s.features)
                                            if (x.key == f.key ? v : x.on) x.key,
                                        ],
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  if (s.enabled && s.isOwner)
                    SuiteSection(
                      title: l10n.suiteApprovalLimit,
                      child: Row(
                        children: [
                          NumField(controller: _limit, label: l10n.suiteApprovalLimitField, width: 240),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () {
                              final v = parseNum(_limit.text);
                              _update(() => api.updateSettings(poApprovalThreshold: v, clearThreshold: v == null));
                            },
                            child: Text(l10n.commonSave),
                          ),
                        ],
                      ),
                    ),
                  if (s.enabled) const _PrintSettings(),
                  if (rejected.isNotEmpty)
                    SuiteSection(
                      title: l10n.suiteRejectedTitle,
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await store.clearRejected();
                            setState(() {});
                          },
                          child: Text(l10n.suiteClear),
                        ),
                      ],
                      child: Column(
                        children: [for (final r in rejected) ListTile(dense: true, title: Text('${r['message']}'), subtitle: Text('${r['method']} ${r['path']} · ${r['at']}'))],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _status(AppLocalizations l10n, String status) => switch (status) {
    'active' => l10n.suiteSubActive,
    'grace' => l10n.suiteSubGrace,
    'read_only' => l10n.suiteSubReadOnly,
    _ => l10n.suiteSubNone,
  };
}

/// TEMPORARY (owner, 2026-10-30: «اضف خيارات تغيير بين انواع الاجهزة فترة الاختبارات ونحذف لاحقا»): while the suite
/// is being tried on one computer, the owner switches THIS computer between the device types from here — a computer
/// set to «مخزن» loses the «الأجهزة» screen and could not come back. Set to false (and delete [_TestDeviceRole]) to remove.
const kSuiteTestRoleSwitch = true;

class _TestDeviceRole extends ConsumerWidget {
  const _TestDeviceRole();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final device = ref.watch(thisDeviceProvider).valueOrNull;
    final store = ref.watch(suiteStoreProvider);

    Future<void> switchTo(String role) async {
      final api = ref.read(inventoryApiProvider);
      await suiteRun(
        context,
        () => device == null
            ? api.registerDevice(uuid: store.deviceUuid, name: suiteRoleLabel(l10n, role), role: role, isHub: role == 'main')
            : api.updateDevice(device.id, {'role': role, 'screens': null, 'is_hub': role == 'main'}),
        queueable: false,
      );
      ref.invalidate(thisDeviceProvider);
      ref.read(currentScreenProvider.notifier).state = SuiteScreen.settings;
    }

    return Card(
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Tone.warn(context), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.suiteTestRoleTitle,
              style: TextStyle(fontWeight: FontWeight.w800, color: Tone.warn(context)),
            ),
            const SizedBox(height: 4),
            Text(l10n.suiteTestRoleHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final r in suiteRoles) ChoiceChip(label: Text(suiteRoleLabel(l10n, r)), selected: device?.role == r, onSelected: device?.role == r ? null : (_) => switchTo(r))],
            ),
          ],
        ),
      ),
    );
  }
}

/// «اللغة والمظهر والبيانات» — shown on every computer, the suite switched on or not (attendance and payroll work
/// without it): the language and theme are this computer's own (kept on it, like the phone's), and «استيراد بياناتي»
/// opens the same import wizard as the phone for the parts this business has.
class _AppPrefs extends ConsumerWidget {
  const _AppPrefs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);
    final mode = ref.watch(themeModeControllerProvider);
    final isOwner = ref.watch(suiteBusinessProvider)?.isOwnerAccount ?? false;
    final keys = isOwner ? ref.watch(myServiceKeysProvider).valueOrNull : null;
    final canImport = keys != null && (keys.contains('menu') || keys.contains('clinic') || keys.contains('bookings'));

    return SuiteSection(
      title: l10n.suiteAppPrefs,
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.settingsLanguage, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'ar', label: Text(l10n.settingsLanguageArabic)),
                  ButtonSegment(value: 'en', label: Text(l10n.settingsLanguageEnglish)),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (v) => ref.read(localeControllerProvider.notifier).setLocale(Locale(v.first)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.settingsAppearance, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(l10n.settingsAppearanceLight)),
                  ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(l10n.settingsAppearanceDark)),
                  ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.computer_outlined), label: Text(l10n.settingsAppearanceSystem)),
                ],
                selected: {mode},
                onSelectionChanged: (v) => ref.read(themeModeControllerProvider.notifier).setThemeMode(v.first),
              ),
            ],
          ),
          if (canImport)
            OutlinedButton.icon(
              icon: const Icon(Icons.import_export_outlined),
              label: Text(l10n.importHubTitle),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DataImportHubScreen(hasMenu: keys.contains('menu'), hasClinic: keys.contains('clinic'), hasUnits: keys.contains('bookings')),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// «الطباعة على هذا الجهاز» — each computer picks its receipt printer (an 80 mm roll) and its documents printer (A4),
/// from the printers Windows / macOS know — «Microsoft Print to PDF» included, to try it without paper. None picked:
/// the system's print dialog opens.
class _PrintSettings extends ConsumerStatefulWidget {
  const _PrintSettings();

  @override
  ConsumerState<_PrintSettings> createState() => _PrintSettingsState();
}

class _PrintSettingsState extends ConsumerState<_PrintSettings> {
  late final Future<List<Printer>> _printers = Printing.listPrinters();

  Future<void> _set(String key, String? value) async {
    final meta = ref.read(suiteStoreProvider).meta;
    value == null || value.isEmpty ? await meta.delete(key) : await meta.put(key, value);
    setState(() {});
  }

  Future<void> _testReceipt() async {
    final l10n = AppLocalizations.of(context)!;
    final pdf = await SuitePrint.receipt(
      businessName: ref.read(suiteBusinessProvider)?.name ?? '',
      title: l10n.suiteTestPrint,
      number: 'TEST',
      at: DateTime.now(),
      lines: const [
        PrintLine(name: 'وجبة برجر دبل', qty: '2', price: '260', total: '520'),
        PrintLine(name: 'في كولا علبة', qty: '3', price: '25', total: '75'),
      ],
      total: '595',
      paid: '600',
      change: '5',
      footer: l10n.suiteReceiptFooter,
      labels: {'number': l10n.suiteReceiptNumber, 'date': l10n.suiteWhen, 'total': l10n.stkTotal, 'paid': l10n.suitePaidCash, 'change': l10n.suiteChangeLabel},
    );
    try {
      await ref.read(suitePrintProvider).print(pdf, receipt: true, name: 'test-receipt');
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.suitePrintFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = ref.watch(suiteStoreProvider).meta;

    return SuiteSection(
      title: l10n.suitePrinting,
      child: FutureBuilder<List<Printer>>(
        future: _printers,
        builder: (context, snap) {
          final printers = snap.data ?? const <Printer>[];
          DropdownButtonFormField<String> picker(String key, String label) {
            final current = meta.get(key);
            return DropdownButtonFormField<String>(
              initialValue: printers.any((p) => p.url == current) ? current : '',
              decoration: InputDecoration(labelText: label),
              items: [
                DropdownMenuItem(value: '', child: Text(l10n.suitePrintDialog)),
                for (final p in printers) DropdownMenuItem(value: p.url, child: Text(p.name)),
              ],
              onChanged: (v) => _set(key, v),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              picker(SuitePrint.receiptPrinterKey, l10n.suiteReceiptPrinter),
              const SizedBox(height: 8),
              picker(SuitePrint.documentPrinterKey, l10n.suiteDocumentPrinter),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.suiteAutoReceipt),
                value: meta.get(SuitePrint.autoReceiptKey) == '1',
                onChanged: (v) => _set(SuitePrint.autoReceiptKey, v ? '1' : null),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(icon: const Icon(Icons.print_outlined), label: Text(l10n.suiteTestPrint), onPressed: _testReceipt),
              ),
            ],
          );
        },
      ),
    );
  }
}
