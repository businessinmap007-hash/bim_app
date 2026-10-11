import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

/// The pieces every «pick a day, then a time» booking board is drawn with (clinic, hourly venue, table): the white
/// section card, the day chip, the time chip and the summary bar at the bottom. One look, so the boards agree.

/// A white section card with a bold title (and an optional control at the end of the title row).
class BookingSectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  const BookingSectionCard({super.key, required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                ?trailing,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// Active = the theme's primary pair (navy with gold ink in light, gold with navy ink in dark); idle = a bordered chip;
/// [enabled] false = a time nobody can take (grey, no tap).
class BookingPickChip extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget Function(Color ink) builder;

  const BookingPickChip({super.key, required this.selected, this.enabled = true, required this.onTap, required this.builder});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ink = !enabled ? cs.onSurface.withValues(alpha: 0.38) : (selected ? cs.onPrimary : cs.onSurface);

    return Material(
      color: selected && enabled ? cs.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected && enabled ? cs.primary : cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: Center(child: builder(ink)),
      ),
    );
  }
}

class BookingDayChip extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final VoidCallback onTap;
  const BookingDayChip({super.key, required this.day, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return SizedBox(
      width: 62,
      child: BookingPickChip(
        selected: selected,
        onTap: onTap,
        builder: (ink) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat.E(locale).format(day), style: TextStyle(fontSize: 11, color: ink)),
            Text(DateFormat.d(locale).format(day), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          ],
        ),
      ),
    );
  }
}

/// A row of the coming days; the selected one is the active chip.
class BookingDayStrip extends StatelessWidget {
  final int days;
  final DateTime selected;
  final ValueChanged<DateTime> onPick;
  const BookingDayStrip({super.key, this.days = 14, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final first = DateTime(today.year, today.month, today.day);

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = first.add(Duration(days: i));
          return BookingDayChip(
            day: day,
            selected: day.year == selected.year && day.month == selected.month && day.day == selected.day,
            onTap: () => onPick(day),
          );
        },
      ),
    );
  }
}

/// The grid of start times — four to a row, the taken ones greyed.
class BookingTimeGrid extends StatelessWidget {
  final List<({DateTime at, bool enabled})> times;
  final DateTime? selected;
  final ValueChanged<DateTime> onPick;
  const BookingTimeGrid({super.key, required this.times, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.1,
      children: [
        for (final t in times)
          BookingPickChip(
            selected: selected != null && selected!.isAtSameMomentAs(t.at),
            enabled: t.enabled,
            onTap: () => onPick(t.at),
            builder: (ink) => Text(
              DateFormat.jm(locale).format(t.at),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink),
            ),
          ),
      ],
    );
  }
}

/// The bar at the bottom of a board: what is chosen (and its price), then one full-width action.
class BookingSummaryBar extends StatelessWidget {
  final String summary;
  final double? price;
  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  const BookingSummaryBar({super.key, required this.summary, this.price, required this.label, this.busy = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (summary.isNotEmpty || price != null) ...[
                Row(
                  children: [
                    Expanded(child: Text(summary, style: theme.textTheme.bodyMedium)),
                    if (price != null)
                      Text(
                        '${price!.toStringAsFixed(price! % 1 == 0 ? 0 : 2)} ${l10n.invCurrency}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: busy ? null : onPressed,
                child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small «label: value» field that opens a picker when tapped — the canvas's date and party-size boxes.
class BookingValueField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const BookingValueField({super.key, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
            Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
