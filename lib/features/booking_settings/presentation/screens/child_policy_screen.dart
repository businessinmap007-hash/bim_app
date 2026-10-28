import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../booking/data/models/child_policy.dart';
import '../../application/booking_settings_controller.dart';

/// «سياسة الأطفال»: the hotel writes its age bands («حتى 5 مجانًا، من 6 إلى 11 بنصف سعر الليلة»), the age from which a child takes a
/// place in the room, the age of an adult, and whether a child's meals follow the same percentage. It applies to every room of the
/// hotel and to the rooms its partners sell.
class ChildPolicyScreen extends ConsumerStatefulWidget {
  const ChildPolicyScreen({super.key});

  @override
  ConsumerState<ChildPolicyScreen> createState() => _ChildPolicyScreenState();
}

class _ChildPolicyScreenState extends ConsumerState<ChildPolicyScreen> {
  bool _loaded = false;
  bool _failed = false;
  bool _saving = false;
  int _adult = 12;
  int _counts = 6;
  bool _meals = true;
  final _bedPrice = TextEditingController();
  int _bedsMax = 1;

  /// «بالغ واحد مع طفل»: null = the child pays its normal share
  double? _single;
  List<ChildBand> _bands = const [ChildBand(from: 0, to: 5, percent: 0, secondPercent: 50), ChildBand(from: 6, to: 11, percent: 50)];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(bookingSettingsApiProvider).childPolicy();
      if (!mounted) return;
      setState(() {
        if (p != null) {
          _adult = p.adultFromAge;
          _counts = p.countsFromAge;
          _meals = p.mealsFollow;
          _bands = p.bands;
          _bedPrice.text = p.extraBedPrice == null ? '' : p.extraBedPrice!.toStringAsFixed(p.extraBedPrice! % 1 == 0 ? 0 : 2);
          _bedsMax = p.extraBedsMax;
          _single = p.singleParentPercent;
        }
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final bed = double.tryParse(_bedPrice.text.trim().replaceAll(',', '.'));
      await ref.read(bookingSettingsApiProvider).saveChildPolicy(
        ChildPolicy(adultFromAge: _adult, countsFromAge: _counts, mealsFollow: _meals, bands: _bands, extraBedPrice: bed, extraBedsMax: _bedsMax, singleParentPercent: _single),
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.childPolicySaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _setBand(int i, ChildBand b) => setState(() => _bands = [for (var k = 0; k < _bands.length; k++) k == i ? b : _bands[k]]);

  Widget _ageField(int value, ValueChanged<int> onChanged, {int min = 0, int max = 17}) => DropdownButton<int>(
    value: value.clamp(min, max),
    items: [for (var a = min; a <= max; a++) DropdownMenuItem(value: a, child: Text('$a'))],
    onChanged: (v) => v == null ? null : onChanged(v),
  );

  /// Free, half or a third of one person's night, or a percentage the hotel writes.
  Widget _payRow(AppLocalizations l10n, String label, double value, ValueChanged<double> onChanged, String key) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      SizedBox(width: 92, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      for (final p in const [0.0, 50.0, 33.33])
        ChoiceChip(
          label: Text(p == 0 ? l10n.childFree : (p == 50 ? l10n.childHalf : l10n.childThird)),
          selected: value == p,
          onSelected: (_) => onChanged(p),
        ),
      SizedBox(
        width: 96,
        child: TextFormField(
          key: ValueKey('pct-$key-$value'),
          initialValue: value == 0 ? '' : value.toStringAsFixed(value % 1 == 0 ? 0 : 2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(isDense: true, labelText: l10n.childPolicyPercent, suffixText: '%'),
          onFieldSubmitted: (v) => onChanged((double.tryParse(v.replaceAll(',', '.')) ?? 0).clamp(0, 100).toDouble()),
        ),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.childPolicyTitle)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.childPolicyIntro, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 16),
                Text(l10n.childPolicyBands, style: theme.textTheme.titleMedium),
                for (var i = 0; i < _bands.length; i++)
                  Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(l10n.childPolicyFrom),
                            const SizedBox(width: 8),
                            _ageField(_bands[i].from, (v) => _setBand(i, _bands[i].copyWith(from: v)), max: _adult - 1),
                            const SizedBox(width: 16),
                            Text(l10n.childPolicyTo),
                            const SizedBox(width: 8),
                            _ageField(_bands[i].to, (v) => _setBand(i, _bands[i].copyWith(to: v)), max: _adult - 1),
                            const Spacer(),
                            IconButton(
                              tooltip: l10n.commonDelete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => setState(() => _bands = [..._bands]..removeAt(i)),
                            ),
                          ]),
                          // what a child of these ages pays of one person's night: the room's FIRST child, then each further one
                          _payRow(l10n, l10n.childPolicyFirstChild, _bands[i].percent, (p) => _setBand(i, _bands[i].copyWith(percent: p)), 'f$i'),
                          _payRow(l10n, l10n.childPolicyNextChild, _bands[i].secondPercent, (p) => _setBand(i, _bands[i].copyWith(secondPercent: p)), 's$i'),
                        ],
                      ),
                    ),
                  ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.childPolicyAddBand),
                    onPressed: _bands.length >= 6
                        ? null
                        : () => setState(() {
                            final from = _bands.isEmpty ? 0 : (_bands.last.to + 1).clamp(0, _adult - 1);
                            _bands = [..._bands, ChildBand(from: from, to: (_adult - 1).clamp(from, 17), percent: 50)];
                          }),
                  ),
                ),
                const Divider(height: 24),
                Row(children: [Expanded(child: Text(l10n.childPolicyAdultAge)), _ageField(_adult, (v) => setState(() => _adult = v), min: 1, max: 18)]),
                Row(children: [Expanded(child: Text(l10n.childPolicyCountsFrom)), _ageField(_counts, (v) => setState(() => _counts = v), max: 18)]),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.childPolicyMeals),
                  value: _meals,
                  onChanged: (v) => setState(() => _meals = v),
                ),
                const Divider(height: 24),
                // «سرير إضافي»: instead of refusing a guest over the room's capacity
                Text(l10n.extraBedTitle, style: theme.textTheme.titleMedium),
                Text(l10n.extraBedHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _bedPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.extraBedPrice),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(l10n.extraBedsMax),
                  const SizedBox(width: 8),
                  _ageField(_bedsMax, (v) => setState(() => _bedsMax = v), max: 4),
                ]),
                const Divider(height: 24),
                // «بالغ واحد مع طفل»: the second adult's place is paid for in the room's price; the child in it pays this
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.singleParentTitle),
                  subtitle: Text(l10n.singleParentHint),
                  value: _single != null,
                  onChanged: (v) => setState(() => _single = v ? 0 : null),
                ),
                if (_single != null) _payRow(l10n, l10n.singleParentChild, _single!, (p) => setState(() => _single = p), 'sp'),
                const SizedBox(height: 16),
                FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
              ],
            ),
    );
  }
}
