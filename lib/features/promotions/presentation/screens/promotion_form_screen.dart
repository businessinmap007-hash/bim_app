import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/promotions_providers.dart';
import '../../data/models/promotion.dart';

/// Which of the five ways a promotion can discount, as the merchant picks it. «اشترِ ٣ وادفع ثمن الأغلى» and «اشترِ ٢ واحصل على ١ مجانًا»
/// are the same rule (`n_for_price_of`) written two ways.
enum _Way { percent, amount, buyTop, buyFree, spend }

/// «العروض والخصومات»: three steps on one page — what it covers (the whole shop, a whole section, or some products), what it does,
/// and when and for whom.
class PromotionFormScreen extends ConsumerStatefulWidget {
  final Promotion? editing;

  const PromotionFormScreen({super.key, this.editing});

  @override
  ConsumerState<PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends ConsumerState<PromotionFormScreen> {
  bool _all = false;
  final Set<String> _sections = {}; // 'type:id'
  final Set<String> _items = {};
  _Way _way = _Way.percent;
  final _value = TextEditingController();
  final _n = TextEditingController(text: '3');
  final _free = TextEditingController(text: '1');
  final _minTotal = TextEditingController();
  final _maxUses = TextEditingController();
  final _title = TextEditingController();
  DateTime? _starts;
  DateTime? _ends;
  bool _newCustomers = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editing;
    if (p == null) return;

    for (final t in p.targets) {
      if (t.type == PromotionTargetType.all) {
        _all = true;
      } else if (t.type == PromotionTargetType.menuSection || t.type == PromotionTargetType.listingCategory) {
        _sections.add('${t.type}:${t.id}');
      } else {
        _items.add('${t.type}:${t.id}');
      }
    }

    switch (p.kind) {
      case PromotionKind.percent:
        _way = _Way.percent;
        _value.text = _fmt(p.param('value'));
      case PromotionKind.amount:
        _way = _Way.amount;
        _value.text = _fmt(p.param('value'));
      case PromotionKind.nForPriceOf:
        final n = p.param('n').round();
        final pay = p.param('pay').round();
        if (pay <= 1) {
          _way = _Way.buyTop;
          _n.text = '$n';
        } else {
          _way = _Way.buyFree;
          _n.text = '$pay';
          _free.text = '${n - pay}';
        }
      case PromotionKind.spendPercent:
        _way = _Way.spend;
        _minTotal.text = _fmt(p.param('min_total'));
        _value.text = _fmt(p.param('value'));
    }

    _title.text = p.title ?? '';
    _starts = p.startsAt;
    _ends = p.endsAt;
    _maxUses.text = p.maxUses?.toString() ?? '';
    _newCustomers = p.forNewCustomers;
  }

  @override
  void dispose() {
    for (final c in [_value, _n, _free, _minTotal, _maxUses, _title]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

  num _read(TextEditingController c) => num.tryParse(c.text.trim().replaceAll('٫', '.')) ?? 0;

  List<PromotionTarget> _targets() {
    if (_all) return const [PromotionTarget(type: PromotionTargetType.all)];

    return [
      for (final s in _sections) PromotionTarget(type: s.split(':').first, id: int.parse(s.split(':').last)),
      for (final i in _items) PromotionTarget(type: i.split(':').first, id: int.parse(i.split(':').last)),
    ];
  }

  (String, Map<String, num>) _rule() {
    switch (_way) {
      case _Way.percent:
        return (PromotionKind.percent, {'value': _read(_value)});
      case _Way.amount:
        return (PromotionKind.amount, {'value': _read(_value)});
      case _Way.buyTop:
        return (PromotionKind.nForPriceOf, {'n': _read(_n).round(), 'pay': 1});
      case _Way.buyFree:
        final pay = _read(_n).round();
        return (PromotionKind.nForPriceOf, {'n': pay + _read(_free).round(), 'pay': pay});
      case _Way.spend:
        return (PromotionKind.spendPercent, {'min_total': _read(_minTotal), 'value': _read(_value)});
    }
  }

  Future<void> _pickDate(bool start) async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: (start ? _starts : _ends) ?? now, firstDate: DateTime(now.year - 1), lastDate: now.add(const Duration(days: 365 * 2)));
    if (d != null) setState(() => start ? _starts = d : _ends = DateTime(d.year, d.month, d.day, 23, 59));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final targets = _targets();

    if (targets.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.promoPickSomething)));
      return;
    }

    if (_ends == null && _maxUses.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.promoNeedsEnd)));
      return;
    }

    final (kind, params) = _rule();
    setState(() => _saving = true);

    try {
      final notYet = await ref.read(promotionsApiProvider).save(
        id: widget.editing?.id,
        title: _title.text.trim(),
        kind: kind,
        params: params,
        targets: targets,
        audience: _newCustomers ? 'new_customers' : 'all',
        startsAt: _starts,
        endsAt: _ends,
        maxUses: _maxUses.text.trim().isEmpty ? null : _read(_maxUses).round(),
      );

      ref.invalidate(myPromotionsProvider);
      if (!mounted) return;
      if (notYet.isNotEmpty) messenger.showSnackBar(SnackBar(content: Text(l10n.promoNotYetDiscounted(notYet.take(3).join('، ')))));
      Navigator.of(context).pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final catalog = ref.watch(promotionCatalogProvider);

    Widget header(String text) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)));

    return Scaffold(
      appBar: AppBar(title: Text(widget.editing == null ? l10n.promoAdd : l10n.promoEdit)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          header(l10n.promoStepProducts),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _all,
            onChanged: (v) => setState(() => _all = v ?? false),
            title: Text(l10n.promoWholeShop),
          ),
          if (!_all)
            catalog.when(
              loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
              error: (_, _) => OutlinedButton(onPressed: () => ref.invalidate(promotionCatalogProvider), child: Text(l10n.commonRetry)),
              data: (c) => c.groups.isEmpty
                  ? Text(l10n.promoNoProducts)
                  : Column(children: [for (final g in c.groups) _group(context, g)]),
            ),
          header(l10n.promoStepType),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (way, label) in [
                (_Way.percent, l10n.promoWayPercent),
                (_Way.amount, l10n.promoWayAmount),
                (_Way.buyTop, l10n.promoWayBuyTop),
                (_Way.buyFree, l10n.promoWayBuyFree),
                (_Way.spend, l10n.promoWaySpend),
              ])
                ChoiceChip(label: Text(label), selected: _way == way, onSelected: (_) => setState(() => _way = way)),
            ],
          ),
          const SizedBox(height: 8),
          ..._ruleFields(l10n),
          header(l10n.promoStepDetails),
          TextField(controller: _title, decoration: InputDecoration(labelText: l10n.promoTitleOptional)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _pickDate(true), child: Text(_starts == null ? l10n.promoStarts : LocalFormat.date(context).format(_starts!)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => _pickDate(false), child: Text(_ends == null ? l10n.promoEnds : LocalFormat.date(context).format(_ends!)))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(controller: _maxUses, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.promoMaxUses, helperText: l10n.promoNeedsEnd)),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: _newCustomers, onChanged: (v) => setState(() => _newCustomers = v), title: Text(l10n.promoAudienceNew)),
          const SizedBox(height: 12),
          FilledButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.promoSave)),
        ],
      ),
    );
  }

  List<Widget> _ruleFields(AppLocalizations l10n) {
    InputDecoration d(String label) => InputDecoration(labelText: label);

    switch (_way) {
      case _Way.percent:
        return [TextField(controller: _value, keyboardType: TextInputType.number, decoration: d(l10n.promoValuePercent))];
      case _Way.amount:
        return [TextField(controller: _value, keyboardType: TextInputType.number, decoration: d(l10n.promoValueAmount))];
      case _Way.buyTop:
        return [TextField(controller: _n, keyboardType: TextInputType.number, decoration: d(l10n.promoBuyQty)), Text(l10n.promoBuyTopHint, style: Theme.of(context).textTheme.bodySmall)];
      case _Way.buyFree:
        return [
          TextField(controller: _n, keyboardType: TextInputType.number, decoration: d(l10n.promoBuyQty)),
          TextField(controller: _free, keyboardType: TextInputType.number, decoration: d(l10n.promoFreeQty)),
          Text(l10n.promoBuyFreeHint, style: Theme.of(context).textTheme.bodySmall),
        ];
      case _Way.spend:
        return [
          TextField(controller: _minTotal, keyboardType: TextInputType.number, decoration: d(l10n.promoMinTotal)),
          TextField(controller: _value, keyboardType: TextInputType.number, decoration: d(l10n.promoValuePercent)),
        ];
    }
  }

  /// A section with its products: «القسم كله» or some of them.
  Widget _group(BuildContext context, CatalogGroup g) {
    final l10n = AppLocalizations.of(context)!;
    final key = g.isSection ? '${g.type}:${g.id}' : null;
    final whole = key != null && _sections.contains(key);
    final picked = g.items.where((i) => _items.contains('${i.type}:${i.id}')).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(g.name ?? l10n.promoNoSection),
        subtitle: Text(whole ? l10n.promoWholeSection : (picked > 0 ? l10n.promoSelectedCount(picked) : l10n.promoItemsCount(g.items.length))),
        children: [
          if (key != null)
            CheckboxListTile(
              value: whole,
              onChanged: (v) => setState(() => v == true ? _sections.add(key) : _sections.remove(key)),
              title: Text(l10n.promoWholeSection, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          for (final i in g.items)
            CheckboxListTile(
              value: whole || _items.contains('${i.type}:${i.id}'),
              onChanged: whole ? null : (v) => setState(() => v == true ? _items.add('${i.type}:${i.id}') : _items.remove('${i.type}:${i.id}')),
              title: Text(i.name),
              secondary: Text(_fmt(i.price)),
            ),
        ],
      ),
    );
  }
}
