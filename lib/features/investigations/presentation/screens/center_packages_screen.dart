import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/investigations_providers.dart';
import '../../data/models/investigation.dart';
import '../widgets/investigation_widgets.dart';

/// «باقات»: the centre prices a named set of its tests as ONE (a package), and a lab says what it charges to take the
/// sample at the patient's home. What it writes here is what the patient sees on the centre's page and pays.
class CenterPackagesScreen extends ConsumerStatefulWidget {
  const CenterPackagesScreen({super.key});

  @override
  ConsumerState<CenterPackagesScreen> createState() => _CenterPackagesScreenState();
}

class _CenterPackagesScreenState extends ConsumerState<CenterPackagesScreen> {
  final _home = TextEditingController();
  bool _homeLoaded = false;
  bool _savingHome = false;

  @override
  void dispose() {
    _home.dispose();
    super.dispose();
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _saveHome() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _savingHome = true);
    try {
      final fee = double.tryParse(_home.text.trim().replaceAll(',', '.'));
      await ref.read(investigationsApiProvider).saveHomeFee(fee);
      ref.invalidate(centerPackagesProvider);
      _message(l10n.invHomeFeeSaved);
    } catch (e) {
      _message(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _savingHome = false);
    }
  }

  Future<void> _edit([CenterPackage? existing]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PackageSheet(existing: existing),
    );
    if (changed == true) ref.invalidate(centerPackagesProvider);
  }

  Future<void> _delete(CenterPackage p) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(investigationsApiProvider).deletePackage(p.id);
      ref.invalidate(centerPackagesProvider);
    } catch (e) {
      _message(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(centerPackagesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invPackagesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: Text(l10n.invPackageAdd),
      ),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(centerPackagesProvider),
        builder: (context, data) {
          if (!_homeLoaded) {
            _home.text = data.homeFee == null ? '' : formatInvestigationMoney(data.homeFee!);
            _homeLoaded = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(l10n.invPackagesHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 12),
              if (data.packages.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text(l10n.invPackagesEmpty)))
              else
                for (final p in data.packages)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _edit(p),
                      leading: Icon(p.isActive ? Icons.inventory_2_outlined : Icons.visibility_off_outlined),
                      title: Text(p.name),
                      subtitle: Text(
                        [if (p.tests.isNotEmpty) l10n.invIncludes(p.tests.join('، ')), if (!p.isActive) l10n.invPackageHidden].join('\n'),
                      ),
                      isThreeLine: p.tests.isNotEmpty,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${formatInvestigationMoney(p.price)} ${l10n.invCurrency}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          IconButton(tooltip: l10n.commonDelete, icon: const Icon(Icons.delete_outline), onPressed: () => _delete(p)),
                        ],
                      ),
                    ),
                  ),
              // a lab only: the sample at the patient's home
              if (data.canHome) ...[
                const Divider(height: 32),
                Text(l10n.invHomeCollection, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.invHomeFeeHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _home,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.invHomeFeeLabel, suffixText: l10n.invCurrency),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _savingHome ? null : _saveHome,
                      child: _savingHome
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.commonSave),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PackageSheet extends ConsumerStatefulWidget {
  final CenterPackage? existing;
  const _PackageSheet({this.existing});

  @override
  ConsumerState<_PackageSheet> createState() => _PackageSheetState();
}

class _PackageSheetState extends ConsumerState<_PackageSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();
  final Set<int> _tests = {};
  bool _active = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _name.text = p.name;
      _price.text = formatInvestigationMoney(p.price);
      _note.text = p.note ?? '';
      _tests.addAll(p.optionIds);
      _active = p.isActive;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    if (_name.text.trim().isEmpty || price == null || price <= 0 || _tests.isEmpty) {
      setState(() => _error = l10n.invPackageNeedTests);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(investigationsApiProvider).savePackage(
        id: widget.existing?.id,
        name: _name.text.trim(),
        price: price,
        optionIds: _tests.toList(),
        note: _note.text.trim(),
        active: _active,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final prices = ref.watch(centerPriceListProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? l10n.invPackageAdd : l10n.invPackageEdit, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.invPackageName)),
            const SizedBox(height: 8),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.invPackagePrice, suffixText: l10n.invCurrency),
            ),
            const SizedBox(height: 8),
            TextField(controller: _note, decoration: InputDecoration(labelText: l10n.invPackageNote)),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: Text(_active ? l10n.invPackageShow : l10n.invPackageHidden),
            ),
            Text(l10n.invPackageTests, style: theme.textTheme.titleSmall),
            Expanded(
              child: prices.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
                data: (all) {
                  // the words of the platform's lists the centre does (it priced them); the rest are not its to include
                  final mine = all.where((t) => t.price != null).toList();

                  return ListView(
                    children: [
                      for (final t in mine)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _tests.contains(t.optionId),
                          onChanged: (on) => setState(() => on == true ? _tests.add(t.optionId) : _tests.remove(t.optionId)),
                          title: Text(t.name),
                          secondary: Text('${formatInvestigationMoney(t.price!)} ${l10n.invCurrency}', style: theme.textTheme.bodySmall),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.invPackageSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
