import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/promotions_providers.dart';
import '../../data/models/promotion.dart';
import '../widgets/offer_widgets.dart';

/// The four ways a promotion can discount, as the merchant picks it. «اشترِ [..] واحصل على [..]» is ONE way with two typed numbers:
/// he pays for the first and takes the second (the cheapest pieces of every group are free).
enum _Way { percent, amount, buyGet, spend }

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
  final _pay = TextEditingController(text: '2');
  final _take = TextEditingController(text: '3');
  final _maxGroups = TextEditingController();
  bool _sameItem = false;
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
        _way = _Way.buyGet;
        _pay.text = '${p.param('pay').round()}';
        _take.text = '${p.param('n').round()}';
        _sameItem = p.params['same_item'] == true;
        if (p.param('max_groups') > 0) _maxGroups.text = '${p.param('max_groups').round()}';
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
    for (final c in [_value, _pay, _take, _maxGroups, _minTotal, _maxUses, _title]) {
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

  (String, Map<String, Object>) _rule() {
    switch (_way) {
      case _Way.percent:
        return (PromotionKind.percent, {'value': _read(_value)});
      case _Way.amount:
        return (PromotionKind.amount, {'value': _read(_value)});
      case _Way.buyGet:
        return (PromotionKind.nForPriceOf, {
          'n': _read(_take).round(),
          'pay': _read(_pay).round(),
          if (_sameItem) 'same_item': true,
          if (_maxGroups.text.trim().isNotEmpty) 'max_groups': _read(_maxGroups).round(),
        });
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
      if (notYet.isNotEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.promoNotYetDiscounted(notYet.take(3).map((n) => n.eligibleFrom == null ? n.name : '${n.name} (${n.eligibleFrom})').join('، ')))));
      }
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
          _summaryCard(l10n, theme),
          header(l10n.promoStepType),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (way, label) in [
                (_Way.percent, l10n.promoWayPercent),
                (_Way.amount, l10n.promoWayAmount),
                (_Way.buyGet, l10n.promoWayBuyGet),
                (_Way.spend, l10n.promoWaySpend),
              ])
                ChoiceChip(label: Text(label), selected: _way == way, onSelected: (_) => setState(() => _way = way)),
            ],
          ),
          const SizedBox(height: 8),
          ..._ruleFields(l10n),
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

  /// «ملخص العرض»: the rule in words and what it covers, growing as the merchant fills the steps.
  Widget _summaryCard(AppLocalizations l10n, ThemeData theme) {
    final (kind, params) = _rule();
    double param(String key) => (params[key] as num?)?.toDouble() ?? 0;

    final valid = switch (_way) {
      _Way.percent || _Way.amount => param('value') > 0,
      _Way.buyGet => param('pay') >= 1 && param('n') > param('pay') && param('n') <= 20,
      _Way.spend => param('min_total') > 0 && param('value') > 0,
    };

    final picked = _sections.length + _items.length;
    final covers = _all ? l10n.promoCoversAll : (picked > 0 ? l10n.promoSelectedCount(picked) : l10n.promoPickSomething);

    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFFD6A94A).withValues(alpha: 0.14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.promoSummaryTitle, style: theme.textTheme.bodySmall),
            Text(valid ? promotionSummary(l10n, kind, param) : l10n.promoBuyGetInvalid, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(covers, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  List<Widget> _ruleFields(AppLocalizations l10n) {
    InputDecoration d(String label) => InputDecoration(labelText: label);

    switch (_way) {
      case _Way.percent:
        return [TextField(controller: _value, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: d(l10n.promoValuePercent))];
      case _Way.amount:
        return [TextField(controller: _value, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: d(l10n.promoValueAmount))];
      case _Way.buyGet:
        final pay = _read(_pay).round();
        final take = _read(_take).round();
        final valid = pay >= 1 && take > pay && take <= 20;

        return [
          // «اشترِ ١ واحصل على ٣» … «اشترِ ٤ واحصل على ٨»: the numbers the shops use, one tap
          Wrap(
            spacing: 8,
            children: [
              for (final (p, t) in [(1, 3), (2, 3), (2, 6), (4, 8)])
                ActionChip(label: Text(l10n.promoBuyGet(p, t)), onPressed: () => setState(() { _pay.text = '$p'; _take.text = '$t'; })),
            ],
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _pay, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: d(l10n.promoBuyPay))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _take, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: d(l10n.promoGetTake))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              valid ? l10n.promoBuyGetSentence(pay, take, take - pay) : l10n.promoBuyGetInvalid,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: _sameItem, onChanged: (v) => setState(() => _sameItem = v), title: Text(l10n.promoSameItemOnly)),
          TextField(controller: _maxGroups, keyboardType: TextInputType.number, decoration: d(l10n.promoMaxGroups)),
        ];
      case _Way.spend:
        return [
          TextField(controller: _minTotal, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: d(l10n.promoMinTotal)),
          TextField(controller: _value, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: d(l10n.promoValuePercent)),
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
