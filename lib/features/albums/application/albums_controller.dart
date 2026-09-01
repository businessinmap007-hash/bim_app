import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/album_api.dart';
import '../data/models/album.dart';

final albumApiProvider = Provider<AlbumApi>((ref) {
  return AlbumApi(ref.watch(apiClientProvider));
});

class AlbumsState {
  final List<Album> albums;
  final bool isLoading;
  final String? error;

  const AlbumsState({
    this.albums = const [],
    this.isLoading = false,
    this.error,
  });

  AlbumsState copyWith({
    List<Album>? albums,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AlbumsState(
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// The signed-in account's own albums — list + the actions that mutate one
/// (create, add/remove a photo, delete), each just replacing that album's
/// row in [albums] with what the backend actually returned rather than
/// guessing the new state locally.
class AlbumsController extends StateNotifier<AlbumsState> {
  final AlbumApi _api;

  AlbumsController(this._api) : super(const AlbumsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final albums = await _api.list();
      state = state.copyWith(albums: albums, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create(String title) async {
    try {
      final album = await _api.create(titleAr: title);
      state = state.copyWith(albums: [album, ...state.albums]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Album> addPhoto({
    required int albumId,
    required String filePath,
    required String source,
  }) async {
    try {
      final updated = await _api.addPhoto(
        albumId: albumId,
        filePath: filePath,
        source: source,
      );
      _replace(updated);
      return updated;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<Album> removePhoto({
    required int albumId,
    required int photoId,
  }) async {
    try {
      final updated = await _api.removePhoto(
        albumId: albumId,
        photoId: photoId,
      );
      _replace(updated);
      return updated;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> delete(int albumId) async {
    try {
      await _api.delete(albumId);
      state = state.copyWith(
        albums: state.albums.where((a) => a.id != albumId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Fetches one album's full detail (with photos) and merges it into the
  /// list — the plain list endpoint never includes `photos`.
  Future<Album> loadDetail(int albumId) async {
    final detail = await _api.show(albumId);
    _replace(detail);
    return detail;
  }

  void _replace(Album updated) {
    state = state.copyWith(
      albums: [
        for (final a in state.albums)
          if (a.id == updated.id) updated else a,
      ],
    );
  }
}

final albumsControllerProvider =
    StateNotifierProvider<AlbumsController, AlbumsState>((ref) {
      return AlbumsController(ref.watch(albumApiProvider));
    });
