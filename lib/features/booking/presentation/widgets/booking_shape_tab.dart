import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/offering_item.dart';
import '../../application/booking_providers.dart';
import '../../data/models/unit_discovery.dart';
import '../../../investigations/presentation/widgets/center_tests_tab.dart';
import '../screens/booking_screen.dart';
import 'appointment_board_tab.dart';
import 'course_board_tab.dart';
import 'furnished_units_tab.dart';
import 'hourly_venue_tab.dart';
import 'table_booking_tab.dart';

/// The «الحجز» tab of a business page drawn by its booking shape («أشكال الحجز»): a room kind is a section with its
/// rooms under it — photo, what it carries, its price — like the menu's sections, then one tap into the booking.
///
/// A business whose trade has no shape (or no units yet) gets [fallback] — the priced-lines list the tab always was.
class BookingShapeTab extends ConsumerWidget {
  final int businessId;
  final Widget fallback;

  const BookingShapeTab({super.key, required this.businessId, required this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(unitCatalogProvider(businessId));

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => fallback,
      data: (catalog) {
        final shape = catalog.shape;
        // a lab or a radiology centre sells tests, not rooms: several at once, priced by the centre
        if (shape != null && shape.multiSelect) return CenterTestsTab(centerId: businessId);
        // an appointment with the business itself has no units: its own board, whatever the unit list says
        if (shape != null && shape.code == 'appointment') {
          return AppointmentBoardTab(businessId: businessId, shape: shape, fallback: fallback);
        }
        // a course has no units either: its groups are the board
        if (shape != null && shape.code == 'course') {
          return CourseBoardTab(businessId: businessId, shape: shape, fallback: fallback);
        }
        if (shape == null || !catalog.hasUnits) return fallback;

        // the boards that have their own drawing: a day and a time first (a pitch, a table) or dates first (a chalet)
        switch (shape.code) {
          case 'hourly_venue':
            return HourlyVenueTab(businessId: businessId, catalog: catalog, shape: shape);
          case 'table':
            return TableBookingTab(businessId: businessId, catalog: catalog, shape: shape);
          case 'furnished_units':
            return FurnishedUnitsTab(businessId: businessId, catalog: catalog, shape: shape);
        }

        return _ShapedBooking(businessId: businessId, catalog: catalog, shape: shape);
      },
    );
  }
}

/// One tap from a board into the booking form with the unit (and, when the board already asked, the time and the
/// party) filled in — what the form still asks is only what the board did not.
void openUnitBooking(
  BuildContext context, {
  required int businessId,
  required UnitCatalog catalog,
  required UnitShape shape,
  required UnitKindGroup group,
  required DiscoveredUnit unit,
  bool dayUse = false,
  DateTime? startsAt,
  DateTime? endsAt,
  int? partySize,
}) {
  final offeringId = group.offeringId;
  if (offeringId == null) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BookingScreen(
        businessId: businessId,
        shape: shape,
        initialUnit: unit,
        startInDayUse: dayUse,
        initialStartsAt: startsAt,
        initialEndsAt: endsAt,
        initialPartySize: partySize,
        offering: OfferingItem(
          id: offeringId,
          source: 'price',
          label: unit.displayTitle,
          price: unit.price ?? group.price ?? 0,
          currency: group.currency ?? 'EGP',
          serviceId: catalog.serviceId,
          itemType: group.itemType,
          imageUrl: unit.images.isEmpty ? null : unit.images.first,
          action: 'book',
        ),
      ),
    ),
  );
}

/// The scrolling body of a shaped board plus its bottom bar. The page is a tab inside the business page's
/// NestedScrollView, so the body hands its top over to the header the way every tab there does.
class BoardScaffold extends StatelessWidget {
  final List<Widget> children;
  final Widget? bottom;
  const BoardScaffold({super.key, required this.children, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  sliver: SliverList(delegate: SliverChildListDelegate(children)),
                ),
              ],
            ),
          ),
        ),
        ?bottom,
      ],
    );
  }
}

class _ShapedBooking extends StatelessWidget {
  final int businessId;
  final UnitCatalog catalog;
  final UnitShape shape;

  const _ShapedBooking({required this.businessId, required this.catalog, required this.shape});

  void _book(BuildContext context, UnitKindGroup group, DiscoveredUnit unit, {bool dayUse = false}) {
    openUnitBooking(context, businessId: businessId, catalog: catalog, shape: shape, group: group, unit: unit, dayUse: dayUse);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final kinds = catalog.kinds.where((k) => k.units.isNotEmpty).toList();

    // the cheapest room type that is also sold through the day — the Day use card opens it
    ({UnitKindGroup group, DiscoveredUnit unit})? dayUse;
    if (shape.offerDayUse) {
      for (final k in kinds) {
        for (final u in k.units) {
          if (u.dayUse != null && (dayUse == null || u.dayUse!.price < dayUse.unit.dayUse!.price)) {
            dayUse = (group: k, unit: u);
          }
        }
      }
    }

    final children = <Widget>[
      Text(l10n.bookingPickUnitTitle, style: theme.textTheme.titleLarge),
      const SizedBox(height: 12),
      for (final kind in kinds) ...[
        if (shape.sectioned && (kind.name ?? '').isNotEmpty) _SectionHeader(kind: kind),
        for (final unit in kind.units)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _UnitCard(
              kind: kind,
              unit: unit,
              shape: shape,
              onTap: kind.offeringId == null ? null : () => _book(context, kind, unit),
            ),
          ),
        const SizedBox(height: 6),
      ],
      if (dayUse != null)
        _DayUseCard(
          offer: dayUse.unit.dayUse!,
          currency: dayUse.group.currency,
          onTap: () => _book(context, dayUse!.group, dayUse.unit, dayUse: true),
        ),
    ];

    return Builder(
      builder: (context) => CustomScrollView(
        key: const PageStorageKey('business_booking_shape'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate(children)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final UnitKindGroup kind;
  const _SectionHeader({required this.kind});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(kind.name!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(
            l10n.bookingUnitsAvailableCount(kind.units.length),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final UnitKindGroup kind;
  final DiscoveredUnit unit;
  final UnitShape shape;
  final VoidCallback? onTap;

  const _UnitCard({required this.kind, required this.unit, required this.shape, this.onTap});

  String _per(AppLocalizations l10n) {
    switch (unit.periodUnit) {
      case 'night':
        return l10n.bookingPerNight;
      case 'hour':
        return l10n.bookingPerHour;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final price = unit.price ?? kind.price;
    final facts = <String>[
      if (shape.showCapacity && unit.capacity != null) '${l10n.bookingCapacityLabel}: ${unit.capacity}',
      ...unit.features,
    ];

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (shape.showPhotos) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 84,
                      height: 76,
                      child: unit.images.isEmpty
                          ? ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.bed_outlined, color: theme.hintColor),
                            )
                          : Image.network(
                              unit.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => ColoredBox(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.bed_outlined, color: theme.hintColor),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(unit.displayTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (facts.isNotEmpty)
                        Text(facts.join(' · '), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                      if (shape.showPrice)
                        price == null
                            ? Text(
                                l10n.bookingUnitNotPriced,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    price.toStringAsFixed(0),
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${kind.currency ?? ''} ${_per(l10n)}'.trim(),
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                  ),
                                  if (unit.features.isNotEmpty) ...[
                                    const Spacer(),
                                    Flexible(
                                      child: Text(
                                        l10n.bookingPriceIncludes(unit.features.join('، ')),
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayUseCard extends StatelessWidget {
  final DayUseOffer offer;
  final String? currency;
  final VoidCallback onTap;

  const _DayUseCard({required this.offer, required this.currency, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: scheme.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bookingDayUse,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      l10n.bookingDayUseCardHint(offer.from, offer.to),
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              Text(
                '${offer.price.toStringAsFixed(0)} ${currency ?? ''}'.trim(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
