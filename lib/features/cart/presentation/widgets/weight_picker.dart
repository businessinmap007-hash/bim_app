import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// «1.5» as «1.5», «2.0» as «2» — a quantity without the noise of a decimal point it does not need.
String formatQty(num qty) {
  final v = qty.toDouble();
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  final s = v.toStringAsFixed(2);
  return s.endsWith('0') ? s.substring(0, s.length - 1) : s;
}

/// «كيلو وربع ونص» — how much of a food sold by the kilo: the grams as chips (250 · 500 · 750) and the whole
/// kilos as a «− 1 +» stepper. The value is in kilos (1.5 = a kilo and a half); never below 250 g.
class WeightPicker extends StatelessWidget {
  static const minKg = 0.25;
  static const _grams = [250, 500, 750];

  final double value;
  final ValueChanged<double> onChanged;

  const WeightPicker({super.key, required this.value, required this.onChanged});

  int get _wholeKg => value.floor();
  int get _grams_ => ((value - value.floor()) * 1000).round();

  void _set(int kg, int grams) {
    final next = kg + grams / 1000;
    onChanged(next < minKg ? minKg : next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final g in _grams)
              ChoiceChip(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                label: Text(l10n.weightGramsChip(g)),
                selected: _grams_ == g,
                // Tapping the chosen grams again clears them.
                onSelected: (_) => _set(_wholeKg, _grams_ == g ? 0 : g),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: _wholeKg > 0 ? () => _set(_wholeKg - 1, _grams_) : null,
              icon: const Icon(Icons.remove_circle_outline, size: 22),
            ),
            Text('$_wholeKg', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Text(l10n.weightKilo, style: theme.textTheme.bodyMedium),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => _set(_wholeKg + 1, _grams_),
              icon: const Icon(Icons.add_circle_outline, size: 22),
            ),
            const SizedBox(width: 8),
            Text('= ${formatQty(value)} ${l10n.weightKilo}', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
        ),
      ],
    );
  }
}
