import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/booking_providers.dart';
import '../../data/models/unit_discovery.dart';
import 'booking_grid_widgets.dart';
import 'booking_shape_tab.dart';

/// «ملاعب وقاعات — بالساعة»: a day, then a start time (the taken ones greyed), then the pitch or hall — each unit that
/// is free at that time — and one bar with what was chosen and its price.
class HourlyVenueTab extends ConsumerStatefulWidget {
  final int businessId;
  final UnitCatalog catalog;
  final UnitShape shape;

  const HourlyVenueTab({super.key, required this.businessId, required this.catalog, required this.shape});

  @override
  ConsumerState<HourlyVenueTab> createState() => _HourlyVenueTabState();
}

class _HourlyVenueTabState extends ConsumerState<HourlyVenueTab> {
  static const _durations = [60, 90, 120, 180, 240];

  late DateTime _day;
  int _minutes = 60;
  DateTime? _slot;
  int? _unitId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _durationLabel(AppLocalizations l10n, int minutes) {
    switch (minutes) {
      case 60:
        return l10n.bookingDurHour;
      case 90:
        return l10n.bookingDurHourHalf;
      case 120:
        return l10n.bookingDurTwoHours;
      default:
        return l10n.bookingDurHours(minutes ~/ 60);
    }
  }

  List<UnitKindGroup> get _kinds => widget.catalog.kinds.where((k) => k.units.isNotEmpty).toList();

  ({UnitKindGroup group, DiscoveredUnit unit})? get _chosen {
    for (final k in _kinds) {
      for (final u in k.units) {
        if (u.id == _unitId) return (group: k, unit: u);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final kinds = _kinds;

    final params = (
      businessId: widget.businessId,
      date: _dateKey(_day),
      durationMinutes: _minutes,
      stepMinutes: _minutes % 60 == 0 ? 60 : 30,
      partySize: null,
      serviceId: widget.catalog.serviceId,
      itemType: kinds.isEmpty ? null : kinds.first.itemType,
    );
    final grid = ref.watch(dayGridProvider(params));
    final slotData = grid.valueOrNull?.slots.where((s) => s.startsAt == _slot).firstOrNull;
    final freeIds = slotData?.unitIds.toSet();

    final chosen = _chosen;
    final canBook = chosen != null && _slot != null && (freeIds?.contains(chosen.unit.id) ?? false);
    final hours = _minutes / 60;
    final total = chosen == null
        ? null
        : (chosen.unit.price ?? chosen.group.price) == null
        ? null
        : (chosen.unit.price ?? chosen.group.price)! * (chosen.unit.periodUnit == 'hour' || chosen.unit.periodUnit == null ? hours : 1);

    final summary = chosen == null || _slot == null
        ? l10n.bookingHourlyHint
        : '${chosen.unit.displayTitle} — ${DateFormat.jm(locale).format(_slot!)} – ${DateFormat.jm(locale).format(_slot!.add(Duration(minutes: _minutes)))}';

    return BoardScaffold(
      bottom: BookingSummaryBar(
        summary: summary,
        price: canBook ? total : null,
        label: l10n.bookingBookNow,
        onPressed: !canBook
            ? null
            : () => openUnitBooking(
                context,
                businessId: widget.businessId,
                catalog: widget.catalog,
                shape: widget.shape,
                group: chosen.group,
                unit: chosen.unit,
                startsAt: _slot,
                endsAt: _slot!.add(Duration(minutes: _minutes)),
              ),
      ),
      children: [
        BookingSectionCard(
          title: l10n.bookingDayTitle,
          child: BookingDayStrip(
            selected: _day,
            onPick: (d) => setState(() {
              _day = d;
              _slot = null;
            }),
          ),
        ),
        const SizedBox(height: 14),
        BookingSectionCard(
          title: l10n.bookingStartTime,
          trailing: PopupMenuButton<int>(
            initialValue: _minutes,
            onSelected: (m) => setState(() {
              _minutes = m;
              _slot = null;
            }),
            itemBuilder: (_) => [for (final m in _durations) PopupMenuItem(value: m, child: Text(_durationLabel(l10n, m)))],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.bookingDurationLabel(_durationLabel(l10n, _minutes)), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          child: grid.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            error: (_, _) => Text(l10n.commonSomethingWentWrong),
            data: (g) {
              if (g.closed) return Text(l10n.bookingClosedDay);
              if (g.slots.isEmpty) return Text(l10n.bookingNoFreeTime);

              return BookingTimeGrid(
                times: [for (final s in g.slots) (at: s.startsAt, enabled: s.isFree)],
                selected: _slot,
                onPick: (t) => setState(() {
                  _slot = t;
                  // a unit that is not free at the new time cannot stay chosen
                  final free = g.slots.firstWhere((s) => s.startsAt == t).unitIds;
                  if (_unitId != null && !free.contains(_unitId)) _unitId = null;
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        for (final kind in kinds) ...[
          if ((kind.name ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 2),
              child: Row(
                children: [
                  Text(kind.name!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                ],
              ),
            ),
          for (final unit in kind.units)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _VenueRow(
                unit: unit,
                price: unit.price ?? kind.price,
                selected: unit.id == _unitId,
                // before a time is chosen every unit can be tapped; after, only the ones free at that time
                enabled: freeIds == null || freeIds.contains(unit.id),
                onTap: () => setState(() => _unitId = unit.id),
              ),
            ),
        ],
      ],
    );
  }
}

class _VenueRow extends StatelessWidget {
  final DiscoveredUnit unit;
  final double? price;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _VenueRow({required this.unit, required this.price, required this.selected, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final faded = !enabled;

    return Opacity(
      opacity: faded ? 0.5 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? cs.secondary : Colors.transparent, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 56,
                    child: unit.images.isEmpty
                        ? ColoredBox(color: cs.surfaceContainerHighest, child: const Icon(Icons.sports_soccer_outlined))
                        : Image.network(
                            unit.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                ColoredBox(color: cs.surfaceContainerHighest, child: const Icon(Icons.broken_image_outlined)),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unit.displayTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (faded) Text(l10n.bookingUnitUnavailable, style: theme.textTheme.bodySmall?.copyWith(color: cs.error)),
                    ],
                  ),
                ),
                if (price != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price!.toStringAsFixed(price! % 1 == 0 ? 0 : 2),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text('${l10n.invCurrency} / ${l10n.bookingHourWord}', style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
