import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/form_save_button.dart';
import '../../application/hospital_providers.dart';
import '../../data/models/hospital_procedure.dart';
import '../widgets/procedure_widgets.dart';

/// The hospital's own list of medical procedures: tick the ones it does and write its price (empty = «السعر بعد
/// التقييم»), or add a procedure the platform list does not have. The price is the hospital's, like a centre's test.
class HospitalProceduresManageScreen extends ConsumerStatefulWidget {
  const HospitalProceduresManageScreen({super.key});

  @override
  ConsumerState<HospitalProceduresManageScreen> createState() => _HospitalProceduresManageScreenState();
}

class _HospitalProceduresManageScreenState extends ConsumerState<HospitalProceduresManageScreen> {
  final Map<int, bool> _offered = {};
  final Map<int, TextEditingController> _prices = {};
  final Map<int, bool> _was = {};
  final Map<int, String> _wasPrice = {};
  bool _seeded = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _prices.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _seed(List<ProcedureCatalogSection> sections) {
    for (final e in sections.expand((s) => s.entries)) {
      _offered[e.id] = e.offered;
      _was[e.id] = e.offered;
      _wasPrice[e.id] = e.price == null ? '' : formatProcedureMoney(e.price!);
      final c = _prices[e.id];
      if (c == null) {
        _prices[e.id] = TextEditingController(text: _wasPrice[e.id]);
      } else {
        c.text = _wasPrice[e.id]!;
      }
    }
    _seeded = true;
  }

  bool get _dirty => _offered.entries.any((e) => e.value != (_was[e.key] ?? false)) ||
      _prices.entries.any((e) => (_offered[e.key] ?? false) && e.value.text.trim() != (_wasPrice[e.key] ?? ''));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final keep = {
        for (final e in _offered.entries)
          if (e.value) e.key: double.tryParse((_prices[e.key]?.text ?? '').trim().replaceAll(',', '.')),
      };
      final remove = [for (final e in _offered.entries) if (!e.value && (_was[e.key] ?? false)) e.key];
      final saved = await ref.read(hospitalApiProvider).saveProcedures(keep, remove);
      _seed(saved);
      ref.invalidate(procedureCatalogProvider);
    } catch (e) {
      _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addOwn() async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController();
    var kind = 'surgery';

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.procAddOwn, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [for (final k in procedureKinds) ButtonSegment(value: k, label: Text(procedureKindLabel(l10n, k)))],
                  selected: {kind},
                  onSelectionChanged: (s) => setSheet(() => kind = s.first),
                ),
                const SizedBox(height: 12),
                TextField(controller: name, decoration: InputDecoration(labelText: l10n.procOwnName)),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => Navigator.of(sheetContext).pop(true), child: Text(l10n.procAddOwn)),
              ],
            ),
          ),
        ),
      ),
    );
    final text = name.text.trim();
    name.dispose();
    if (ok != true || text.isEmpty) return;

    try {
      final sections = await ref.read(hospitalApiProvider).addOwnProcedure(kind, text);
      if (mounted) setState(() => _seed(sections));
      ref.invalidate(procedureCatalogProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _deleteOwn(ProcedureCatalogEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final sections = await ref.read(hospitalApiProvider).deleteOwnProcedure(entry.id);
      if (mounted) setState(() => _seed(sections));
      ref.invalidate(procedureCatalogProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(procedureCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.procManageTitle),
        actions: [IconButton(tooltip: l10n.procAddOwn, icon: const Icon(Icons.add), onPressed: _addOwn)],
      ),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(procedureCatalogProvider),
        builder: (context, sections) {
          if (!_seeded) _seed(sections);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.procManageHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              for (final s in sections) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 6),
                  child: Text(procedureKindLabel(l10n, s.kind), style: theme.textTheme.titleMedium),
                ),
                for (final e in s.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Checkbox(value: _offered[e.id] ?? false, onChanged: (v) => setState(() => _offered[e.id] = v ?? false)),
                        Expanded(child: Text(e.name)),
                        if (e.own)
                          IconButton(tooltip: l10n.commonDelete, icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _deleteOwn(e)),
                        if (_offered[e.id] ?? false)
                          SizedBox(
                            width: 112,
                            child: TextField(
                              controller: _prices[e.id],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(hintText: l10n.invPriceLabel, isDense: true, suffixText: l10n.invCurrency),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FormSaveButton(saving: _saving, saved: !_dirty, onPressed: _save),
            ],
          );
        },
      ),
    );
  }
}
