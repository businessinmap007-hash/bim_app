import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/offering_item.dart';
import '../../../promotions/presentation/widgets/offer_widgets.dart';
import '../../data/models/child_policy.dart';
import '../../data/models/unit_discovery.dart';
import '../screens/booking_screen.dart';

/// «غرف من فنادق شريكة»: rooms another business (a hotel) gave this one to sell — shown with the photos and what each carries,
/// at THIS business's own price. A tap books the hotel's room through this business; the contract behind it is never shown.
class PartnerRoomsSection extends StatelessWidget {
  final int businessId;
  final List<PartnerRoom> rooms;
  final UnitShape? shape;

  const PartnerRoomsSection({super.key, required this.businessId, required this.rooms, this.shape});

  void _book(BuildContext context, PartnerRoom r) => openPartnerRoomBooking(
    context,
    businessId: businessId,
    shape: shape,
    unitId: r.unitId,
    serviceId: r.serviceId,
    itemType: r.itemType,
    label: r.label,
    capacity: r.capacity,
    images: r.images,
    features: r.features,
    price: r.price,
    currency: r.currency,
    guestScope: r.guestScope,
    choices: r.choices,
    optionIds: r.optionIds,
    childPolicy: r.childPolicy,
    // the other kinds of the same room (a view each), so the form offers them as one choice
    variants: [
      for (final k in rooms.where((x) => x.allocationId == r.allocationId))
        DiscoveredUnit(id: k.unitId, label: k.label, capacity: k.capacity, images: k.images, price: k.price, features: k.features, guestScope: k.guestScope, choices: k.choices, variantOptionIds: k.optionIds, available: k.available, reason: k.reason),
    ],
    holdStartsAt: r.myHold?.isLive == true ? r.myHold!.startsAt : null,
    holdEndsAt: r.myHold?.isLive == true ? r.myHold!.endsAt : null,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.pshPartnerRoomsTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final r in rooms)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Opacity(
              opacity: r.available ? 1 : 0.55,
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: r.available ? () => _book(context, r) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 84,
                            height: 76,
                            child: r.images.isEmpty
                                ? ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Icon(Icons.bed_outlined, color: theme.hintColor))
                                : Image.network(
                                    r.images.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Icon(Icons.bed_outlined, color: theme.hintColor)),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              if ((r.fromName ?? '').isNotEmpty) Text(l10n.pshFromHotel(r.fromName!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                              if (r.myHold?.isLive == true) Text(l10n.bookingMyHold(r.myHold!.leftLabel), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                              if (r.guestScope != 'all') Text(r.guestScope == 'locals' ? l10n.guestScopeLocals : l10n.guestScopeForeigners, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                              if (r.features.isNotEmpty) Text(r.features.join(' · '), style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  PriceWithOffer(
                                    label: '${r.price == r.price.roundToDouble() ? r.price.toStringAsFixed(0) : r.price.toStringAsFixed(2)} ${r.currency}',
                                    offer: r.offer,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(l10n.pshPerNight, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                  const Spacer(),
                                  Text(
                                    r.available ? l10n.pshRoomsLeft(r.availableQuantity) : (r.reason ?? ''),
                                    style: theme.textTheme.bodySmall?.copyWith(color: r.available ? null : theme.colorScheme.error),
                                  ),
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
            ),
          ),
      ],
    );
  }
}

/// A tap on a hotel's room sold through THIS business: the booking form opens on that room at this business's price. The offering id is 0:
/// the room is not on this business's own price list, the allocation prices it.
void openPartnerRoomBooking(
  BuildContext context, {
  required int businessId,
  UnitShape? shape,
  required int unitId,
  required int serviceId,
  required String itemType,
  required String label,
  int? capacity,
  List<String> images = const [],
  List<String> features = const [],
  required double price,
  String currency = 'EGP',
  String guestScope = 'all',
  List<UnitChoice> choices = const [],
  List<int> optionIds = const [],
  List<DiscoveredUnit> variants = const [],
  ChildPolicy? childPolicy,
  DateTime? holdStartsAt,
  DateTime? holdEndsAt,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BookingScreen(
        businessId: businessId,
        shape: shape,
        initialStartsAt: holdStartsAt,
        initialEndsAt: holdEndsAt,
        initialUnit: DiscoveredUnit(id: unitId, label: label, capacity: capacity, images: images, price: price, features: features, guestScope: guestScope, choices: choices, variantOptionIds: optionIds),
        variants: variants.length > 1 ? variants : const [],
        childPolicy: childPolicy,
        offering: OfferingItem(
          id: 0,
          source: 'price',
          label: label,
          price: price,
          currency: currency,
          serviceId: serviceId,
          itemType: itemType,
          imageUrl: images.isEmpty ? null : images.first,
          action: 'book',
        ),
      ),
    ),
  );
}

/// The whole «الحجز» tab of a business that has no rooms of its own but sells a partner's.
class PartnerRoomsPage extends StatelessWidget {
  final int businessId;
  final List<PartnerRoom> rooms;
  final UnitShape? shape;

  const PartnerRoomsPage({super.key, required this.businessId, required this.rooms, this.shape});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => CustomScrollView(
        key: const PageStorageKey('business_partner_rooms'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: PartnerRoomsSection(businessId: businessId, rooms: rooms, shape: shape)),
          ),
        ],
      ),
    );
  }
}
