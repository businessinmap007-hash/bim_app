import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/picked_media.dart';

/// A small corner badge marking whether a picked photo came from the
/// camera or the gallery — hover/tap surfaces the same fact as a message,
/// so a viewer squinting at a small icon on mobile isn't left guessing.
class MediaSourceBadge extends StatelessWidget {
  final MediaSource source;

  const MediaSourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCamera = source == MediaSource.camera;
    final message = isCamera ? l10n.mediaCapturedByCamera : l10n.mediaFromGallery;

    return PositionedDirectional(
      top: 8,
      end: 8,
      child: Tooltip(
        message: message,
        triggerMode: TooltipTriggerMode.tap,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCamera ? Icons.photo_camera_rounded : Icons.photo_library_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
