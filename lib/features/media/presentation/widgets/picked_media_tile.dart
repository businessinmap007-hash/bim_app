import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/adaptive_image_box.dart';
import '../../data/picked_media.dart';
import 'media_source_badge.dart';

/// One photo in the composer review grid — adaptive Instagram-style sizing,
/// a source badge (camera vs gallery), and crop/remove actions. Shows
/// [PickedMedia.processedBytes] once set (crop and/or watermark applied),
/// the original file otherwise.
class PickedMediaTile extends StatelessWidget {
  final PickedMedia media;
  final VoidCallback? onRemove;
  final VoidCallback? onCrop;
  final BorderRadius borderRadius;

  const PickedMediaTile({
    super.key,
    required this.media,
    this.onRemove,
    this.onCrop,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (media.processedBytes != null) {
      return _buildBox(context, MemoryImage(media.processedBytes!), l10n: l10n);
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

  Widget _buildBox(BuildContext context, ImageProvider provider, {required AppLocalizations l10n}) {
    return AdaptiveImageBox(
      imageProvider: provider,
      borderRadius: borderRadius,
      overlays: [
        MediaSourceBadge(source: media.source),
        if (onRemove != null)
          PositionedDirectional(
            top: 8,
            start: 8,
            child: _RoundIconButton(icon: Icons.close_rounded, tooltip: l10n.mediaRemove, onTap: onRemove!),
          ),
        if (onCrop != null)
          PositionedDirectional(
            bottom: 8,
            end: 8,
            child: _RoundIconButton(icon: Icons.crop_rounded, tooltip: l10n.mediaCrop, onTap: onCrop!),
          ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
