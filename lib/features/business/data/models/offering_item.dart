import '../../../../core/env/env.dart';
import '../../../booking/data/models/booking_form.dart';

/// Mirrors `BusinessOfferingsController::payload()` — one priced row on a
/// single business's "services" tab: a line option plus any modifiers,
/// already labelled ("SUV — أوتوماتيك"), with the action the row leads to.
/// Ordering into a cart is wired; booking reads `serviceId`/`units` below —
/// a rented car is a NAMED car, and the units here are already scoped to
/// exactly this line (same item_type + line_option the row was priced
/// under), not the business's whole fleet.
class OfferingItem {
  final int id;
  final String source;
  final String label;
  final double price;
  final String currency;
  final int? serviceId;
  final String? serviceKey;
  final String? itemType;
  final String? imageUrl;
  final String action; // 'book' | 'order'
  final List<BookableUnitOption> units;

  const OfferingItem({
    required this.id,
    required this.source,
    required this.label,
    required this.price,
    required this.currency,
    this.serviceId,
    this.serviceKey,
    this.itemType,
    this.imageUrl,
    required this.action,
    this.units = const [],
  });

  bool get isBookable => action == 'book';

  factory OfferingItem.fromJson(Map<String, dynamic> json) => OfferingItem(
    id: json['id'] as int,
    source: json['source'] as String? ?? '',
    label: json['label'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    serviceId: json['service_id'] as int?,
    serviceKey: json['service_key'] as String?,
    itemType: json['item_type'] as String?,
    imageUrl: Env.assetUrl(json['image'] as String?),
    action: json['action'] as String? ?? 'order',
    units: (json['units'] as List<dynamic>? ?? [])
        .map((e) => BookableUnitOption.fromOfferingJson(e as Map<String, dynamic>))
        .toList(),
  );
}
