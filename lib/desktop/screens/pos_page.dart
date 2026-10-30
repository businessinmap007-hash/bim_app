import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../features/customers/data/customers_api.dart';
import '../../features/customers/presentation/crm_widgets.dart';
import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../desktop_app.dart';
import '../print/suite_print.dart';
import '../sync/desktop_sync.dart';
import 'common.dart';

final _catalogProvider = FutureProvider.autoDispose<List<InvPosProduct>>((ref) => ref.watch(inventoryApiProvider).posCatalog());

class _CartLine {
  final InvPosProduct product;
  final InvPosChoice? variant;
  final List<InvPosChoice> extras;
  double qty = 1;

  _CartLine({required this.product, this.variant, this.extras = const []});

  double get unitPrice => (variant?.price ?? product.price) + extras.fold(0.0, (s, e) => s + e.price);

  Map<String, dynamic> toJson() => {
    'owner_type': product.ownerType,
    'owner_id': product.ownerId,
    'qty': qty,
    'variant_id': ?variant?.id,
    if (extras.isNotEmpty)
      'extras': [
        for (final e in extras) {'id': e.id, 'qty': 1},
      ],
  };
}

/// «الكاشير» — a counter sale on this computer: the products the apps sell, at the business's prices (the server prices
/// them again — a device's price is never trusted), taken from the stock by the same recipes. Cash in the drawer, outside
/// the app. With no internet the sale is kept here (or on the main computer) and sent later; the drawer closes against
/// what the sales say it should hold. A sale may name a customer and put part or all of it «على الحساب» — within his
/// limit, checked by the server (so such a sale is never queued offline); only the cash part is in the drawer.
class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  final _scan = TextEditingController();
  final _paid = TextEditingController();
  final _search = TextEditingController();
  final _onAccount = TextEditingController();
  CrmCustomer? _customer;
  final List<_CartLine> _cart = [];
  final List<Map<String, dynamic>> _lastSales = [];
  bool _busy = false;

  @override
  void dispose() {
    _scan.dispose();
    _paid.dispose();
    _search.dispose();
    _onAccount.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _shift {
    final raw = ref.read(suiteStoreProvider).meta.get('pos_shift');
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  double get _total => _cart.fold(0.0, (s, l) => s + l.unitPrice * l.qty);

  Future<void> _add(InvPosProduct p) async {
    InvPosChoice? variant;
    var extras = <InvPosChoice>[];
    if (p.variants.isNotEmpty || p.extras.isNotEmpty) {
      final picked = await showDialog<(InvPosChoice?, List<InvPosChoice>)>(
        context: context,
        builder: (_) => _ChoiceDialog(product: p),
      );
      if (picked == null) return;
      (variant, extras) = picked;
    }
    setState(() {
      final same = _cart.where((l) => l.product == p && l.variant == variant && l.extras.length == extras.length && l.extras.every(extras.contains)).firstOrNull;
      if (same != null) {
        same.qty += 1;
      } else {
        _cart.add(_CartLine(product: p, variant: variant, extras: extras));
      }
    });
  }

  Future<void> _openShift() async {
    final l10n = AppLocalizations.of(context)!;
    final cash = TextEditingController(text: '0');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.suiteOpenShift),
        content: NumField(controller: cash, label: l10n.suiteOpeningCash, width: 240),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.suiteOpenShift)),
        ],
      ),
    );
    final opening = parseNum(cash.text) ?? 0;
    cash.dispose();
    if (ok != true || !mounted) return;
    final store = ref.read(suiteStoreProvider);
    final shift = await suiteRun(context, () => ref.read(inventoryApiProvider).openShift(openingCash: opening, deviceUuid: store.deviceUuid), queueable: false);
    if (shift != null) {
      await store.meta.put('pos_shift', jsonEncode({'id': shift['id'], 'opening': opening}));
      setState(() {});
    }
  }

  Future<void> _closeShift() async {
    final l10n = AppLocalizations.of(context)!;
    final shift = _shift;
    if (shift == null) return;
    final counted = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.suiteCloseShift),
        content: NumField(controller: counted, label: l10n.suiteCountedCash, width: 240),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.suiteCloseShift)),
        ],
      ),
    );
    final value = parseNum(counted.text);
    counted.dispose();
    if (ok != true || value == null || !mounted) return;
    try {
      final summary = await ref.read(inventoryApiProvider).closeShift(shift['id'] as int, value);
      await ref.read(suiteStoreProvider).meta.delete('pos_shift');
      if (!mounted) return;
      setState(_lastSales.clear);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.suiteShiftClosed),
          content: Text(l10n.suiteShiftSummary(InvLabels.money((summary['expected_cash'] as num?) ?? 0), InvLabels.money(value), InvLabels.money((summary['difference'] as num?) ?? 0))),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonOk))],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  double get _onAccountValue => _customer == null ? 0 : (parseNum(_onAccount.text) ?? 0).clamp(0, _total).toDouble();

  Future<void> _pickCustomer() async {
    final picked = await showDialog<CrmCustomer>(context: context, builder: (_) => const _CustomerPicker());
    if (picked != null) setState(() => _customer = picked);
  }

  /// The server refused the account part (over the limit): pass it with a manager's right, or go back.
  Future<bool> _askOverride(ApiException e) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.crmCreditLimit),
        content: Text(e.firstErrorFor('credit_limit') ?? e.message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.crmAskOverride)),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _sell({bool override = false}) async {
    final l10n = AppLocalizations.of(context)!;
    if (_cart.isEmpty) return;
    final onAccount = _onAccountValue;
    final paid = parseNum(_paid.text) ?? (_total - onAccount);
    if (paid + onAccount + 0.001 < _total) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.suitePaidLess)));
      return;
    }
    setState(() => _busy = true);
    final store = ref.read(suiteStoreProvider);
    try {
      final result = await ref
          .read(inventoryApiProvider)
          .sell(
            shiftId: _shift?['id'] as int?,
            paid: paid,
            lines: [for (final l in _cart) l.toJson()],
            deviceUuid: store.deviceUuid,
            customerId: _customer?.id,
            onAccount: onAccount,
            creditOverride: override,
          );
      if (!mounted) return;
      final change = paid + onAccount - _total;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result == null ? '${l10n.suiteQueued} · ${l10n.suiteChange(InvLabels.money(change))}' : l10n.suiteChange(InvLabels.money(change)))));
      // the receipt: from the server's own pricing when it answered, from this computer's cart when the sale was queued
      final sale =
          result?['sale'] as Map<String, dynamic>? ??
          {
            'number': '—',
            'total': _total,
            'paid': paid,
            'on_account': onAccount,
            'lines': [
              for (final l in _cart) {'name': l.product.name, 'qty': l.qty, 'unit_price': l.unitPrice, 'total': l.unitPrice * l.qty},
            ],
          };
      if (ref.read(suitePrintProvider).autoReceipt) unawaited(_printReceipt(sale));
      setState(() {
        if (result?['sale'] is Map<String, dynamic>) _lastSales.insert(0, result!['sale'] as Map<String, dynamic>);
        _cart.clear();
        _paid.clear();
        _onAccount.clear();
        _customer = null;
      });
      ref.invalidate(_catalogProvider);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.firstErrorFor('credit_limit') != null && !override) {
        setState(() => _busy = false);
        if (await _askOverride(e)) await _sell(override: true);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.firstErrorFor('credit_override') ?? e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _printReceipt(Map<String, dynamic> sale) async {
    final l10n = AppLocalizations.of(context)!;
    num n(Object? v) => v is num ? v : num.tryParse('$v') ?? 0;
    final total = n(sale['total']);
    final paidAmount = n(sale['paid']) + n(sale['on_account']);
    final pdf = await SuitePrint.receipt(
      businessName: ref.read(suiteBusinessProvider)?.name ?? '',
      title: l10n.suiteReceiptTitle,
      number: '${sale['number']}',
      at: DateTime.tryParse('${sale['sold_at']}')?.toLocal() ?? DateTime.now(),
      lines: [
        for (final l in (sale['lines'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
          PrintLine(name: '${l['name']}', qty: invNum(n(l['qty'])), price: InvLabels.money(n(l['unit_price'])), total: InvLabels.money(n(l['total']))),
      ],
      total: InvLabels.money(total),
      paid: InvLabels.money(paidAmount),
      change: InvLabels.money(paidAmount - total),
      footer: l10n.suiteReceiptFooter,
      labels: {'number': l10n.suiteReceiptNumber, 'date': l10n.suiteWhen, 'total': l10n.stkTotal, 'paid': l10n.suitePaidCash, 'change': l10n.suiteChangeLabel},
    );
    try {
      await ref.read(suitePrintProvider).print(pdf, receipt: true, name: 'receipt-${sale['number']}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.suitePrintFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = ref.watch(_catalogProvider);
    final shift = _shift;
    final paid = parseNum(_paid.text);

    return SuitePage(
      title: l10n.suiteNavPos,
      scroll: false,
      actions: [if (shift == null) FilledButton(onPressed: _openShift, child: Text(l10n.suiteOpenShift)) else OutlinedButton(onPressed: _closeShift, child: Text(l10n.suiteCloseShift))],
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
                        controller: _scan,
                        autofocus: true,
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.qr_code_scanner), hintText: l10n.suiteScanToSell, isDense: true),
                        onSubmitted: (code) {
                          final c = code.trim();
                          _scan.clear();
                          final p = catalog.valueOrNull?.where((p) => p.barcodes.contains(c)).firstOrNull;
                          if (p != null) {
                            _add(p);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.suiteUnknownBarcode(c))));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.suiteSearch, isDense: true),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: AsyncValueView<List<InvPosProduct>>(
                    value: catalog,
                    onRetry: () => ref.invalidate(_catalogProvider),
                    builder: (context, products) {
                      final q = _search.text.trim();
                      final shown = q.isEmpty ? products : products.where((p) => p.name.contains(q)).toList();
                      return GridView.extent(
                        maxCrossAxisExtent: 180,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.4,
                        children: [
                          for (final p in shown)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(10), alignment: AlignmentDirectional.topStart),
                              onPressed: () => _add(p),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  Text('${InvLabels.money(p.price)} ${l10n.stkCurrency}'),
                                  if (p.available != null) Text(l10n.suiteAvailable(p.available!), style: TextStyle(fontSize: 12, color: p.available! < 10 ? Tone.bad(context) : Tone.good(context))),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 380,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.suiteInvoice, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final l in _cart)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.product.name + (l.variant != null ? ' — ${l.variant!.name}' : '')),
                              subtitle: l.extras.isEmpty ? null : Text(l.extras.map((e) => e.name).join('، ')),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove), onPressed: () => setState(() => l.qty <= 1 ? _cart.remove(l) : l.qty -= 1)),
                                  Text(invNum(l.qty)),
                                  IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add), onPressed: () => setState(() => l.qty += 1)),
                                ],
                              ),
                              trailing: Text(InvLabels.money(l.unitPrice * l.qty)),
                            ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.stkTotal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                        Text('${InvLabels.money(_total)} ${l10n.stkCurrency}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    _customerBar(l10n),
                    if (_customer != null)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _onAccount,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: l10n.crmOnAccount, isDense: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _onAccount.text = invNum(_total);
                              _paid.text = '0';
                            }),
                            child: Text(l10n.crmAllOnAccount),
                          ),
                        ],
                      ),
                    TextField(
                      controller: _paid,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.suitePaidCash, hintText: InvLabels.money(_total - _onAccountValue)),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (paid != null && paid + _onAccountValue >= _total)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          l10n.suiteChange(InvLabels.money(paid + _onAccountValue - _total)),
                          style: TextStyle(color: Tone.good(context), fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: _busy || _cart.isEmpty ? null : _sell,
                      child: Text(l10n.suitePay, style: const TextStyle(fontSize: 17)),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.suiteCashOutsideHint, style: Theme.of(context).textTheme.bodySmall),
                    if (_lastSales.isNotEmpty) ...[
                      const Divider(),
                      Text(l10n.suiteLastSales, style: const TextStyle(fontWeight: FontWeight.w700)),
                      for (final s in _lastSales.take(5))
                        Row(
                          children: [
                            Expanded(child: Text('#${s['number']} · ${InvLabels.money((s['total'] as num?) ?? 0)}${s['status'] == 'returned' ? ' · ${l10n.suiteReturned}' : ''}')),
                            IconButton(tooltip: l10n.suitePrint, icon: const Icon(Icons.print_outlined), onPressed: () => _printReceipt(s)),
                            if (s['status'] != 'returned')
                              TextButton(
                                onPressed: () async {
                                  final r = await suiteRun(context, () => ref.read(inventoryApiProvider).returnSale(s['id'] as int), queueable: false);
                                  if (r != null) setState(() => s['status'] = 'returned');
                                },
                                child: Text(l10n.suiteReturn),
                              ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _PosPageState {
  /// Who this sale is for: «عميل نقدي» (no file) or a customer with his balance against his limit.
  Widget _customerBar(AppLocalizations l10n) {
    final c = _customer;
    if (c == null) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(icon: const Icon(Icons.person_search_outlined), label: Text('${l10n.crmCashCustomer} · ${l10n.crmPickCustomer}'), onPressed: _pickCustomer),
      );
    }
    final headroom = c.headroom;
    final over = headroom == null ? 0.0 : _onAccountValue - headroom;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l10n.crmCashCustomer,
                icon: const Icon(Icons.close),
                // ignore: invalid_use_of_protected_member
                onPressed: () => setState(() {
                  _customer = null;
                  _onAccount.clear();
                }),
              ),
            ],
          ),
          Text(
            '${CrmLabels.balance(context, c.balance)}${c.creditLimit == null ? '' : ' ${l10n.crmLimitOf(InvLabels.money(c.creditLimit!))}'}',
            style: TextStyle(color: CrmLabels.balanceColor(context, c.balance), fontWeight: FontWeight.w700),
          ),
          if (c.creditLimit != null && c.creditLimit! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(value: (c.balance / c.creditLimit!).clamp(0, 1).toDouble(), minHeight: 6, color: CrmLabels.balanceColor(context, 1)),
            ),
          if (over > 0.004)
            Text(
              l10n.crmOverLimit(InvLabels.money(over)),
              style: TextStyle(color: Tone.bad(context), fontWeight: FontWeight.w800),
            )
          else if (headroom != null)
            Text(l10n.crmHeadroom(InvLabels.money(headroom)), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// «اختيار عميل» at the counter: search by name or mobile, type the code from his app, or add him on the spot.
class _CustomerPicker extends ConsumerStatefulWidget {
  const _CustomerPicker();

  @override
  ConsumerState<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends ConsumerState<_CustomerPicker> {
  final _q = TextEditingController();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  List<CrmCustomer> _found = const [];
  bool _adding = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    for (final c in [_q, _code, _name, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      setState(() => _error = null);
      await action();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.firstErrorFor('code') ?? e.message);
    }
  }

  Future<void> _search() => _run(() async {
    final r = await ref.read(customersApiProvider).customers(q: _q.text);
    if (mounted) setState(() => _found = r.customers);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(customersApiProvider);
    return AlertDialog(
      title: Text(l10n.crmPickCustomer),
      content: SizedBox(
        width: 460,
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _q,
              autofocus: true,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.crmSearch, isDense: true),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _code,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.qr_code_2), hintText: l10n.crmScanCode, isDense: true),
              onSubmitted: (v) => _run(() async {
                final c = await api.resolveCode(v.trim());
                if (context.mounted) Navigator.pop(context, c);
              }),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_error!, style: TextStyle(color: Tone.bad(context))),
              ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: [
                  for (final c in _found)
                    ListTile(
                      dense: true,
                      title: Text(c.name),
                      subtitle: Text([if (c.phone != null) c.phone!, if (c.onApp) l10n.crmOnApp].join(' · ')),
                      trailing: Text(CrmLabels.balance(context, c.balance), style: TextStyle(color: CrmLabels.balanceColor(context, c.balance))),
                      onTap: () => Navigator.pop(context, c),
                    ),
                ],
              ),
            ),
            if (_adding) ...[
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.crmName, isDense: true),
              ),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.crmPhone, isDense: true),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        if (!_adding)
          OutlinedButton(onPressed: () => setState(() => _adding = true), child: Text(l10n.crmNewCustomer))
        else
          FilledButton(
            onPressed: () => _run(() async {
              if (_name.text.trim().isEmpty) return;
              final c = await api.create(name: _name.text.trim(), phone: _phone.text.trim().isEmpty ? null : _phone.text.trim());
              if (context.mounted) Navigator.pop(context, c);
            }),
            child: Text(l10n.commonSave),
          ),
      ],
    );
  }
}

class _ChoiceDialog extends StatefulWidget {
  final InvPosProduct product;
  const _ChoiceDialog({required this.product});

  @override
  State<_ChoiceDialog> createState() => _ChoiceDialogState();
}

class _ChoiceDialogState extends State<_ChoiceDialog> {
  InvPosChoice? _variant;
  final Set<InvPosChoice> _extras = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.product;
    return AlertDialog(
      title: Text(p.name),
      content: SizedBox(
        width: 380,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (p.variants.isNotEmpty) ...[
              Text(l10n.suiteSize, style: const TextStyle(fontWeight: FontWeight.w800)),
              RadioGroup<InvPosChoice?>(
                groupValue: _variant,
                onChanged: (v) => setState(() => _variant = v),
                child: Column(
                  children: [
                    RadioListTile<InvPosChoice?>(value: null, title: Text('${l10n.suiteRegular} · ${InvLabels.money(p.price)}')),
                    for (final v in p.variants) RadioListTile<InvPosChoice?>(value: v, title: Text('${v.name} · ${InvLabels.money(v.price)}')),
                  ],
                ),
              ),
            ],
            if (p.extras.isNotEmpty) ...[
              Text(l10n.suiteExtras, style: const TextStyle(fontWeight: FontWeight.w800)),
              for (final e in p.extras)
                CheckboxListTile(value: _extras.contains(e), title: Text('${e.name} · +${InvLabels.money(e.price)}'), onChanged: (v) => setState(() => v == true ? _extras.add(e) : _extras.remove(e))),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, (_variant, _extras.toList())), child: Text(l10n.suiteAddToInvoice)),
      ],
    );
  }
}
