import '../../../../core/env/env.dart';

/// One photo inside an album — mirrors AlbumController::detail()'s
/// `photos[]`. `source` matches the app's own MediaSource ('camera' |
/// 'upload') from Image::SOURCE_CAMERA/SOURCE_UPLOAD on the backend.
class AlbumPhoto {
  final int id;
  final String imageUrl;
  final String source;

  const AlbumPhoto({required this.id, required this.imageUrl, required this.source});

  bool get isFromCamera => source == 'camera';

  factory AlbumPhoto.fromJson(Map<String, dynamic> json) => AlbumPhoto(
    id: json['id'] as int,
    imageUrl: Env.assetUrl(json['image'] as String?) ?? '',
    source: json['source'] as String? ?? 'upload',
  );
}

/// One of the signed-in account's own albums — never someone else's, same
/// privacy shape as the rest of the profile. Mirrors
/// Api\V2\AlbumController's summary()/detail() shapes; `photos` is only
/// populated by the detail (show/create/addPhoto/removePhoto) responses,
/// not the plain list.
class Album {
  final int id;
  final String? title;
  final String? description;
  final String? coverUrl;
  final int photosCount;
  final List<AlbumPhoto> photos;

  const Album({
    required this.id,
    this.title,
    this.description,
    this.coverUrl,
    required this.photosCount,
    this.photos = const [],
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    id: json['id'] as int,
    title: json['title'] as String?,
    description: json['description'] as String?,
    coverUrl: Env.assetUrl(json['cover'] as String?),
    photosCount: (json['photos_count'] as num?)?.toInt() ?? 0,
    photos: (json['photos'] as List<dynamic>? ?? [])
        .map((e) => AlbumPhoto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
