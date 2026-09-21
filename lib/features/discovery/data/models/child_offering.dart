import '../../../../core/env/env.dart';

/// One tappable «line — modifiers» combination a specialty sells, with how many
/// priced rows carry it (`GET /discovery/offering-lines`). [optionIds] go
/// straight back to `/discovery/offerings`.
class OfferingLine {
  final String key;
  final String label;
  final List<int> optionIds;
  final int offerings;

  const OfferingLine({required this.key, required this.label, required this.optionIds, required this.offerings});

  factory OfferingLine.fromJson(Map<String, dynamic> json) => OfferingLine(
    key: '${json['key']}',
    label: json['label'] as String? ?? '',
    optionIds: (json['option_ids'] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList(),
    offerings: (json['offerings'] as num?)?.toInt() ?? 0,
  );
}

/// One priced row across every shop of a specialty — «كشف عظام — 300 — مستشفى BIM».
class ChildOffering {
  final int id;
  final String source;
  final String label;
  final double price;
  final String currency;
  final String? imageUrl;
  final int businessId;
  final String businessName;
  final String? businessLogoUrl;

  const ChildOffering({
    required this.id,
    required this.source,
    required this.label,
    required this.price,
    required this.currency,
    this.imageUrl,
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
  });

  factory ChildOffering.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>? ?? const {};
    final own = json['own_name'] as String? ?? '';
    final label = json['label'] as String? ?? '';
    return ChildOffering(
      id: (json['id'] as num).toInt(),
      source: json['source'] as String? ?? '',
      label: label.isNotEmpty ? label : own,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      imageUrl: Env.assetUrl(json['image'] as String?),
      businessId: (business['id'] as num?)?.toInt() ?? 0,
      businessName: business['name'] as String? ?? '',
      businessLogoUrl: Env.assetUrl(business['logo'] as String?),
    );
  }
}
