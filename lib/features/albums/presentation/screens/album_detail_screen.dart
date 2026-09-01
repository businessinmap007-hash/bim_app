import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/adaptive_image_box.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../../media/presentation/widgets/media_source_badge.dart';
import '../../application/albums_controller.dart';
import '../../data/models/album.dart';

/// One album's photos — reuses AdaptiveImageBox + MediaSourceBadge from the
/// media composer so a photo here frames and badges exactly like one does
/// there, camera vs gallery provenance included.
class AlbumDetailScreen extends ConsumerStatefulWidget {
  final int albumId;
  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  final _picker = MediaPickerService();
  bool _uploading = false;
  Album? _album;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final album = await ref.read(albumsControllerProvider.notifier).loadDetail(widget.albumId);
    if (mounted) setState(() => _album = album);
  }

  Future<void> _addFrom(MediaSource source) async {
    PickedMedia? media;
    if (source == MediaSource.camera) {
      media = await _picker.pickFromCamera();
    } else {
      final picked = await _picker.pickFromGallery(allowMultiple: false);
      media = picked.isNotEmpty ? picked.first : null;
    }
    if (media == null) return;

    setState(() => _uploading = true);
    try {
      final updated = await ref
          .read(albumsControllerProvider.notifier)
          .addPhoto(
            albumId: widget.albumId,
            filePath: media.file.path,
            source: source == MediaSource.camera ? 'camera' : 'upload',
          );
      if (mounted) setState(() => _album = updated);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _removePhoto(int photoId) async {
    final updated = await ref
        .read(albumsControllerProvider.notifier)
        .removePhoto(albumId: widget.albumId, photoId: photoId);
    if (mounted) setState(() => _album = updated);
  }

  Future<void> _deleteAlbum() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileAlbumsDelete),
        content: Text(l10n.profileAlbumsDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.profileAlbumsDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(albumsControllerProvider.notifier).delete(widget.albumId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final album = _album;

    return Scaffold(
      appBar: AppBar(
        title: Text(album?.title ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteAlbum,
            tooltip: l10n.profileAlbumsDelete,
          ),
        ],
      ),
      body: album == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _uploading ? null : () => _addFrom(MediaSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.mediaAddFromCamera),
                      ),
                      OutlinedButton.icon(
                        onPressed: _uploading ? null : () => _addFrom(MediaSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(l10n.mediaAddFromGallery),
                      ),
                      if (_uploading) const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: album.photos.isEmpty
                        ? Center(child: Text(l10n.mediaEmpty))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: album.photos.length,
                            itemBuilder: (context, index) {
                              final photo = album.photos[index];
                              return AdaptiveImageBox(
                                imageProvider: NetworkImage(photo.imageUrl),
                                borderRadius: BorderRadius.circular(12),
                                overlays: [
                                  MediaSourceBadge(
                                    source: photo.isFromCamera ? MediaSource.camera : MediaSource.gallery,
                                  ),                                  PositionedDirectional(
                                    top: 8,
                                    start: 8,
                                    child: GestureDetector(
                                      onTap: () => _removePhoto(photo.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.55),
                                          shape: BoxShape.circle,
                                        ),                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
