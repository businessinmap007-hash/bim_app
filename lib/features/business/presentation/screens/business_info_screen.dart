import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../albums/application/albums_controller.dart';
import '../../../albums/data/models/album.dart';
import '../../application/business_page_providers.dart';
import '../../data/models/business_profile.dart';

/// "Who is this business" — phone, governorate/city, and its photo album,
/// gathered on one screen instead of scattered (or, until now, simply
/// missing) across the public business page. Social-media links aren't
/// here yet: there's no such field on a business account at all today, a
/// separate feature to add deliberately rather than fake with dead icons.
class BusinessInfoScreen extends ConsumerWidget {
  final int businessId;
  const BusinessInfoScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(businessProfileProvider(businessId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessInfoTitle)),
      body: AsyncValueView(
        value: profileAsync,
        onRetry: () => ref.invalidate(businessProfileProvider(businessId)),
        builder: (context, profile) => _BusinessInfoBody(profile: profile),
      ),
    );
  }
}

class _BusinessInfoBody extends ConsumerWidget {
  final BusinessProfile profile;
  const _BusinessInfoBody({required this.profile});

  Future<void> _call(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri(scheme: 'tel', path: profile.phone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  Future<void> _openInMaps(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${profile.latitude},${profile.longitude}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    final placeLine = [
      profile.governorate?.localizedName(languageCode),
      profile.city?.localizedName(languageCode),
    ].whereType<String>().where((s) => s.isNotEmpty).join(' — ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          children: [
            if (profile.phone != null && profile.phone!.isNotEmpty)
              _InfoRow(
                icon: Icons.call_outlined,
                label: l10n.businessInfoPhone,
                value: profile.phone!,
                onTap: () => _call(context),
              ),
            if (placeLine.isNotEmpty || profile.hasLocation) ...[
              if (profile.phone != null && profile.phone!.isNotEmpty) const Divider(height: 1),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: l10n.businessInfoLocation,
                value: placeLine.isNotEmpty ? placeLine : l10n.businessInfoOpenInMaps,
                onTap: profile.hasLocation ? () => _openInMaps(context) : null,
                trailing: profile.hasLocation
                    ? Icon(Icons.open_in_new, size: 18, color: Theme.of(context).hintColor)
                    : null,
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Text(l10n.businessInfoAlbums, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _AlbumsSection(businessId: profile.id),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _InfoRow({required this.icon, required this.label, required this.value, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.hintColor),
      title: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      subtitle: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _AlbumsSection extends ConsumerWidget {
  final int businessId;
  const _AlbumsSection({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final albumsAsync = ref.watch(businessAlbumsProvider(businessId));

    return albumsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
      error: (_, _) => Text(l10n.commonSomethingWentWrong, style: TextStyle(color: Theme.of(context).hintColor)),
      data: (albums) {
        if (albums.isEmpty) {
          return Text(l10n.businessInfoNoAlbums, style: TextStyle(color: Theme.of(context).hintColor));
        }
        return SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _AlbumTile(businessId: businessId, album: albums[index]),
          ),
        );
      },
    );
  }
}

class _AlbumTile extends StatelessWidget {
  final int businessId;
  final Album album;
  const _AlbumTile({required this.businessId, required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BusinessAlbumViewerScreen(businessId: businessId, albumId: album.id)),
      ),
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 96,
                height: 96,
                color: AppColors.accentGold.withValues(alpha: 0.12),
                child: album.coverUrl != null
                    ? CachedNetworkImage(imageUrl: album.coverUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.photo_library_outlined),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              album.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// One album's photos, read-only — a simple grid + full-screen tap, unlike
/// the owner's own [AlbumDetailScreen] which also uploads/deletes.
class BusinessAlbumViewerScreen extends ConsumerWidget {
  final int businessId;
  final int albumId;
  const BusinessAlbumViewerScreen({super.key, required this.businessId, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(businessAlbumProvider((businessId: businessId, albumId: albumId)));

    return Scaffold(
      appBar: AppBar(title: Text(albumAsync.valueOrNull?.title ?? '')),
      body: AsyncValueView(
        value: albumAsync,
        onRetry: () => ref.invalidate(businessAlbumProvider((businessId: businessId, albumId: albumId))),
        builder: (context, album) {
          if (album.photos.isEmpty) {
            return const Center(child: Icon(Icons.photo_library_outlined, size: 48));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: album.photos.length,
            itemBuilder: (context, index) {
              final photo = album.photos[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _FullScreenPhoto(urls: album.photos.map((p) => p.imageUrl).toList(), initialIndex: index),
                    fullscreenDialog: true,
                  ),
                ),
                child: CachedNetworkImage(imageUrl: photo.imageUrl, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }
}

class _FullScreenPhoto extends StatelessWidget {
  final List<String> urls;
  final int initialIndex;
  const _FullScreenPhoto({required this.urls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: urls.length,
        itemBuilder: (context, index) => InteractiveViewer(
          child: SizedBox.expand(
            child: Image(image: CachedNetworkImageProvider(urls[index]), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
