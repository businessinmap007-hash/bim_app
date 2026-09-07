import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../albums/application/albums_controller.dart';
import '../../../albums/data/models/album.dart';
import '../../application/business_page_providers.dart';
import '../../data/models/business_profile.dart';

/// "Who is this business" — phone, governorate/city, social links, and its
/// photo album, gathered on one screen instead of scattered (or, until
/// social links were added 2026-09-04, simply missing) across the public
/// business page.
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

  Future<void> _openSocial(BuildContext context, String value) async {
    final l10n = AppLocalizations.of(context)!;
    final url = value.startsWith('http://') || value.startsWith('https://') ? value : 'https://$value';
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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

    final rows = <Widget>[
      if (profile.address != null)
        _InfoRow(icon: Icons.home_outlined, label: l10n.businessInfoAddress, value: profile.address!),
      if (profile.phone != null && profile.phone!.isNotEmpty)
        _InfoRow(
          icon: Icons.call_outlined,
          label: l10n.businessInfoPhone,
          value: profile.phone!,
          onTap: () => _call(context),
        ),
      if (profile.country != null)
        _InfoRow(
          icon: Icons.flag_outlined,
          label: l10n.businessInfoCountry,
          value: profile.country!.localizedName(languageCode),
        ),
      if (placeLine.isNotEmpty || profile.hasLocation)
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: l10n.businessInfoLocation,
          value: placeLine.isNotEmpty ? placeLine : l10n.businessInfoOpenInMaps,
          onTap: profile.hasLocation ? () => _openInMaps(context) : null,
          trailing: profile.hasLocation
              ? Icon(Icons.open_in_new, size: 18, color: Theme.of(context).hintColor)
              : null,
        ),
      if (profile.categoryName != null)
        _InfoRow(
          icon: Icons.category_outlined,
          label: l10n.profileCategory,
          value: profile.categoryName!.localizedName(languageCode),
        ),
      if (profile.categoryChildName != null)
        _InfoRow(
          icon: Icons.storefront_outlined,
          label: l10n.profileSpecialty,
          value: profile.categoryChildName!.localizedName(languageCode),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              rows[i],
            ],
          ],
        ),
        if (profile.options.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(l10n.businessFilterByAttributes, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.options
                .map((o) => Chip(label: Text(o.localizedName(languageCode))))
                .toList(),
          ),
        ],
        if (profile.social != null && !profile.social!.isEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (profile.social!.facebook != null)
                _SocialIconButton(
                  icon: Icons.facebook,
                  onTap: () => _openSocial(context, profile.social!.facebook!),
                ),
              if (profile.social!.instagram != null)
                _SocialIconButton(
                  icon: Icons.camera_alt_outlined,
                  onTap: () => _openSocial(context, profile.social!.instagram!),
                ),
              if (profile.social!.twitter != null)
                _SocialIconButton(
                  icon: Icons.alternate_email,
                  onTap: () => _openSocial(context, profile.social!.twitter!),
                ),
              if (profile.social!.youtube != null)
                _SocialIconButton(
                  icon: Icons.play_circle_outline,
                  onTap: () => _openSocial(context, profile.social!.youtube!),
                ),
              if (profile.social!.linkedin != null)
                _SocialIconButton(
                  icon: Icons.business_center_outlined,
                  onTap: () => _openSocial(context, profile.social!.linkedin!),
                ),
            ],
          ),
        ],
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

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
          ),
          child: Icon(icon, color: AppColors.primaryNavy),
        ),
      ),
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
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: albums.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _AlbumTile(businessId: businessId, album: albums[index]),
            ),
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
