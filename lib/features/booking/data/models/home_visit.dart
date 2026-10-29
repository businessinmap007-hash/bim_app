/// «أحتاج فنيًا» on its visit booking: the address the customer sent the technician to (copied when he chose, so a later
/// edit of his address book never moves it) and signed links to the photos of the problem. Read by the two of them only.
class HomeVisit {
  final String? addressLine;
  final double? lat;
  final double? lng;
  final List<String> photos;

  const HomeVisit({
    this.addressLine,
    this.lat,
    this.lng,
    this.photos = const [],
  });

  bool get hasPin => lat != null && lng != null;

  static HomeVisit? fromJsonOrNull(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final address = json['address'] is Map<String, dynamic>
        ? json['address'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return HomeVisit(
      addressLine: address['line'] as String?,
      lat: (address['lat'] as num?)?.toDouble(),
      lng: (address['lng'] as num?)?.toDouble(),
      photos: [
        for (final p in json['photos'] as List<dynamic>? ?? const []) '$p',
      ],
    );
  }
}
