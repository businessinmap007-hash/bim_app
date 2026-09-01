import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/albums_controller.dart';
import '../../data/models/album.dart';
import 'album_detail_screen.dart';

/// The signed-in account's own photo albums — a grid of covers, tap to open
/// one, "+" to create another.
class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  Future<void> _createAlbum(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileAlbumsAdd),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.profileAlbumsNewTitle),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.profileAlbumsCreate),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      await ref.read(albumsControllerProvider.notifier).create(title);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(albumsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileAlbumsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAlbum(context, ref),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(l10n.profileAlbumsAdd),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.albums.isEmpty
          ? Center(child: Text(l10n.profileAlbumsEmpty))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: state.albums.length,
              itemBuilder: (context, index) {
                final album = state.albums[index];
                return _AlbumCard(album: album);
              },
            ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final Album album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AlbumDetailScreen(albumId: album.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: album.coverUrl != null
                  ? CachedNetworkImage(imageUrl: album.coverUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.accentGold.withValues(alpha: 0.12),
                      child: const Icon(Icons.photo_album_outlined, size: 40, color: AppColors.accentGold),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(album.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${album.photosCount}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
