import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import 'common.dart';
import 'items_page.dart';

final _countsProvider = FutureProvider.autoDispose<List<InvStocktake>>((ref) => ref.watch(inventoryApiProvider).stocktakes());
final _openCountProvider = StateProvider.autoDispose<int?>((ref) => null);
final _countProvider = FutureProvider.autoDispose.family<InvStocktake, int>((ref, id) => ref.watch(inventoryApiProvider).stocktake(id));

/// «الجرد» — blind by default: the counter types what he finds and does not see the computed figure until he finishes;
/// then the differences and their value show for review, and applying books one adjustment per line. Sales during the
/// count stay moves of their own (the expected figures were taken when the count started).
class StocktakePage extends ConsumerWidget {
  const StocktakePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final open = ref.watch(_openCountProvider);

    if (open != null) return _CountScreen(id: open);

    return SuitePage(
      title: l10n.suiteNavStocktake,
      actions: [
        FilledButton.icon(
          icon: const Icon(Icons.playlist_add_check),
          label: Text(l10n.suiteStartCount),
          onPressed: () async {
            final title = TextEditingController();
            final group = TextEditingController();
            var blind = true;
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => StatefulBuilder(
                builder: (ctx, setState) => AlertDialog(
                  title: Text(l10n.suiteStartCount),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: title, decoration: InputDecoration(labelText: l10n.suiteCountTitle)),
                      TextField(controller: group, decoration: InputDecoration(labelText: l10n.suiteCountGroup)),
                      SwitchListTile(value: blind, title: Text(l10n.suiteBlindCount), onChanged: (v) => setState(() => blind = v)),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.suiteStartCount)),
                  ],
                ),
              ),
            );
            if (ok == true && context.mounted) {
              final count = await suiteRun(context, () => ref.read(inventoryApiProvider).startStocktake(
                    title: title.text.trim().isEmpty ? null : title.text.trim(),
                    groupName: group.text.trim().isEmpty ? null : group.text.trim(),
                    blind: blind,
                  ), queueable: false);
              ref.invalidate(_countsProvider);
              if (count != null) ref.read(_openCountProvider.notifier).state = count.id;
            }
            title.dispose();
            group.dispose();
          },
        ),
      ],
      child: AsyncValueView<List<InvStocktake>>(
        value: ref.watch(_countsProvider),
        onRetry: () => ref.invalidate(_countsProvider),
        builder: (context, rows) => Column(
          children: [
            for (final c in rows)
              Card(
                child: ListTile(
                  title: Text(c.title ?? l10n.suiteNavStocktake),
                  subtitle: Text('${_status(l10n, c.status)}${c.startedAt == null ? '' : ' · ${MaterialLocalizations.of(context).formatShortDate(c.startedAt!)}'}'),
                  trailing: c.netDifferenceValue == null ? null : Text(InvLabels.money(c.netDifferenceValue!)),
                  onTap: () => ref.read(_openCountProvider.notifier).state = c.id,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _status(AppLocalizations l10n, String s) => switch (s) {
      'counting' => l10n.suiteCounting,
      'review' => l10n.suiteReview,
      'applied' => l10n.suiteApplied,
      _ => l10n.stkPoCancelled,
    };

class _CountScreen extends ConsumerStatefulWidget {
  final int id;
  const _CountScreen({required this.id});

  @override
  ConsumerState<_CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends ConsumerState<_CountScreen> {
  final Map<String, TextEditingController> _counted = {};
  final Map<String, TextEditingController> _reasons = {};
  final _scan = TextEditingController();

  @override
  void dispose() {
    for (final c in [..._counted.values, ..._reasons.values, _scan]) {
      c.dispose();
    }
    super.dispose();
  }

  String _key(InvStocktakeLine l) => '${l.itemId}:${l.lotId ?? 0}';

  Future<void> _saveCounts(InvStocktake count) async {
    final lines = [
      for (final l in count.lines)
        if (_counted[_key(l)]?.text.trim().isNotEmpty ?? false)
          {'item_id': l.itemId, 'lot_id': ?l.lotId, 'counted_qty': parseNum(_counted[_key(l)]!.text), 'reason': _reasons[_key(l)]?.text.trim()},
    ];
    if (lines.isEmpty) return;
    await suiteRun(context, () => ref.read(inventoryApiProvider).countLines(count.id, lines));
    ref.invalidate(_countProvider(count.id));
  }

  Future<void> _action(InvStocktake count, String action) async {
    if (action != 'cancel') await _saveCounts(count);
    if (!mounted) return;
    await suiteRun(context, () => ref.read(inventoryApiProvider).stocktakeAction(count.id, action), queueable: false);
    ref.invalidate(_countProvider(count.id));
    ref.invalidate(_countsProvider);
    ref.invalidate(suiteItemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(suiteItemsProvider).valueOrNull?.items ?? const <InvItem>[];

    return AsyncValueView<InvStocktake>(
      value: ref.watch(_countProvider(widget.id)),
      onRetry: () => ref.invalidate(_countProvider(widget.id)),
      builder: (context, count) {
        final editable = count.status == 'counting' || count.status == 'review';
        for (final l in count.lines) {
          _counted.putIfAbsent(_key(l), () => TextEditingController(text: l.countedQty == null ? '' : invNum(l.countedQty!)));
          _reasons.putIfAbsent(_key(l), () => TextEditingController(text: l.reason ?? ''));
        }

        return SuitePage(
          title: '${count.title ?? l10n.suiteNavStocktake} — ${_status(l10n, count.status)}',
          actions: [
            TextButton(onPressed: () => ref.read(_openCountProvider.notifier).state = null, child: Text(l10n.suiteBack)),
            if (editable) OutlinedButton(onPressed: () => _saveCounts(count), child: Text(l10n.commonSave)),
            if (count.status == 'counting') FilledButton(onPressed: () => _action(count, 'finish'), child: Text(l10n.suiteFinishCount)),
            if (count.status == 'review') FilledButton(onPressed: () => _action(count, 'apply'), child: Text(l10n.suiteApplyCount)),
            if (editable) TextButton(onPressed: () => _action(count, 'cancel'), child: Text(l10n.commonCancel)),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (count.blind && count.status == 'counting') Text(l10n.suiteBlindHint, style: TextStyle(color: Tone.warn(context), fontWeight: FontWeight.w700)),
              if (editable)
                TextField(
                  controller: _scan,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.qr_code_scanner), hintText: l10n.suiteScanToCount),
                  onSubmitted: (code) {
                    final c = code.trim();
                    _scan.clear();
                    final item = items.where((i) => i.barcode == c || i.units.any((u) => u.barcode == c)).firstOrNull;
                    final line = item == null ? null : count.lines.where((l) => l.itemId == item.id).firstOrNull;
                    if (line == null) return;
                    final step = item!.units.where((u) => u.barcode == c).firstOrNull?.factor ?? 1;
                    final ctrl = _counted[_key(line)]!;
                    setState(() => ctrl.text = invNum((parseNum(ctrl.text) ?? 0) + step));
                  },
                ),
              if (count.netDifferenceValue != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.suiteNetDifference(InvLabels.money(count.netDifferenceValue!)), style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              Card(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(l10n.suiteItem)),
                    DataColumn(label: Text(l10n.suiteExpected)),
                    DataColumn(label: Text(l10n.suiteCounted)),
                    DataColumn(label: Text(l10n.suiteDifference)),
                    DataColumn(label: Text(l10n.stkReason)),
                  ],
                  rows: [
                    for (final l in count.lines)
                      DataRow(cells: [
                        DataCell(Text('${l.itemName ?? ''} (${l.baseUnit ?? ''})')),
                        DataCell(Text(l.expectedQty == null ? '•••' : invNum(l.expectedQty!))),
                        DataCell(editable ? SizedBox(width: 90, child: TextField(controller: _counted[_key(l)], keyboardType: TextInputType.number)) : Text(l.countedQty == null ? '—' : invNum(l.countedQty!))),
                        DataCell(Text(l.difference == null ? '' : invNum(l.difference!),
                            style: TextStyle(fontWeight: FontWeight.w800, color: (l.difference ?? 0) < 0 ? Tone.bad(context) : Tone.good(context)))),
                        DataCell(editable ? SizedBox(width: 180, child: TextField(controller: _reasons[_key(l)])) : Text(l.reason ?? '')),
                      ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
