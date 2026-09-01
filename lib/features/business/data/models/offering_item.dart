import '../../../../core/env/env.dart';

/// Mirrors `BusinessOfferingsController::payload()` — one priced row on a
/// single business's "services" tab: a line option plus any modifiers,
/// already labelled ("SUV — أوتوماتيك"), with the action the row leads to.
/// Booking a specific unit and ordering into a cart are later modules; this
/// is the read-only browse shape (filter axes are deliberately not modelled
/// yet — this first pass shows the unfiltered list).
class OfferingItem {
  final int id;
  final String source;
  final String label;
  final double price;
  final String currency;
  final String? serviceKey;
  final String? imageUrl;
  final String action; // 'book' | 'order'

  const OfferingItem({
    required this.id,
    required this.source,
    required this.label,
    required this.price,
    required this.currency,
    this.serviceKey,
    this.imageUrl,
    required this.action,
  });

  bool get isBookable => action == 'book';

  factory OfferingItem.fromJson(Map<String, dynamic> json) => OfferingItem(
    id: json['id'] as int,
    source: json['source'] as String? ?? '',
    label: json['label'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    serviceKey: json['service_key'] as String?,
    imageUrl: Env.assetUrl(json['image'] as String?),
    action: json['action'] as String? ?? 'order',
  );
}
