import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// A circular avatar with a small edit badge — tapping opens a sheet to take
/// a new photo, pick one from the gallery, or remove the current one.
class ProfileAvatarPicker extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onRemove;
  final double radius;

  const ProfileAvatarPicker({
    super.key,
    required this.imageUrl,
    required this.onCamera,
    required this.onGallery,
    this.onRemove,
    this.radius = 52,
  });

  void _openSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profilePhotoCamera),
              onTap: () {
                Navigator.pop(context);
                onCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profilePhotoGallery),
              onTap: () {
                Navigator.pop(context);
                onGallery();
              },
            ),
            if (onRemove != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text(
                  l10n.profilePhotoRemove,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRemove!();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Blended against white rather than the page background so the navy
    // icon's contrast stays the same in both themes — see the matching note
    // on profile_cover_header.dart's _Avatar.
    final placeholderFill = Color.alphaBlend(
      AppColors.accentGold.withValues(alpha: 0.15),
      Colors.white,
    );
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Stack(
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: placeholderFill,
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.person, color: AppColors.primaryNavy, size: radius),
                    )
                  : Icon(Icons.person, color: AppColors.primaryNavy, size: radius),
            ),
          ),
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryNavy,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
