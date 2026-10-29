import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/inventory_providers.dart';
import '../../data/inventory_models.dart';
import '../inventory_labels.dart';

/// «المخزون» on the owner's phone (owner, 2026-10-29): the stock the desktop app keeps, live — «يكفي مبيعات اليوم؟»
/// for every item, worst first, and the purchase orders waiting for his approval. The heavy work (receiving, counting,
/// the cashier) lives on the computer; a small business with no computer can still switch the suite on from here.
class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(invSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stkTitle)),
      body: AsyncValueView<InvSettings>(
        value: settings,
        onRetry: () => ref.invalidate(invSettingsProvider),
        builder: (context, s) {
          if (!s.available) return _Note(text: l10n.stkNotAvailable);
          if (!s.enabled) return _EnableCard(settings: s);
          return const _StockBody();
        },
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  const _Note({required this.text});

  @override
  Widget build(BuildContext context) =>
      Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(text, textAlign: TextAlign.center)));
}

class _EnableCard extends ConsumerStatefulWidget {
  final InvSettings settings;
  const _EnableCard({required this.settings});

  @override
  ConsumerState<_EnableCard> createState() => _EnableCardState();
}

class _EnableCardState extends ConsumerState<_EnableCard> {
  bool _busy = false;

  Future<void> _enable() async {
    setState(() => _busy = true);
    try {
      await ref.read(inventoryApiProvider).updateSettings(enabled: true);
      ref.invalidate(invSettingsProvider);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.settings;
    final price = s.subscription.price;

    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.stkEnableTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.stkEnableBody),
                  const SizedBox(height: 8),
                  Text(price > 0 ? l10n.stkSubscriptionPrice(InvLabels.money(price)) : l10n.stkSubscriptionFree),
                  const SizedBox(height: 16),
                  if (s.isOwner)
                    FilledButton(onPressed: _busy ? null : _enable, child: Text(l10n.stkEnableAction))
                  else
                    Text(l10n.stkOwnerEnables),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockBody extends ConsumerWidget {
  const _StockBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dashboard = ref.watch(invDashboardProvider);
    final coverage = ref.watch(invCoverageProvider);
    final pending = ref.watch(invPendingApprovalsProvider);

    Future<void> refresh() async {
      ref.invalidate(invDashboardProvider);
      ref.invalidate(invCoverageProvider);
      ref.invalidate(invPendingApprovalsProvider);
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (dashboard.valueOrNull case final d?)
              Row(
                children: [
                  Expanded(child: _Stat(label: l10n.stkStockValue, value: '${InvLabels.money(d.summary.stockValue)} ${l10n.stkCurrency}')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Stat(label: l10n.stkBelowReorder, value: '${d.summary.belowReorder}', alert: d.summary.belowReorder > 0),
                  ),
                ],
              ),
            for (final po in pending.valueOrNull ?? const <InvPurchaseOrder>[])
              Card(
                color: const Color(0xFFF4EBD6),
                child: ListTile(
                  title: Text(l10n.stkPendingApproval(po.number), style: const TextStyle(color: Color(0xFF5E440E), fontWeight: FontWeight.w700)),
                  subtitle: Text('${po.supplier?.name ?? ''} · ${InvLabels.money(po.total)} ${l10n.stkCurrency}', style: const TextStyle(color: Color(0xFF5E440E))),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF5E440E)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PurchaseApprovalScreen(orderId: po.id))),
                ),
              ),
            const SizedBox(height: 12),
            Text(l10n.stkCoversToday, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AsyncValueView<List<InvCoverage>>(
              value: coverage,
              onRetry: () => ref.invalidate(invCoverageProvider),
              builder: (context, rows) => rows.isEmpty
                  ? _Note(text: l10n.stkNoItems)
                  : Column(children: [for (final r in rows) _CoverageTile(row: r)]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool alert;
  const _Stat({required this.label, required this.value, this.alert = false});

  @override
  Widget build(BuildContext context) {
    final fg = alert ? const Color(0xFFB93A22) : null;
    return Card(
      color: alert ? const Color(0xFFF9E4DF) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: fg)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
          ],
        ),
      ),
    );
  }
}

class _CoverageTile extends StatelessWidget {
  final InvCoverage row;
  const _CoverageTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (bg, fg) = InvLabels.verdictColors(row.verdict);
    final need = row.expectedRestOfToday;
    final ratio = need <= 0 ? 1.0 : (row.onHand / need).clamp(0.0, 1.0).toDouble();
    final detail = row.daysLeft != null
        ? l10n.stkCoverageLine(invNum(row.onHand), row.baseUnit, invNum(row.daysLeft!))
        : '${invNum(row.onHand)} ${row.baseUnit}';

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StockItemScreen(itemId: row.itemId))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(row.name, style: const TextStyle(fontWeight: FontWeight.w800))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                    child: Text(InvLabels.verdict(l10n, row.verdict), style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(value: ratio, minHeight: 6, color: fg, backgroundColor: const Color(0xFFEEEAE0)),
              ),
              const SizedBox(height: 6),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// One item on the phone: its balance in the biggest units, the answer to «يكفي اليوم؟» with its arithmetic, and the
/// last moves. Waste can be booked from here (it is the one quick thing a manager on the floor needs).
class StockItemScreen extends ConsumerWidget {
  final int itemId;
  const StockItemScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final data = ref.watch(invItemProvider(itemId));
    final settings = ref.watch(invSettingsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(data.valueOrNull?.item.nameAr ?? l10n.stkTitle)),
      body: AsyncValueView(
        value: data,
        onRetry: () => ref.invalidate(invItemProvider(itemId)),
        builder: (context, d) {
          final c = d.coverage;
          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.stkOnHandNow, style: Theme.of(context).textTheme.bodySmall),
                        Text('${invNum(d.item.onHand)} ${d.item.baseUnit}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                        if (d.item.units.isNotEmpty) Text(d.item.onHandDisplay),
                      ],
                    ),
                  ),
                ),
                if (c != null)
                  Card(
                    color: InvLabels.verdictColors(c.verdict).$1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.stkCoversToday} ${InvLabels.verdict(l10n, c.verdict)}',
                              style: TextStyle(fontWeight: FontWeight.w800, color: InvLabels.verdictColors(c.verdict).$2)),
                          const SizedBox(height: 6),
                          Text(l10n.stkCoverageExplain(invNum(c.usedToday), invNum(c.weekdayAverage), invNum(c.expectedRestOfToday), c.baseUnit)),
                          if (c.daysLeft != null) Text(l10n.stkDaysLeft(invNum(c.daysLeft!))),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(l10n.stkRecentMoves, style: Theme.of(context).textTheme.titleMedium),
                for (final m in d.moves.take(20))
                  ListTile(
                    dense: true,
                    title: Text(InvLabels.moveType(l10n, m.type) + (m.reason != null ? ' — ${m.reason}' : '')),
                    subtitle: Text(m.occurredAt == null ? '' : MaterialLocalizations.of(context).formatShortDate(m.occurredAt!)),
                    trailing: Text(
                      '${m.qty > 0 ? '+' : ''}${invNum(m.qty)}',
                      style: TextStyle(fontWeight: FontWeight.w800, color: m.qty >= 0 ? const Color(0xFF1F7A44) : const Color(0xFFB93A22)),
                    ),
                  ),
                if (settings != null && settings.has('waste') && settings.can('inventory'))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: Text(l10n.stkRecordWaste),
                      onPressed: () => _waste(context, ref, d.item),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _waste(BuildContext context, WidgetRef ref, InvItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<(double, String)>(context: context, builder: (_) => _WasteDialog(item: item));
    if (result == null) return;
    try {
      await ref.read(inventoryApiProvider).move({'kind': 'waste', 'item_id': item.id, 'qty': result.$1, 'reason': result.$2});
      ref.invalidate(invItemProvider(item.id));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.stkSaved)));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _WasteDialog extends StatefulWidget {
  final InvItem item;
  const _WasteDialog({required this.item});

  @override
  State<_WasteDialog> createState() => _WasteDialogState();
}

class _WasteDialogState extends State<_WasteDialog> {
  final _qty = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _qty.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.stkRecordWaste),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _qty,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.stkQtyIn(widget.item.baseUnit)),
          ),
          TextField(controller: _reason, decoration: InputDecoration(labelText: l10n.stkReason)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            final q = double.tryParse(_qty.text.trim());
            if (q == null || q <= 0) return;
            Navigator.pop(context, (q, _reason.text.trim()));
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// «اعتماد أمر شراء» — from the phone, above the limit the owner set.
class PurchaseApprovalScreen extends ConsumerStatefulWidget {
  final int orderId;
  const PurchaseApprovalScreen({super.key, required this.orderId});

  @override
  ConsumerState<PurchaseApprovalScreen> createState() => _PurchaseApprovalScreenState();
}

class _PurchaseApprovalScreenState extends ConsumerState<PurchaseApprovalScreen> {
  bool _busy = false;

  Future<void> _act(String action, {String? reason}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(inventoryApiProvider).purchaseOrderAction(widget.orderId, action, reason: reason);
      ref.invalidate(invPurchaseOrderProvider(widget.orderId));
      ref.invalidate(invPendingApprovalsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.stkSaved)));
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stkReject),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: l10n.stkReason)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: Text(l10n.stkReject)),
        ],
      ),
    );
    controller.dispose();
    if (reason != null) await _act('reject', reason: reason.isEmpty ? null : reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = ref.watch(invPurchaseOrderProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stkPurchaseOrderNo(detail.valueOrNull?.order.number ?? 0))),
      body: AsyncValueView<InvPurchaseOrderDetail>(
        value: detail,
        onRetry: () => ref.invalidate(invPurchaseOrderProvider(widget.orderId)),
        builder: (context, d) {
          final po = d.order;
          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text(po.supplier?.name ?? ''),
                    subtitle: Text(InvLabels.poStatus(l10n, po.status)),
                    trailing: po.supplier?.onBim == true ? Chip(label: Text(l10n.stkOnBim)) : null,
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (final l in po.lines)
                        ListTile(
                          title: Text(l.itemName ?? '#${l.itemId}'),
                          subtitle: Text('${invNum(l.qty)} × ${l.unitName} · ${InvLabels.money(l.unitPrice)}'),
                          trailing: Text(InvLabels.money(l.total)),
                        ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(l10n.stkTotal, style: const TextStyle(fontWeight: FontWeight.w800)),
                        trailing: Text('${InvLabels.money(po.total)} ${l10n.stkCurrency}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                if (po.status == 'pending_approval' && d.canApprove) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FilledButton(onPressed: _busy ? null : () => _act('approve'), child: Text(l10n.stkApproveAndSend)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton(onPressed: _busy ? null : _reject, child: Text(l10n.stkReject))),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The supplier's side: orders other businesses on BIM sent to this one, and its confirmation.
class IncomingPurchaseOrdersScreen extends ConsumerWidget {
  const IncomingPurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final orders = ref.watch(invIncomingOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stkIncomingTitle)),
      body: AsyncValueView<List<InvPurchaseOrder>>(
        value: orders,
        onRetry: () => ref.invalidate(invIncomingOrdersProvider),
        builder: (context, rows) => rows.isEmpty
            ? _Note(text: l10n.stkIncomingEmpty)
            : ResponsiveCenter(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final po in rows)
                      Card(
                        child: ExpansionTile(
                          title: Text('${l10n.stkPurchaseOrderNo(po.number)} · ${po.buyerName ?? ''}'),
                          subtitle: Text('${InvLabels.money(po.total)} ${l10n.stkCurrency} · ${InvLabels.poStatus(l10n, po.status)}'),
                          children: [
                            for (final l in po.lines)
                              ListTile(dense: true, title: Text(l.itemName ?? ''), trailing: Text('${invNum(l.qty)} × ${l.unitName}')),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: po.supplierConfirmedAt != null
                                  ? Text(l10n.stkConfirmed)
                                  : FilledButton(
                                      onPressed: () async {
                                        try {
                                          await ref.read(inventoryApiProvider).confirmIncoming(po.id);
                                          ref.invalidate(invIncomingOrdersProvider);
                                        } on ApiException catch (e) {
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                                        }
                                      },
                                      child: Text(l10n.stkConfirmOrder),
                                    ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
