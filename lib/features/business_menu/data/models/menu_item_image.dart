import '../../../../core/env/env.dart';

/// Which part of a photo a card shows: the point kept in the middle ([x], [y] in 0..1 across and down) and how far
/// in to go ([zoom], 1 = the whole photo). The default shows everything, centred — as before.
class PhotoCrop {
  final double x;
  final double y;
  final double zoom;
  const PhotoCrop({this.x = 0.5, this.y = 0.5, this.zoom = 1});

  static const whole = PhotoCrop();

  bool get isDefault => x == 0.5 && y == 0.5 && zoom == 1;

  factory PhotoCrop.fromJson(Object? json) {
    if (json is! Map) return whole;
    return PhotoCrop(
      x: (json['x'] as num?)?.toDouble() ?? 0.5,
      y: (json['y'] as num?)?.toDouble() ?? 0.5,
      zoom: (json['zoom'] as num?)?.toDouble() ?? 1,
    );
  }

  @override
  bool operator ==(Object other) => other is PhotoCrop && other.x == x && other.y == y && other.zoom == zoom;

  @override
  int get hashCode => Object.hash(x, y, zoom);
}

class MenuItemImage {
  final int id;
  final String url;

  /// 'camera' = a live shot; 'upload' = picked from the phone. Both are badged, for the merchant AND the customer.
  final String source;

  /// The photo the item's card shows (the merchant's choice; the first one until he chooses).
  final bool isCover;
  final PhotoCrop crop;

  const MenuItemImage({required this.id, required this.url, this.source = 'upload', this.isCover = false, this.crop = PhotoCrop.whole});

  bool get isFromCamera => source == 'camera';

  factory MenuItemImage.fromJson(Map<String, dynamic> json) => MenuItemImage(
    id: json['id'] as int,
    url: Env.assetUrl(json['image'] as String)!,
    source: json['source'] as String? ?? 'upload',
    isCover: json['is_cover'] as bool? ?? false,
    crop: PhotoCrop.fromJson(json['crop']),
  );
}
