import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../booking_settings/application/booking_settings_controller.dart';
import '../../../booking_settings/data/models/booking_settings_models.dart';
import '../../data/import_core.dart';
import '../../data/units_import.dart';
import 'import_wizard_screen.dart';

/// «الغرف والوحدات» — bring a hotel's (or a court's, a hall's) old list of units in. The service and the unit type are
/// chosen once here; the sheet then says, per row, the number, name, kind, capacity and count.
class UnitsImportScreen extends ConsumerStatefulWidget {
  const UnitsImportScreen({super.key});

  @override
  ConsumerState<UnitsImportScreen> createState() => _UnitsImportScreenState();
}

class _UnitsImportScreenState extends ConsumerState<UnitsImportScreen> {
  BookableItemsOptionsPayload? _options;
  bool _failed = false;
  BusinessServiceOption? _service;
  ServiceItemType? _type;
  int? _kindId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final options = await ref.read(bookingSettingsApiProvider).bookableItemsOptions();
      if (!mounted) return;
      final services = options.services.where((s) => s.itemTypes.isNotEmpty).toList();
      setState(() {
        _options = options;
        _service = services.isEmpty ? null : services.first;
        _type = _service?.itemTypes.first;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  List<NamedOption> get _kinds => [for (final g in _options?.lineOptions ?? const <VocabularyGroup>[]) ...g.options];

  void _next() {
    final l10n = AppLocalizations.of(context)!;
    final service = _service!;
    final type = _type!;
    final kinds = _kinds;
    final defaultKind = _kindId;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImportWizardScreen(
          title: l10n.importHubUnits,
          intro: l10n.unitsImportIntro,
          memoryKey: 'bookable_units',
          templateName: 'units-template.xlsx',
          fields: unitImportFields,
          apply: (grid, mapping) async {
            final api = ref.read(bookingSettingsApiProvider);
            final result = unitsFromGrid(grid, mapping);
            final skipped = [...result.skipped];

            // a unit already on the account (same service, type and number) is left as it is
            final have = {
              for (final i in await api.bookableItems())
                if (i.serviceId == service.id && i.itemType == type.key) normalizeHeader(i.code),
            };

            var created = 0;
            for (final u in result.units) {
              if (have.contains(normalizeHeader(u.code))) {
                skipped.add((row: u.row, reason: 'موجودة من قبل'));
                continue;
              }
              try {
                await api.createBookableItem(
                  serviceId: service.id,
                  itemType: type.key,
                  code: u.code,
                  lineOptionId: matchKind(u.kindText, kinds)?.id ?? defaultKind,
                  capacity: u.capacity,
                  title: u.title,
                  description: u.description,
                  quantity: u.quantity,
                );
                created++;
              } catch (_) {
                skipped.add((row: u.row, reason: 'لم يقبلها الخادم'));
              }
            }

            ref.invalidate(bookingSettingsControllerProvider);
            skipped.sort((a, b) => a.row.compareTo(b.row));

            return ImportSummary(created: created, skipped: skipped);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final services = (_options?.services ?? const <BusinessServiceOption>[]).where((s) => s.itemTypes.isNotEmpty).toList();

    Widget body;
    if (_failed) {
      body = Center(child: TextButton(onPressed: _load, child: Text(l10n.commonSomethingWentWrong)));
    } else if (_options == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (services.isEmpty) {
      body = Center(child: Text(l10n.unitsImportNone));
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.unitsImportIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _service?.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.unitsImportService),
            items: [for (final s in services) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: (id) => setState(() {
              _service = services.firstWhere((s) => s.id == id);
              _type = _service!.itemTypes.first;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('type-${_service?.id}'),
            initialValue: _type?.key,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.unitsImportType),
            items: [for (final t in _service!.itemTypes) DropdownMenuItem(value: t.key, child: Text(t.label.isEmpty ? t.key : t.label))],
            onChanged: (key) => setState(() => _type = _service!.itemTypes.firstWhere((t) => t.key == key)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _kindId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.unitsImportKind, helperText: l10n.unitsImportKindHelp),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(l10n.unitsImportKindNone)),
              for (final k in _kinds) DropdownMenuItem<int?>(value: k.id, child: Text(k.name)),
            ],
            onChanged: (v) => setState(() => _kindId = v),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _next, child: Text(l10n.unitsImportNext)),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: Text(l10n.importHubUnits)), body: body);
  }
}
