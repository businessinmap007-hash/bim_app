import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business_menu/data/models/menu_vocabulary.dart';
import '../../data/models/menu_search.dart';

/// The filter sheet of one detail kind, drawn from DATA: a figure gets from/to
/// (hinted with the range actually on offer), a choice gets chips (with how
/// many units carry each), words get a box. Returns the new filters, or null
/// when dismissed.
Future<SearchFilters?> showSearchFilterSheet(
  BuildContext context, {
  required List<DetailField> fields,
  required Map<String, SearchFacet> facets,
  required SearchFilters current,
}) {
  return showModalBottomSheet<SearchFilters>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FilterSheet(fields: fields, facets: facets, current: current),
  );
}

class _FilterSheet extends StatefulWidget {
  final List<DetailField> fields;
  final Map<String, SearchFacet> facets;
  final SearchFilters current;
  const _FilterSheet({required this.fields, required this.facets, required this.current});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final Map<String, TextEditingController> _text = {};
  final Map<String, Set<int>> _choices = {};

  TextEditingController _ctl(String key, String initial) =>
      _text.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      if (f.dataType == 'select') {
        _choices[f.code] = {...?widget.current.choices[f.code]};
      } else if (f.dataType == 'number') {
        _ctl('${f.code}_min', widget.current.bounds['${f.code}_min'] ?? '');
        _ctl('${f.code}_max', widget.current.bounds['${f.code}_max'] ?? '');
      } else {
        _ctl(f.code, widget.current.words[f.code] ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  SearchFilters _build() {
    final bounds = <String, String>{};
    final words = <String, String>{};
    for (final f in widget.fields) {
      if (f.dataType == 'number') {
        for (final suffix in ['min', 'max']) {
          final v = _text['${f.code}_$suffix']?.text.trim().replaceAll(',', '').replaceAll('٫', '.') ?? '';
          if (v.isNotEmpty && double.tryParse(v) != null) bounds['${f.code}_$suffix'] = v;
        }
      } else if (f.dataType != 'select') {
        final v = _text[f.code]?.text.trim() ?? '';
        if (v.isNotEmpty) words[f.code] = v;
      }
    }
    return SearchFilters(
      bounds: bounds,
      choices: {for (final e in _choices.entries) if (e.value.isNotEmpty) e.key: e.value},
      words: words,
    );
  }

  String _num(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    for (final f in widget.fields) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Text(
                          f.unit != null && f.dataType == 'number' ? '${f.name} (${f.unit})' : f.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (f.dataType == 'number') _numberField(f, l10n) else if (f.dataType == 'select') _choiceField(f) else _wordsField(f),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(const SearchFilters()),
                      child: Text(l10n.menuSearchReset),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(_build()),
                        child: Text(l10n.menuSearchApply),
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

  Widget _numberField(DetailField f, AppLocalizations l10n) {
    final facet = widget.facets[f.code];
    final hint = facet?.min != null && facet?.max != null
        ? l10n.menuSearchRangeHint(_num(facet!.min!), _num(facet.max!))
        : null;

    Widget box(String suffix, String label) => Expanded(
      child: TextField(
        controller: _ctl('${f.code}_$suffix', ''),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٫]'))],
        decoration: InputDecoration(labelText: label, hintText: hint, isDense: true),
      ),
    );

    return Row(children: [box('min', l10n.menuSearchFrom), const SizedBox(width: 10), box('max', l10n.menuSearchTo)]);
  }

  Widget _choiceField(DetailField f) {
    // What is actually on offer, with counts — else every option the field has.
    final offered = widget.facets[f.code]?.options;
    final options = offered != null && offered.isNotEmpty
        ? [for (final o in offered) (id: o.id, label: '${o.name} (${o.count})')]
        : [for (final o in f.options) (id: o.id, label: o.name)];
    final picked = _choices[f.code] ??= {};

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final o in options)
          FilterChip(
            label: Text(o.label),
            selected: picked.contains(o.id),
            onSelected: (on) => setState(() => on ? picked.add(o.id) : picked.remove(o.id)),
          ),
      ],
    );
  }

  Widget _wordsField(DetailField f) =>
      TextField(controller: _ctl(f.code, ''), decoration: const InputDecoration(isDense: true));
}
