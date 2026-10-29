import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../l10n/app_localizations.dart';
import '../sync/desktop_sync.dart';
import 'common.dart';
import 'items_page.dart';

/// The purchase order the «استلام» screen was opened for (set from the order's detail).
final receiveOrderProvider = StateProvider<int?>((ref) => null);

final _openOrdersProvider = FutureProvider.autoDispose<List<InvPurchaseOrder>>(
  (ref) => ref.watch(inventoryApiProvider).purchaseOrders(status: 'approved,partially_received'),
);

class _Line {
  final int? poLineId;
  final int itemId;
  final String name;
  final String unitName;
  final double unitFactor;
  final double? remaining;
  final List<String> barcodes;
  final qty = TextEditingController();
  final damaged = TextEditingController(text: '0');
  final price = TextEditingController();
  final lot = TextEditingController();
  final expiry = TextEditingController();

  _Line({this.poLineId, required this.itemId, required this.name, required this.unitName, required this.unitFactor, this.remaining, required this.barcodes, double? unitPrice}) {
    price.text = unitPrice == null ? '' : invNum(unitPrice);
  }

  void dispose() {
    for (final c in [qty, damaged, price, lot, expiry]) {
      c.dispose();
    }
  }
}

/// «استلام بضاعة» — against an approved order (whole or part) or without one. The barcode scanner types into the box at
/// the top: every scan adds one of that line's unit. The good part of each line enters the stock at its price; what came
/// damaged stays out and remains open on the order. Lot and expiry show only where the business keeps lots.
class ReceivePage extends ConsumerStatefulWidget {
  const ReceivePage({super.key});

  @override
  ConsumerState<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends ConsumerState<ReceivePage> {
  final _scan = TextEditingController();
  final _scanFocus = FocusNode();
  final List<_Line> _lines = [];
  int? _loadedFor = -1;
  bool _busy = false;

  @override
  void dispose() {
    _scan.dispose();
    _scanFocus.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  void _loadOrder(int? orderId, List<InvPurchaseOrder> orders, List<InvItem> items) {
    if (_loadedFor == orderId) return;
    _loadedFor = orderId;
    for (final l in _lines) {
      l.dispose();
    }
    _lines.clear();
    final po = orders.where((o) => o.id == orderId).firstOrNull;
    if (po == null) return;
    for (final l in po.lines.where((l) => l.remaining > 0)) {
      final item = items.where((i) => i.id == l.itemId).firstOrNull;
      _lines.add(_Line(
        poLineId: l.id,
        itemId: l.itemId,
        name: l.itemName ?? '',
        unitName: l.unitName,
        unitFactor: l.unitFactor,
        remaining: l.remaining,
        unitPrice: l.unitPrice,
        barcodes: [if (item?.barcode != null) item!.barcode!, ...?item?.units.map((u) => u.barcode).whereType<String>()],
      ));
    }
  }

  void _scanned(String code, List<InvItem> items) {
    final c = code.trim();
    _scan.clear();
    _scanFocus.requestFocus();
    if (c.isEmpty) return;

    var line = _lines.where((l) => l.barcodes.contains(c)).firstOrNull;
    if (line == null) {
      final item = items.where((i) => i.barcode == c || i.units.any((u) => u.barcode == c)).firstOrNull;
      if (item == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.suiteUnknownBarcode(c))));
        return;
      }
      final unit = item.units.where((u) => u.barcode == c).firstOrNull;
      line = _Line(
        itemId: item.id,
        name: item.nameAr,
        unitName: unit?.name ?? item.baseUnit,
        unitFactor: unit?.factor ?? 1,
        barcodes: [c],
        unitPrice: item.avgCost * (unit?.factor ?? 1),
      );
      _lines.add(line);
    }
    setState(() => line!.qty.text = invNum((parseNum(line.qty.text) ?? 0) + 1));
  }

  Future<void> _confirm(int? orderId, bool lots) async {
    final lines = [
      for (final l in _lines)
        if ((parseNum(l.qty.text) ?? 0) > 0)
          {
            'po_line_id': ?l.poLineId,
            'item_id': l.itemId,
            'unit_name': l.unitName,
            'unit_factor': l.unitFactor,
            'qty': parseNum(l.qty.text),
            'damaged_qty': parseNum(l.damaged.text) ?? 0,
            'unit_price': parseNum(l.price.text) ?? 0,
            if (lots && l.lot.text.trim().isNotEmpty) 'lot_code': l.lot.text.trim(),
            if (lots && l.expiry.text.trim().isNotEmpty) 'expires_on': l.expiry.text.trim(),
          },
    ];
    if (lines.isEmpty) return;
    setState(() => _busy = true);
    final store = ref.read(suiteStoreProvider);
    await suiteRun(context, () => ref.read(inventoryApiProvider).receive(purchaseOrderId: orderId, lines: lines, deviceUuid: store.deviceUuid));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _loadedFor = -1;
    });
    ref.invalidate(_openOrdersProvider);
    ref.invalidate(suiteItemsProvider);
    ref.read(receiveOrderProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = ref.watch(_openOrdersProvider).valueOrNull ?? const <InvPurchaseOrder>[];
    final items = ref.watch(suiteItemsProvider).valueOrNull?.items ?? const <InvItem>[];
    final orderId = ref.watch(receiveOrderProvider);
    final lots = ref.watch(invSettingsProvider).valueOrNull?.has('lots_expiry') ?? false;
    if (orders.isNotEmpty || orderId == null) _loadOrder(orderId, orders, items);

    return SuitePage(
      title: l10n.suiteNavReceive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int?>(
            initialValue: orderId,
            decoration: InputDecoration(labelText: l10n.suiteAgainstOrder),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(l10n.suiteNoOrder)),
              for (final o in orders) DropdownMenuItem<int?>(value: o.id, child: Text('#${o.number} · ${o.supplier?.name ?? ''}')),
            ],
            onChanged: (v) => ref.read(receiveOrderProvider.notifier).state = v,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(14)),
            child: TextField(
              controller: _scan,
              focusNode: _scanFocus,
              autofocus: true,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(filled: true, fillColor: Colors.white, prefixIcon: const Icon(Icons.qr_code_scanner), hintText: l10n.suiteScanToReceive),
              onSubmitted: (c) => _scanned(c, items),
            ),
          ),
          const SizedBox(height: 12),
          if (_lines.isEmpty)
            Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l10n.suiteReceiveEmpty)))
          else
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(l10n.suiteItem)),
                    DataColumn(label: Text(l10n.suiteRemaining)),
                    DataColumn(label: Text(l10n.suiteReceivedNow)),
                    DataColumn(label: Text(l10n.suiteDamaged)),
                    if (lots) DataColumn(label: Text(l10n.suiteLot)),
                    if (lots) DataColumn(label: Text(l10n.suiteExpiry)),
                    DataColumn(label: Text(l10n.suiteUnitPrice)),
                  ],
                  rows: [
                    for (final l in _lines)
                      DataRow(cells: [
                        DataCell(Text('${l.name}\n${l.unitName}')),
                        DataCell(Text(l.remaining == null ? '—' : invNum(l.remaining!))),
                        DataCell(SizedBox(width: 80, child: TextField(controller: l.qty, keyboardType: TextInputType.number))),
                        DataCell(SizedBox(width: 70, child: TextField(controller: l.damaged, keyboardType: TextInputType.number))),
                        if (lots) DataCell(SizedBox(width: 110, child: TextField(controller: l.lot))),
                        if (lots) DataCell(SizedBox(width: 120, child: TextField(controller: l.expiry, decoration: const InputDecoration(hintText: 'YYYY-MM-DD')))),
                        DataCell(SizedBox(width: 90, child: TextField(controller: l.price, keyboardType: TextInputType.number))),
                      ]),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(l10n.suiteReceiveNoEdit, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              icon: const Icon(Icons.check),
              label: Text(l10n.suiteConfirmReceipt),
              onPressed: _busy ? null : () => _confirm(orderId, lots),
            ),
          ),
        ],
      ),
    );
  }
}
