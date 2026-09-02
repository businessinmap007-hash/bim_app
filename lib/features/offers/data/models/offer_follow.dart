/// A saved alert — «notify me about offers from this business». Only the
/// `business` followable_type is exposed in this app; OfferFollow also
/// supports keyword/category_child/product/service/etc alerts, but those
/// need their own alert-builder screen this pass doesn't build.
class OfferFollow {
  final int id;
  final String followableType;
  final int followableId;

  const OfferFollow({required this.id, required this.followableType, required this.followableId});

  factory OfferFollow.fromJson(Map<String, dynamic> json) => OfferFollow(
    id: json['id'] as int,
    followableType: json['followable_type'] as String? ?? '',
    followableId: (json['followable_id'] as num?)?.toInt() ?? 0,
  );
}
