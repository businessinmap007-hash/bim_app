import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// A full-width cover banner with a small edit badge — same take-photo/
/// gallery/remove sheet as [ProfileAvatarPicker], just shaped for a banner
/// instead of a circle.
class ProfileCoverPicker extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onRemove;
  final double height;

  const ProfileCoverPicker({
    super.key,
    required this.imageUrl,
    required this.onCamera,
    required this.onGallery,
    this.onRemove,
    this.height = 140,
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
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: height,
              color: AppColors.accentGold.withValues(alpha: 0.1),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: height,
                      errorWidget: (context, url, error) => const Icon(Icons.image_outlined),
                    )
                  : const Center(child: Icon(Icons.image_outlined)),
            ),
            PositionedDirectional(
              end: 10,
              bottom: 10,
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
      ),
    );
  }
}
