import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/booking_providers.dart';
import '../../data/models/unit_discovery.dart';
import 'booking_grid_widgets.dart';
import 'booking_shape_tab.dart';

/// «شقق وشاليهات»: the dates and the guests first, then the units that are free on those dates — photo, what it
/// carries, the price a night and for the whole stay — and one bar to carry on with the chosen one.
class FurnishedUnitsTab extends ConsumerStatefulWidget {
  final int businessId;
  final UnitCatalog catalog;
  final UnitShape shape;

  const FurnishedUnitsTab({super.key, required this.businessId, required this.catalog, required this.shape});

  @override
  ConsumerState<FurnishedUnitsTab> createState() => _FurnishedUnitsTabState();
}

class _FurnishedUnitsTabState extends ConsumerState<FurnishedUnitsTab> {
  late DateTime _arrival;
  late DateTime _departure;
  int _guests = 2;
  int? _unitId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _arrival = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    _departure = _arrival.add(const Duration(days: 3));
  }

  Future<void> _pickArrival() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _arrival,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final nights = _departure.difference(_arrival).inDays.clamp(1, 60);
      _arrival = picked;
      if (!_departure.isAfter(_arrival)) _departure = _arrival.add(Duration(days: nights));
      _unitId = null;
    });
  }

  Future<void> _pickDeparture() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departure,
      firstDate: _arrival.add(const Duration(days: 1)),
      lastDate: _arrival.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _departure = picked;
        _unitId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMd(locale);

    final firstKind = widget.catalog.kinds.where((k) => k.units.isNotEmpty).firstOrNull;
    final async = ref.watch(
      unitDiscoveryProvider((
        businessId: widget.businessId,
        serviceId: widget.catalog.serviceId,
        itemType: firstKind?.itemType,
        startsAt: _arrival,
        endsAt: _departure,
      )),
    );

    final nights = _departure.difference(_arrival).inDays;
    final entries = <({UnitKindGroup group, DiscoveredUnit unit})>[];
    for (final k in async.valueOrNull ?? const <UnitKindGroup>[]) {
      for (final u in k.units) {
        // a unit that is taken on these dates is not offered; one that seats fewer than the party is left out too
        if (u.available == false) continue;
        if (u.capacity != null && u.capacity! < _guests) continue;
        entries.add((group: k, unit: u));
      }
    }
    final chosen = entries.where((e) => e.unit.id == _unitId).firstOrNull;

    return BoardScaffold(
      bottom: BookingSummaryBar(
        summary: chosen == null ? '' : chosen.unit.displayTitle,
        price: chosen?.unit.total,
        label: chosen == null ? l10n.bookingPickUnitToContinue : l10n.bookingContinue,
        onPressed: chosen == null
            ? null
            : () => openUnitBooking(
                context,
                businessId: widget.businessId,
                catalog: widget.catalog,
                shape: widget.shape,
                group: chosen.group,
                unit: chosen.unit,
                startsAt: _arrival,
                endsAt: _departure,
                partySize: _guests,
              ),
      ),
      children: [
        BookingSectionCard(
          title: l10n.bookingWhenStay,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: BookingValueField(label: l10n.bookingArrival, value: fmt.format(_arrival), onTap: _pickArrival)),
                  const SizedBox(width: 10),
                  Expanded(child: BookingValueField(label: l10n.bookingDeparture, value: fmt.format(_departure), onTap: _pickDeparture)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(l10n.bookingGuests, style: theme.textTheme.bodyMedium)),
                  IconButton(
                    onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(l10n.bookingGuestsCount(_guests), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: _guests < 30 ? () => setState(() => _guests++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text(l10n.bookingAvailableInDates, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
            if (async.hasValue) Text(l10n.bookingUnitsCount(entries.length), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
        ),
        const SizedBox(height: 8),
        if (async.isLoading && !async.hasValue)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (async.hasError && !async.hasValue)
          Text(l10n.commonSomethingWentWrong)
        else if (entries.isEmpty)
          Text(l10n.bookingNoUnitsInDates, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))
        else
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _UnitCard(
                unit: e.unit,
                price: e.unit.price ?? e.group.price,
                nights: nights,
                selected: e.unit.id == _unitId,
                onTap: () => setState(() => _unitId = e.unit.id),
              ),
            ),
      ],
    );
  }
}

class _UnitCard extends StatelessWidget {
  final DiscoveredUnit unit;
  final double? price;
  final int nights;
  final bool selected;
  final VoidCallback onTap;

  const _UnitCard({required this.unit, required this.price, required this.nights, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final facts = [
      if (unit.capacity != null) '${l10n.bookingCapacityLabel}: ${unit.capacity}',
      ...unit.features,
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? cs.secondary : Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 130,
              child: unit.images.isEmpty
                  ? ColoredBox(color: cs.primary.withValues(alpha: 0.07), child: Icon(Icons.cottage_outlined, size: 40, color: cs.primary.withValues(alpha: 0.55)))
                  : Image.network(
                      unit.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          ColoredBox(color: cs.surfaceContainerHighest, child: const Icon(Icons.broken_image_outlined)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(unit.displayTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        if (facts.isNotEmpty) Text(facts, style: theme.textTheme.bodySmall),
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
                        Text('${l10n.invCurrency} / ${l10n.bookingNightWord}', style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
