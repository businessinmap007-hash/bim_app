import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../desktop_app.dart';
import '../print/suite_print.dart';
import '../shell/desktop_shell.dart';
import 'common.dart';
import 'items_page.dart';
import 'receive_page.dart';

final _ordersProvider = FutureProvider.autoDispose<List<InvPurchaseOrder>>((ref) => ref.watch(inventoryApiProvider).purchaseOrders());
final suiteSuppliersProvider = FutureProvider.autoDispose<List<InvSupplier>>((ref) => ref.watch(inventoryApiProvider).suppliers());
final _selectedOrderProvider = StateProvider.autoDispose<int?>((ref) => null);

/// «المشتريات» — purchase orders (the owner approves above his limit, from here or his phone), the supplier's bill
/// matched three ways, payments RECORDED only — and the suppliers with what is owed to each.
class PurchasesPage extends ConsumerWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: SuitePage(
        title: l10n.suiteNavPurchases,
        scroll: false,
        actions: [
          OutlinedButton.icon(icon: const Icon(Icons.person_add_alt), label: Text(l10n.suiteNewSupplier), onPressed: () => _newSupplier(context, ref)),
          FilledButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(l10n.suiteNewOrder),
            onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => const _OrderDialog());
              if (ok == true) ref.invalidate(_ordersProvider);
            },
          ),
        ],
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: l10n.suiteOrders),
                Tab(text: l10n.suiteSuppliers),
              ],
            ),
            const Expanded(child: TabBarView(children: [_OrdersTab(), _SuppliersTab()])),
          ],
        ),
      ),
    );
  }

  Future<void> _newSupplier(BuildContext context, WidgetRef ref) async {
    final picked = await showDialog<({String name, String? phone, int? linkedBusinessId})>(context: context, builder: (_) => const _SupplierDialog());
    if (picked == null || !context.mounted) return;
    await suiteRun(context, () => ref.read(inventoryApiProvider).createSupplier(name: picked.name, phone: picked.phone, linkedBusinessId: picked.linkedBusinessId));
    ref.invalidate(suiteSuppliersProvider);
  }
}

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final orders = ref.watch(_ordersProvider);
    final selected = ref.watch(_selectedOrderProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: AsyncValueView<List<InvPurchaseOrder>>(
            value: orders,
            onRetry: () => ref.invalidate(_ordersProvider),
            builder: (context, rows) => ListView(
              children: [
                for (final po in rows)
                  ListTile(
                    selected: selected == po.id,
                    title: Text('#${po.number} · ${po.supplier?.name ?? ''}'),
                    subtitle: Text('${InvLabels.poStatus(l10n, po.status)} · ${InvLabels.money(po.total)} ${l10n.stkCurrency}'),
                    onTap: () => ref.read(_selectedOrderProvider.notifier).state = po.id,
                  ),
              ],
            ),
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: selected == null ? Center(child: Text(l10n.suitePickOrder)) : _OrderDetail(orderId: selected),
        ),
      ],
    );
  }
}

class _OrderDetail extends ConsumerWidget {
  final int orderId;
  const _OrderDetail({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detail = ref.watch(invPurchaseOrderProvider(orderId));

    void refresh() {
      ref.invalidate(invPurchaseOrderProvider(orderId));
      ref.invalidate(_ordersProvider);
    }

    Future<void> act(String action, {String? reason}) async {
      await suiteRun(context, () => ref.read(inventoryApiProvider).purchaseOrderAction(orderId, action, reason: reason), queueable: false);
      refresh();
    }

    return AsyncValueView<InvPurchaseOrderDetail>(
      value: detail,
      onRetry: refresh,
      builder: (context, d) {
        final po = d.order;
        final steps = ['draft', 'pending_approval', 'approved', 'partially_received', 'received', 'closed'];
        final at = steps.indexOf(po.status);

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Text(l10n.stkPurchaseOrderNo(po.number), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < steps.length; i++)
                  Chip(
                    label: Text(InvLabels.poStatus(l10n, steps[i])),
                    backgroundColor: i < at ? const Color(0xFFE7F3EC) : (i == at ? const Color(0xFF0B1F3A) : null),
                    labelStyle: TextStyle(color: i == at ? Colors.white : (i < at ? const Color(0xFF1F7A44) : null)),
                  ),
                if (at < 0) Chip(label: Text(InvLabels.poStatus(l10n, po.status))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SuiteSection(
                    title: l10n.suiteSupplier,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(po.supplier?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
                        if (po.supplier?.onBim == true) Text(po.supplierConfirmedAt != null ? l10n.suiteSupplierConfirmed : l10n.stkOnBim),
                        if (po.rejectedReason != null) Text('${l10n.stkReject}: ${po.rejectedReason}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SuiteSection(
              title: l10n.suiteLines,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.suiteItem)),
                  DataColumn(label: Text(l10n.suiteUnit)),
                  DataColumn(label: Text(l10n.suiteOrdered)),
                  DataColumn(label: Text(l10n.suitePrice)),
                  DataColumn(label: Text(l10n.stkTotal)),
                  DataColumn(label: Text(l10n.suiteReceived)),
                  DataColumn(label: Text(l10n.suiteBilled)),
                ],
                rows: [
                  for (final l in po.lines)
                    DataRow(
                      cells: [
                        DataCell(Text(l.itemName ?? '')),
                        DataCell(Text(l.unitName)),
                        DataCell(Text(invNum(l.qty))),
                        DataCell(Text(InvLabels.money(l.unitPrice))),
                        DataCell(Text(InvLabels.money(l.total))),
                        DataCell(
                          Text(
                            '${invNum(l.receivedQty)} / ${invNum(l.qty)}',
                            style: TextStyle(color: l.receivedQty + 0.0001 >= l.qty ? Tone.good(context) : Tone.warn(context), fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataCell(Text(invNum(l.billedQty))),
                      ],
                    ),
                ],
              ),
            ),
            if (!d.matched)
              Card(
                color: const Color(0xFFF9E4DF),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.suiteMatchProblem,
                        style: TextStyle(color: Tone.bad(context), fontWeight: FontWeight.w800),
                      ),
                      for (final m in d.match.where((m) => m.issues.isNotEmpty))
                        Text(
                          '${po.lines.where((l) => l.id == m.poLineId).firstOrNull?.itemName ?? ''}: '
                          '${m.issues.map((i) => i == 'price_differs' ? l10n.suitePriceDiffers : l10n.suiteBilledMore).join('، ')} '
                          '(${InvLabels.money(m.differenceValue)})',
                          style: TextStyle(color: Tone.bad(context)),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.print_outlined),
                  label: Text(l10n.suitePrint),
                  onPressed: () async {
                    final pdf = await SuitePrint.document(
                      businessName: ref.read(suiteBusinessProvider)?.name ?? '',
                      title: l10n.stkPurchaseOrderNo(po.number),
                      facts: [
                        (l10n.suiteSupplier, po.supplier?.name ?? ''),
                        (l10n.suiteWhen, po.createdAt == null ? '' : MaterialLocalizations.of(context).formatMediumDate(po.createdAt!)),
                        (l10n.suiteStatus, InvLabels.poStatus(l10n, po.status)),
                      ],
                      headers: [l10n.suiteItem, l10n.suiteUnit, l10n.suiteQty, l10n.suiteUnitPrice, l10n.stkTotal],
                      rows: SuitePrint.orderRows(po),
                      totalLabel: l10n.stkTotal,
                      total: '${InvLabels.money(po.total)} ${l10n.stkCurrency}',
                      notes: po.notes,
                      signatures: [l10n.suiteSignPreparedBy, l10n.suiteSignApprovedBy, l10n.suiteSignSupplier],
                    );
                    await ref.read(suitePrintProvider).print(pdf, receipt: false, name: 'purchase-order-${po.number}');
                  },
                ),
                if (po.status == 'draft') FilledButton(onPressed: () => act('submit'), child: Text(l10n.suiteSubmit)),
                if (po.status == 'pending_approval' && d.canApprove) ...[
                  FilledButton(onPressed: () => act('approve'), child: Text(l10n.stkApproveAndSend)),
                  OutlinedButton(onPressed: () => act('reject'), child: Text(l10n.stkReject)),
                ],
                if (po.status == 'approved' || po.status == 'partially_received')
                  FilledButton.icon(
                    icon: const Icon(Icons.move_to_inbox_outlined),
                    label: Text(l10n.suiteReceiveNow),
                    onPressed: () {
                      ref.read(receiveOrderProvider.notifier).state = po.id;
                      ref.read(currentScreenProvider.notifier).state = SuiteScreen.receive;
                    },
                  ),
                if (['approved', 'partially_received', 'received'].contains(po.status) && po.supplier != null)
                  OutlinedButton(onPressed: () => _bill(context, ref, po, refresh), child: Text(l10n.suiteRecordBill)),
                if (po.supplier != null) OutlinedButton(onPressed: () => _pay(context, ref, po.supplier!), child: Text(l10n.suiteRecordPayment)),
                if (['draft', 'pending_approval', 'approved'].contains(po.status) && po.lines.every((l) => l.receivedQty == 0))
                  TextButton(onPressed: () => act('cancel'), child: Text(l10n.commonCancel)),
                if (po.status == 'partially_received' || po.status == 'received') TextButton(onPressed: () => act('close'), child: Text(l10n.suiteClose)),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _bill(BuildContext context, WidgetRef ref, InvPurchaseOrder po, VoidCallback refresh) async {
    final l10n = AppLocalizations.of(context)!;
    final number = TextEditingController();
    final qtys = {for (final l in po.lines) l.id: TextEditingController(text: invNum(l.receivedQty - l.billedQty < 0 ? 0 : l.receivedQty - l.billedQty))};
    final prices = {for (final l in po.lines) l.id: TextEditingController(text: invNum(l.unitPrice))};
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.suiteRecordBill),
        content: SizedBox(
          width: 520,
          child: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: number,
                decoration: InputDecoration(labelText: l10n.suiteBillNumber),
              ),
              for (final l in po.lines)
                Row(
                  children: [
                    Expanded(child: Text(l.itemName ?? '')),
                    NumField(controller: qtys[l.id]!, label: l10n.suiteBilled),
                    const SizedBox(width: 8),
                    NumField(controller: prices[l.id]!, label: l10n.suitePrice),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await suiteRun(
        context,
        () => ref
            .read(inventoryApiProvider)
            .recordBill(
              supplierId: po.supplier!.id,
              purchaseOrderId: po.id,
              number: number.text.trim().isEmpty ? null : number.text.trim(),
              lines: [
                for (final l in po.lines)
                  if ((parseNum(qtys[l.id]!.text) ?? 0) > 0) {'po_line_id': l.id, 'qty': parseNum(qtys[l.id]!.text), 'unit_price': parseNum(prices[l.id]!.text)},
              ],
            ),
      );
      refresh();
    }
    number.dispose();
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, InvSupplier supplier) async {
    final l10n = AppLocalizations.of(context)!;
    final amount = TextEditingController();
    final note = TextEditingController();
    var method = 'cash';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.suiteRecordPayment),
          content: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.suitePaymentOutsideHint, style: Theme.of(ctx).textTheme.bodySmall),
              NumField(controller: amount, label: l10n.suiteAmount, width: 260),
              DropdownButtonFormField<String>(
                initialValue: method,
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(l10n.suiteCash)),
                  DropdownMenuItem(value: 'transfer', child: Text(l10n.suiteTransferMoney)),
                  DropdownMenuItem(value: 'cheque', child: Text(l10n.suiteCheque)),
                ],
                onChanged: (v) => setState(() => method = v ?? 'cash'),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: l10n.suiteNote),
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
    final value = parseNum(amount.text);
    if (ok == true && value != null && value > 0 && context.mounted) {
      await suiteRun(context, () => ref.read(inventoryApiProvider).recordPayment(supplierId: supplier.id, amount: value, method: method, note: note.text.trim().isEmpty ? null : note.text.trim()));
      ref.invalidate(suiteSuppliersProvider);
    }
    amount.dispose();
    note.dispose();
  }
}

class _SuppliersTab extends ConsumerWidget {
  const _SuppliersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AsyncValueView<List<InvSupplier>>(
      value: ref.watch(suiteSuppliersProvider),
      onRetry: () => ref.invalidate(suiteSuppliersProvider),
      builder: (context, rows) => SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text(l10n.suiteSupplierName)),
            DataColumn(label: Text(l10n.suitePhone)),
            DataColumn(label: Text(l10n.stkOnBim)),
            DataColumn(label: Text(l10n.suiteBalance)),
          ],
          rows: [
            for (final s in rows)
              DataRow(
                cells: [
                  DataCell(Text(s.name)),
                  DataCell(Text(s.phone ?? '')),
                  DataCell(Text(s.onBim ? (s.linkedBusinessName ?? '✓') : '—')),
                  DataCell(
                    Text(
                      InvLabels.money(s.balance ?? 0),
                      style: TextStyle(color: (s.balance ?? 0) > 0 ? Tone.bad(context) : null, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// New purchase order: a supplier, then lines in the item's purchase units (كرتونة، جركن…) at the supplier's price.
class _OrderDialog extends ConsumerStatefulWidget {
  const _OrderDialog();

  @override
  ConsumerState<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends ConsumerState<_OrderDialog> {
  int? _supplier;
  final _notes = TextEditingController();
  final List<({int? item, InvUnit? unit, TextEditingController qty, TextEditingController price})> _lines = [];

  @override
  void initState() {
    super.initState();
    _addLine();
  }

  void _addLine() {
    void recount() {
      if (mounted) setState(() {});
    }

    _lines.add((item: null, unit: null, qty: TextEditingController()..addListener(recount), price: TextEditingController()..addListener(recount)));
  }

  @override
  void dispose() {
    _notes.dispose();
    for (final l in _lines) {
      l.qty.dispose();
      l.price.dispose();
    }
    super.dispose();
  }

  Future<void> _save(bool submit) async {
    if (_supplier == null) return;
    final items = ref.read(suiteItemsProvider).valueOrNull?.items ?? const <InvItem>[];
    final lines = [
      for (final l in _lines)
        if (l.item != null && (parseNum(l.qty.text) ?? 0) > 0)
          {
            'item_id': l.item,
            'unit_name': l.unit?.name ?? items.firstWhere((i) => i.id == l.item).baseUnit,
            'unit_factor': l.unit?.factor ?? 1,
            'qty': parseNum(l.qty.text),
            'unit_price': parseNum(l.price.text) ?? 0,
          },
    ];
    if (lines.isEmpty) return;
    await suiteRun(
      context,
      () => ref.read(inventoryApiProvider).createPurchaseOrder(supplierId: _supplier!, lines: lines, submit: submit, notes: _notes.text.trim().isEmpty ? null : _notes.text.trim()),
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final suppliers = ref.watch(suiteSuppliersProvider).valueOrNull ?? const <InvSupplier>[];
    final items = ref.watch(suiteItemsProvider).valueOrNull?.items ?? const <InvItem>[];
    var total = 0.0;
    for (final l in _lines) {
      total += (parseNum(l.qty.text) ?? 0) * (parseNum(l.price.text) ?? 0);
    }

    return AlertDialog(
      title: Text(l10n.suiteNewOrder),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _supplier,
                decoration: InputDecoration(labelText: l10n.suiteSupplier),
                items: [for (final s in suppliers) DropdownMenuItem(value: s.id, child: Text(s.onBim ? '${s.name} (${l10n.stkOnBim})' : s.name))],
                onChanged: (v) => setState(() => _supplier = v),
              ),
              for (var i = 0; i < _lines.length; i++)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        initialValue: _lines[i].item,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l10n.suiteItem, isDense: true),
                        items: [for (final it in items) DropdownMenuItem(value: it.id, child: Text(it.nameAr))],
                        onChanged: (v) => setState(() => _lines[i] = (item: v, unit: null, qty: _lines[i].qty, price: _lines[i].price)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<InvUnit?>(
                        initialValue: _lines[i].unit,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l10n.suiteUnit, isDense: true),
                        items: [
                          DropdownMenuItem<InvUnit?>(value: null, child: Text(items.where((it) => it.id == _lines[i].item).firstOrNull?.baseUnit ?? '—')),
                          for (final u in items.where((it) => it.id == _lines[i].item).firstOrNull?.units ?? const <InvUnit>[]) DropdownMenuItem<InvUnit?>(value: u, child: Text(u.name)),
                        ],
                        onChanged: (v) => setState(() => _lines[i] = (item: _lines[i].item, unit: v, qty: _lines[i].qty, price: _lines[i].price)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    NumField(controller: _lines[i].qty, label: l10n.suiteQty),
                    const SizedBox(width: 8),
                    NumField(controller: _lines[i].price, label: l10n.suiteUnitPrice),
                  ],
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(onPressed: () => setState(_addLine), icon: const Icon(Icons.add), label: Text(l10n.suiteAddLine)),
              ),
              TextField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.suiteNote),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text('${l10n.stkTotal}: ${InvLabels.money(total)} ${l10n.stkCurrency}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        OutlinedButton(onPressed: () => _save(false), child: Text(l10n.suiteSaveDraft)),
        FilledButton(onPressed: () => _save(true), child: Text(l10n.suiteSubmit)),
      ],
    );
  }
}

/// «مورد جديد»: a business on BIM found by its name, trade or city (its purchase orders then reach it in its app), or
/// a supplier outside the app typed in by name and phone.
class _SupplierDialog extends ConsumerStatefulWidget {
  const _SupplierDialog();

  @override
  ConsumerState<_SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends ConsumerState<_SupplierDialog> {
  final _q = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _onBim = true;
  bool _myCity = false;
  bool _loading = false;
  List<InvSupplierCandidate> _found = const [];
  InvSupplierCandidate? _chosen;

  @override
  void dispose() {
    for (final c in [_q, _name, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final rows = await ref.read(inventoryApiProvider).supplierCandidates(q: _q.text, myCity: _myCity);
      if (mounted) setState(() => _found = rows);
    } catch (_) {
      if (mounted) setState(() => _found = const []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chosen = _chosen;

    return AlertDialog(
      title: Text(l10n.suiteNewSupplier),
      content: SizedBox(
        width: 520,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, icon: const Icon(Icons.storefront_outlined), label: Text(l10n.suiteSupplierOnBim)),
                ButtonSegment(value: false, icon: const Icon(Icons.person_outline), label: Text(l10n.suiteSupplierOffApp)),
              ],
              selected: {_onBim},
              onSelectionChanged: (v) => setState(() => _onBim = v.first),
            ),
            const SizedBox(height: 12),
            if (_onBim) ...[
              TextField(
                controller: _q,
                autofocus: true,
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.suiteSupplierSearchHint, isDense: true),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _myCity,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(l10n.suiteSupplierMyCity),
                onChanged: (v) {
                  setState(() => _myCity = v ?? false);
                  _search();
                },
              ),
              Text(l10n.suiteLinkedBusinessHint, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _found.isEmpty
                    ? Center(child: Text(l10n.suiteSupplierSearchEmpty, textAlign: TextAlign.center))
                    : ListView(
                        children: [
                          for (final b in _found)
                            ListTile(
                              selected: chosen?.id == b.id,
                              enabled: b.supplierId == null,
                              leading: CircleAvatar(child: Text(b.name.isEmpty ? '?' : b.name.characters.first)),
                              title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text([if (b.trade != null) b.trade!, if (b.place != null) b.place!, if (b.supplierId != null) l10n.suiteSupplierAlready].join(' · ')),
                              trailing: chosen?.id == b.id ? const Icon(Icons.check_circle) : null,
                              onTap: () => setState(() => _chosen = b),
                            ),
                        ],
                      ),
              ),
            ] else ...[
              TextField(
                controller: _name,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.suiteSupplierName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.suitePhone),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: _onBim
              ? (chosen == null ? null : () => Navigator.pop(context, (name: chosen.name, phone: null, linkedBusinessId: chosen.id)))
              : () {
                  if (_name.text.trim().isEmpty) return;
                  Navigator.pop(context, (name: _name.text.trim(), phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(), linkedBusinessId: null));
                },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
