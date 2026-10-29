import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
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
        if (extras.isNotEmpty) 'extras': [for (final e in extras) {'id': e.id, 'qty': 1}],
      };
}

/// «الكاشير» — a counter sale on this computer: the products the apps sell, at the business's prices (the server prices
/// them again — a device's price is never trusted), taken from the stock by the same recipes. Cash in the drawer, outside
/// the app. With no internet the sale is kept here (or on the main computer) and sent later; the drawer closes against
/// what the sales say it should hold.
class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  final _scan = TextEditingController();
  final _paid = TextEditingController();
  final _search = TextEditingController();
  final List<_CartLine> _cart = [];
  final List<Map<String, dynamic>> _lastSales = [];
  bool _busy = false;

  @override
  void dispose() {
    _scan.dispose();
    _paid.dispose();
    _search.dispose();
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
      final picked = await showDialog<(InvPosChoice?, List<InvPosChoice>)>(context: context, builder: (_) => _ChoiceDialog(product: p));
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
          content: Text(l10n.suiteShiftSummary(
            InvLabels.money((summary['expected_cash'] as num?) ?? 0),
            InvLabels.money(value),
            InvLabels.money((summary['difference'] as num?) ?? 0),
          )),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonOk))],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _sell() async {
    final l10n = AppLocalizations.of(context)!;
    if (_cart.isEmpty) return;
    final paid = parseNum(_paid.text) ?? _total;
    if (paid + 0.001 < _total) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.suitePaidLess)));
      return;
    }
    setState(() => _busy = true);
    final store = ref.read(suiteStoreProvider);
    try {
      final result = await ref.read(inventoryApiProvider).sell(
            shiftId: _shift?['id'] as int?,
            paid: paid,
            lines: [for (final l in _cart) l.toJson()],
            deviceUuid: store.deviceUuid,
          );
      if (!mounted) return;
      final change = paid - _total;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result == null ? '${l10n.suiteQueued} · ${l10n.suiteChange(InvLabels.money(change))}' : l10n.suiteChange(InvLabels.money(change))),
      ));
      setState(() {
        if (result?['sale'] is Map<String, dynamic>) _lastSales.insert(0, result!['sale'] as Map<String, dynamic>);
        _cart.clear();
        _paid.clear();
      });
      ref.invalidate(_catalogProvider);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
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
      actions: [
        if (shift == null)
          FilledButton(onPressed: _openShift, child: Text(l10n.suiteOpenShift))
        else
          OutlinedButton(onPressed: _closeShift, child: Text(l10n.suiteCloseShift)),
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
                                  Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text('${InvLabels.money(p.price)} ${l10n.stkCurrency}'),
                                  if (p.available != null)
                                    Text(l10n.suiteAvailable(p.available!),
                                        style: TextStyle(fontSize: 12, color: p.available! < 10 ? const Color(0xFFB93A22) : const Color(0xFF1F7A44))),
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
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => setState(() => l.qty <= 1 ? _cart.remove(l) : l.qty -= 1),
                                  ),
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
                    Row(children: [
                      Expanded(child: Text(l10n.stkTotal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                      Text('${InvLabels.money(_total)} ${l10n.stkCurrency}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    ]),
                    TextField(
                      controller: _paid,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.suitePaidCash),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (paid != null && paid >= _total)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(l10n.suiteChange(InvLabels.money(paid - _total)), style: const TextStyle(color: Color(0xFF1F7A44), fontWeight: FontWeight.w800, fontSize: 18)),
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
                child: Column(children: [
                  RadioListTile<InvPosChoice?>(value: null, title: Text('${l10n.suiteRegular} · ${InvLabels.money(p.price)}')),
                  for (final v in p.variants) RadioListTile<InvPosChoice?>(value: v, title: Text('${v.name} · ${InvLabels.money(v.price)}')),
                ]),
              ),
            ],
            if (p.extras.isNotEmpty) ...[
              Text(l10n.suiteExtras, style: const TextStyle(fontWeight: FontWeight.w800)),
              for (final e in p.extras)
                CheckboxListTile(
                  value: _extras.contains(e),
                  title: Text('${e.name} · +${InvLabels.money(e.price)}'),
                  onChanged: (v) => setState(() => v == true ? _extras.add(e) : _extras.remove(e)),
                ),
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
