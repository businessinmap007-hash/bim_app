import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import 'common.dart';

final _itemsQueryProvider = StateProvider.autoDispose<({String search, String? group, bool below, String? barcode})>(
  (ref) => (search: '', group: null, below: false, barcode: null),
);

final suiteItemsProvider = FutureProvider.autoDispose<({List<InvItem> items, List<String> groups})>((ref) {
  final q = ref.watch(_itemsQueryProvider);
  return ref.watch(inventoryApiProvider).items(search: q.search, group: q.group, below: q.below, barcode: q.barcode);
});

final _selectedItemProvider = StateProvider.autoDispose<int?>((ref) => null);

final _ledgerProvider = FutureProvider.autoDispose.family<List<InvMove>, int>((ref, id) => ref.watch(inventoryApiProvider).itemMoves(id));

/// «الأصناف والمخزون» — every stock item with its balance in the biggest units, average cost and value; the selected
/// item's ledger (each move with the balance after it) beside the list. A barcode scanner types into the search box and
/// Enter finds the item by its own or one of its units' barcodes.
class ItemsPage extends ConsumerStatefulWidget {
  const ItemsPage({super.key});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _query({String? search, String? group, bool clearGroup = false, bool? below, String? barcode}) {
    final q = ref.read(_itemsQueryProvider);
    ref.read(_itemsQueryProvider.notifier).state = (
      search: search ?? q.search,
      group: clearGroup ? null : (group ?? q.group),
      below: below ?? q.below,
      barcode: barcode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = ref.watch(suiteItemsProvider);
    final query = ref.watch(_itemsQueryProvider);
    final selected = ref.watch(_selectedItemProvider);

    return SuitePage(
      title: l10n.suiteNavItems,
      scroll: false,
      actions: [
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.suiteNewItem),
          onPressed: () async {
            final saved = await showDialog<bool>(context: context, builder: (_) => const ItemFormDialog());
            if (saved == true) ref.invalidate(suiteItemsProvider);
          },
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.qr_code_scanner), hintText: l10n.suiteSearchOrScan, isDense: true),
                        onSubmitted: (text) {
                          final t = text.trim();
                          // a scanner sends digits only: try it as a barcode, a person types a name
                          final isCode = RegExp(r'^\d{6,}$').hasMatch(t);
                          _query(search: isCode ? '' : t, barcode: isCode ? t : null);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(label: Text(l10n.stkBelowReorder), selected: query.below, onSelected: (v) => _query(below: v)),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.valueOrNull?.groups.isNotEmpty ?? false)
                  Wrap(
                    spacing: 6,
                    children: [
                      ChoiceChip(label: Text(l10n.suiteAll), selected: query.group == null, onSelected: (_) => _query(clearGroup: true)),
                      for (final g in data.valueOrNull!.groups) ChoiceChip(label: Text(g), selected: query.group == g, onSelected: (_) => _query(group: g)),
                    ],
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: AsyncValueView(
                    value: data,
                    onRetry: () => ref.invalidate(suiteItemsProvider),
                    builder: (context, d) => d.items.isEmpty
                        ? Center(child: Text(l10n.stkNoItems))
                        : SingleChildScrollView(
                            child: DataTable(
                              showCheckboxColumn: false,
                              columns: [
                                DataColumn(label: Text(l10n.suiteItem)),
                                DataColumn(label: Text(l10n.suiteOnHand)),
                                DataColumn(label: Text(l10n.suiteReorderLevel)),
                                DataColumn(label: Text(l10n.suiteAvgCost)),
                                DataColumn(label: Text(l10n.suiteValue)),
                              ],
                              rows: [
                                for (final i in d.items)
                                  DataRow(
                                    selected: selected == i.id,
                                    onSelectChanged: (_) => ref.read(_selectedItemProvider.notifier).state = i.id,
                                    cells: [
                                      DataCell(Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [Text(i.nameAr, style: const TextStyle(fontWeight: FontWeight.w700)), if (i.groupName != null) Text(i.groupName!, style: Theme.of(context).textTheme.bodySmall)],
                                      )),
                                      DataCell(Text(i.onHandDisplay, style: TextStyle(color: i.belowReorder ? Tone.bad(context) : null, fontWeight: FontWeight.w700))),
                                      DataCell(Text(i.reorderLevel == null ? '—' : '${invNum(i.reorderLevel!)} ${i.baseUnit}')),
                                      DataCell(Text('${InvLabels.money(i.avgCost)} / ${i.baseUnit}')),
                                      DataCell(Text(InvLabels.money(i.value))),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: selected == null ? Center(child: Text(l10n.suitePickItem)) : _ItemPanel(itemId: selected)),
        ],
      ),
    );
  }
}

class _ItemPanel extends ConsumerWidget {
  final int itemId;
  const _ItemPanel({required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final data = ref.watch(invItemProvider(itemId));
    final ledger = ref.watch(_ledgerProvider(itemId));
    final settings = ref.watch(invSettingsProvider).valueOrNull;

    void refresh() {
      ref.invalidate(invItemProvider(itemId));
      ref.invalidate(_ledgerProvider(itemId));
      ref.invalidate(suiteItemsProvider);
    }

    return Card(
      child: AsyncValueView(
        value: data,
        onRetry: refresh,
        builder: (context, d) {
          final item = d.item;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(item.groupName ?? '', style: Theme.of(context).textTheme.bodySmall),
              Text(item.nameAr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text('${invNum(item.onHand)} ${item.baseUnit}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Tone.good(context))),
              Text(item.onHandDisplay),
              if (d.coverage?.daysLeft != null) Text(l10n.stkDaysLeft(invNum(d.coverage!.daysLeft!))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Chip(label: Text('${item.baseUnit} (${l10n.suiteBaseUnit})')),
                  for (final u in item.units) Chip(label: Text('${u.name} = ${invNum(u.factor)} ${item.baseUnit}')),
                  if (item.barcode != null) Chip(avatar: const Icon(Icons.qr_code, size: 16), label: Text(item.barcode!)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(context: context, builder: (_) => ItemFormDialog(item: item));
                      if (ok == true) refresh();
                    },
                    child: Text(l10n.suiteEdit),
                  ),
                  OutlinedButton(onPressed: () => _move(context, ref, item, 'opening', refresh), child: Text(l10n.suiteAddOpening)),
                  if (settings?.has('waste') ?? false)
                    OutlinedButton(onPressed: () => _move(context, ref, item, 'waste', refresh), child: Text(l10n.stkRecordWaste)),
                  if (settings?.has('multi_warehouse') ?? false)
                    OutlinedButton(onPressed: () => _move(context, ref, item, 'transfer', refresh), child: Text(l10n.suiteTransfer)),
                ],
              ),
              const Divider(height: 28),
              Text(l10n.suiteLedger, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(l10n.suiteLedgerHint, style: Theme.of(context).textTheme.bodySmall),
              AsyncValueView<List<InvMove>>(
                value: ledger,
                builder: (context, moves) => DataTable(
                  columnSpacing: 16,
                  columns: [
                    DataColumn(label: Text(l10n.suiteWhen)),
                    DataColumn(label: Text(l10n.suiteMove)),
                    DataColumn(label: Text(l10n.suiteQty)),
                    DataColumn(label: Text(l10n.suiteBalanceAfter)),
                  ],
                  rows: [
                    for (final m in moves)
                      DataRow(cells: [
                        DataCell(Text(m.occurredAt == null ? '' : MaterialLocalizations.of(context).formatShortDate(m.occurredAt!))),
                        DataCell(Text(InvLabels.moveType(l10n, m.type) + (m.referenceId != null ? ' #${m.referenceId}' : ''))),
                        DataCell(Text('${m.qty > 0 ? '+' : ''}${invNum(m.qty)}',
                            style: TextStyle(fontWeight: FontWeight.w800, color: m.qty >= 0 ? Tone.good(context) : Tone.bad(context)))),
                        DataCell(Text(m.balanceAfter == null ? '' : invNum(m.balanceAfter!))),
                      ]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _move(BuildContext context, WidgetRef ref, InvItem item, String kind, VoidCallback refresh) async {
    final l10n = AppLocalizations.of(context)!;
    final qty = TextEditingController();
    final cost = TextEditingController();
    final reason = TextEditingController();
    int? toWarehouse;
    final warehouses = kind == 'transfer' ? await ref.read(inventoryApiProvider).warehouses() : const <InvWarehouse>[];
    if (!context.mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(switch (kind) { 'opening' => l10n.suiteAddOpening, 'waste' => l10n.stkRecordWaste, _ => l10n.suiteTransfer }),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumField(controller: qty, label: l10n.stkQtyIn(item.baseUnit), width: 260),
              if (kind == 'opening') NumField(controller: cost, label: l10n.suiteUnitCost, width: 260),
              if (kind == 'waste') TextField(controller: reason, decoration: InputDecoration(labelText: l10n.stkReason)),
              if (kind == 'transfer')
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: l10n.suiteToWarehouse),
                  items: [for (final w in warehouses.where((w) => !w.isDefault)) DropdownMenuItem(value: w.id, child: Text(w.name))],
                  onChanged: (v) => setState(() => toWarehouse = v),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
          ],
        ),
      ),
    );

    final q = parseNum(qty.text);
    qty.dispose();
    if (ok != true || q == null || q <= 0 || !context.mounted) return;
    await suiteRun(context, () => ref.read(inventoryApiProvider).move({
          'kind': kind,
          'item_id': item.id,
          'qty': q,
          if (kind == 'opening') 'unit_cost': parseNum(cost.text) ?? 0,
          if (kind == 'waste' && reason.text.trim().isNotEmpty) 'reason': reason.text.trim(),
          if (kind == 'transfer') 'to_warehouse_id': toWarehouse,
        }));
    cost.dispose();
    reason.dispose();
    refresh();
  }
}

/// New / edit stock item: one base unit for everything, bigger units as factors over it (كرتونة = 24، بالتة = 1920).
class ItemFormDialog extends ConsumerStatefulWidget {
  final InvItem? item;
  const ItemFormDialog({super.key, this.item});

  @override
  ConsumerState<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends ConsumerState<ItemFormDialog> {
  late final _name = TextEditingController(text: widget.item?.nameAr);
  late final _nameEn = TextEditingController(text: widget.item?.nameEn);
  late final _group = TextEditingController(text: widget.item?.groupName);
  late final _base = TextEditingController(text: widget.item?.baseUnit);
  late final _barcode = TextEditingController(text: widget.item?.barcode);
  late final _reorder = TextEditingController(text: widget.item?.reorderLevel == null ? '' : invNum(widget.item!.reorderLevel!));
  final _openingQty = TextEditingController();
  final _openingCost = TextEditingController();
  late String _kind = widget.item?.unitKind ?? 'count';
  late final List<(TextEditingController, TextEditingController, TextEditingController)> _units = [
    for (final u in widget.item?.units ?? const <InvUnit>[])
      (TextEditingController(text: u.name), TextEditingController(text: invNum(u.factor)), TextEditingController(text: u.barcode)),
  ];
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _nameEn, _group, _base, _barcode, _reorder, _openingQty, _openingCost]) {
      c.dispose();
    }
    for (final u in _units) {
      u.$1.dispose();
      u.$2.dispose();
      u.$3.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _base.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final body = <String, dynamic>{
      'name_ar': _name.text.trim(),
      'name_en': _nameEn.text.trim().isEmpty ? null : _nameEn.text.trim(),
      'group_name': _group.text.trim().isEmpty ? null : _group.text.trim(),
      'base_unit': _base.text.trim(),
      'unit_kind': _kind,
      'barcode': _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      'reorder_level': parseNum(_reorder.text),
      'units': [
        for (final u in _units)
          if (u.$1.text.trim().isNotEmpty && (parseNum(u.$2.text) ?? 0) > 0)
            InvUnit(name: u.$1.text.trim(), factor: parseNum(u.$2.text)!, barcode: u.$3.text.trim()).toJson(),
      ],
      if (widget.item == null && (parseNum(_openingQty.text) ?? 0) > 0) ...{
        'opening_qty': parseNum(_openingQty.text),
        'opening_cost': parseNum(_openingCost.text) ?? 0,
      },
    };
    final api = ref.read(inventoryApiProvider);
    final item = widget.item;
    final done = await suiteRun(context, () async {
      if (item == null) {
        await api.createItem(body);
      } else {
        await api.updateItem(item.id, body);
      }
      return true;
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (done == true) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kinds = {'count': l10n.suiteKindCount, 'weight': l10n.suiteKindWeight, 'volume': l10n.suiteKindVolume, 'length': l10n.suiteKindLength};

    return AlertDialog(
      title: Text(widget.item == null ? l10n.suiteNewItem : l10n.suiteEdit),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _name, decoration: InputDecoration(labelText: l10n.suiteNameAr)),
              TextField(controller: _nameEn, decoration: InputDecoration(labelText: l10n.suiteNameEn)),
              TextField(controller: _group, decoration: InputDecoration(labelText: l10n.suiteGroup)),
              Row(
                children: [
                  Expanded(child: TextField(controller: _base, decoration: InputDecoration(labelText: l10n.suiteBaseUnitHint))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _kind,
                      decoration: InputDecoration(labelText: l10n.suiteUnitKind),
                      items: [for (final e in kinds.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                      onChanged: (v) => setState(() => _kind = v ?? 'count'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: _barcode, decoration: InputDecoration(labelText: l10n.suiteBarcode))),
                  const SizedBox(width: 12),
                  NumField(controller: _reorder, label: l10n.suiteReorderLevel, width: 160),
                ],
              ),
              const SizedBox(height: 12),
              Align(alignment: AlignmentDirectional.centerStart, child: Text(l10n.suitePurchaseUnits, style: const TextStyle(fontWeight: FontWeight.w800))),
              for (final u in _units)
                Row(
                  children: [
                    Expanded(child: TextField(controller: u.$1, decoration: InputDecoration(labelText: l10n.suiteUnitName, isDense: true))),
                    const SizedBox(width: 8),
                    NumField(controller: u.$2, label: l10n.suiteUnitFactor(_base.text)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: u.$3, decoration: InputDecoration(labelText: l10n.suiteBarcode, isDense: true))),
                  ],
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _units.add((TextEditingController(), TextEditingController(), TextEditingController()))),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.suiteAddUnit),
                ),
              ),
              if (widget.item == null)
                Row(
                  children: [
                    NumField(controller: _openingQty, label: l10n.suiteOpeningQty, width: 200),
                    const SizedBox(width: 12),
                    NumField(controller: _openingCost, label: l10n.suiteUnitCost, width: 200),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
