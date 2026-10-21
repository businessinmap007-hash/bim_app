import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/offering_item.dart';
import '../../data/models/unit_discovery.dart';
import '../screens/booking_screen.dart';

/// «غرف من فنادق شريكة»: rooms another business (a hotel) gave this one to sell — shown with the photos and what each carries,
/// at THIS business's own price. A tap books the hotel's room through this business; the contract behind it is never shown.
class PartnerRoomsSection extends StatelessWidget {
  final int businessId;
  final List<PartnerRoom> rooms;
  final UnitShape? shape;

  const PartnerRoomsSection({super.key, required this.businessId, required this.rooms, this.shape});

  void _book(BuildContext context, PartnerRoom r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          businessId: businessId,
          shape: shape,
          initialUnit: DiscoveredUnit(id: r.unitId, label: r.label, capacity: r.capacity, images: r.images, price: r.price, features: r.features),
          // id 0: the room is not on this business's own price list; the allocation prices it
          offering: OfferingItem(
            id: 0,
            source: 'price',
            label: r.label,
            price: r.price,
            currency: r.currency,
            serviceId: r.serviceId,
            itemType: r.itemType,
            imageUrl: r.images.isEmpty ? null : r.images.first,
            action: 'book',
          ),
        ),
      ),
    );
  }

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
                              if (r.features.isNotEmpty) Text(r.features.join(' · '), style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${r.price == r.price.roundToDouble() ? r.price.toStringAsFixed(0) : r.price.toStringAsFixed(2)} ${r.currency}',
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
