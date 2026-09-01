import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/adaptive_image_box.dart';
import '../../data/picked_media.dart';
import 'media_source_badge.dart';

/// One photo in the composer review grid — adaptive Instagram-style sizing,
/// a source badge (camera vs gallery), and a remove button. Shows
/// [PickedMedia.watermarkedBytes] once set, the original file otherwise.
class PickedMediaTile extends StatelessWidget {
  final PickedMedia media;
  final VoidCallback? onRemove;
  final BorderRadius borderRadius;

  const PickedMediaTile({
    super.key,
    required this.media,
    this.onRemove,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (media.watermarkedBytes != null) {
      return _buildBox(context, MemoryImage(media.watermarkedBytes!));
    }

    return FutureBuilder<Uint8List>(
      future: media.file.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AspectRatio(
            aspectRatio: AdaptiveImageBox.minRatio,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return _buildBox(context, MemoryImage(snapshot.data!), l10n: l10n);
      },
    );
  }

  Widget _buildBox(BuildContext context, ImageProvider provider, {AppLocalizations? l10n}) {
    final loc = l10n ?? AppLocalizations.of(context)!;

    return AdaptiveImageBox(
      imageProvider: provider,
      borderRadius: borderRadius,
      overlays: [
        MediaSourceBadge(source: media.source),
        if (onRemove != null)
          PositionedDirectional(
            top: 8,
            start: 8,
            child: Tooltip(
              message: loc.mediaRemove,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
