import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/album.dart';

/// GET/POST/PATCH/DELETE /profile/albums[/…] — always the caller's OWN
/// albums (Api\V2\AlbumController re-checks ownership on every route even
/// though route-model-binding would resolve any album id).
class AlbumApi {
  final ApiClient _client;

  const AlbumApi(this._client);

  Future<List<Album>> list() async {
    final data = await _client.get('/profile/albums') as List<dynamic>;
    return data.map((e) => Album.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Album> create({required String titleAr, String? titleEn}) async {
    final data = await _client.post(
      '/profile/albums',
      data: {'title_ar': titleAr, 'title_en': ?titleEn},
    );
    return Album.fromJson(data as Map<String, dynamic>);
  }

  Future<Album> show(int albumId) async {
    final data = await _client.get('/profile/albums/$albumId');
    return Album.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int albumId) =>
      _client.delete('/profile/albums/$albumId');

  /// [source] is 'camera' | 'upload' — Image::SOURCE_CAMERA/SOURCE_UPLOAD on
  /// the backend, the same provenance signal the media composer already
  /// tags a picked photo with.
  Future<Album> addPhoto({
    required int albumId,
    required String filePath,
    required String source,
  }) async {
    final data = await _client.post(
      '/profile/albums/$albumId/photos',
      data: FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
        'source': source,
      }),
    );
    return Album.fromJson(data as Map<String, dynamic>);
  }

  Future<Album> removePhoto({
    required int albumId,
    required int photoId,
  }) async {
    final data = await _client.delete(
      '/profile/albums/$albumId/photos/$photoId',
    );
    return Album.fromJson(data as Map<String, dynamic>);
  }
}
