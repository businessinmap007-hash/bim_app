import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'full_screen_gallery.dart';

/// The shape of a profile cover — width over height. The header draws the cover in it, the edit screen's preview is it,
/// and the cover crop screen frames it: what is framed is what shows. (2.5 : 1 — about 160dp tall on a phone.)
const kCoverAspect = 2.5;

/// Cover photo with a circular avatar overlapping its bottom edge — the
/// standard profile header (Facebook/Twitter-style). Used for both business
/// and (later) customer profile screens so the look stays consistent.
///
/// `AlignmentDirectional` is used instead of a hard left/right so the
/// overlap sits at the reading-start side in both RTL and LTR.
class ProfileCoverHeader extends StatelessWidget {
  final String? coverImageUrl;
  final String? avatarImageUrl;
  final String title;
  final String? subtitle;
  /// Fixed height; by default the cover keeps the shape [kCoverAspect] at the width it is given (capped on wide screens).
  final double? coverHeight;
  final double avatarRadius;

  const ProfileCoverHeader({
    super.key,
    required this.coverImageUrl,
    required this.avatarImageUrl,
    required this.title,
    this.subtitle,
    this.coverHeight,
    this.avatarRadius = 40,
  });

  Widget _opens(BuildContext context, String? url, Widget child) {
    if (url == null) return child;

    return GestureDetector(onTap: () => FullScreenGallery.show(context, urls: [url]), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;

        return _buildHeader(context, coverHeight ?? (width / kCoverAspect).clamp(110.0, 240.0).toDouble());
      },
    );
  }

  Widget _buildHeader(BuildContext context, double coverHeight) {
    final overlap = avatarRadius * 0.7;

    return Padding(
      padding: EdgeInsets.only(bottom: overlap + 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tapping the cover or the picture opens it in the app's one photo viewer.
          _opens(context, coverImageUrl, _Cover(imageUrl: coverImageUrl, height: coverHeight)),
          PositionedDirectional(
            start: 20,
            top: coverHeight - avatarRadius,
            child: _opens(context, avatarImageUrl, _Avatar(imageUrl: avatarImageUrl, radius: avatarRadius)),
          ),
          PositionedDirectional(
            start: 20 + avatarRadius * 2 + 16,
            top: coverHeight + 4,
            end: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? imageUrl;
  final double height;
  const _Cover({required this.imageUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const _CoverPlaceholder(),
            )
          : const _CoverPlaceholder(),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryNavy, AppColors.primaryNavyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  const _Avatar({required this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    // A fixed pale-gold fill (blended against white, not the page
    // background) so the navy icon's contrast stays the same in both
    // themes — an alpha-blended gold over a dark scaffold turns muted
    // dark-brown, and navy-on-that was nearly invisible in dark mode.
    final placeholderFill = Color.alphaBlend(
      AppColors.accentGold.withValues(alpha: 0.15),
      Colors.white,
    );

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 3,
        ),
        color: placeholderFill,
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primaryNavy,
                  size: radius,
                ),
              )
            : Icon(
                Icons.storefront_outlined,
                color: AppColors.primaryNavy,
                size: radius,
              ),
      ),
    );
  }
}
