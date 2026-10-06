import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// «علامة الكاميرا والجاليري تظهر للعميل أيضًا» — المالك، 2026-10-06. A small corner mark saying whether a product
/// photo was taken live with the camera or picked from the phone's gallery, so a customer knows which he is looking at.
/// (The album/composer badge takes a picked file's enum; this one takes what the server stored: `camera` or `upload`.)
class PhotoSourceBadge extends StatelessWidget {
  final String source;
  final double size;

  const PhotoSourceBadge({super.key, required this.source, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final camera = source == 'camera';

    return Tooltip(
      message: camera ? l10n.mediaCapturedByCamera : l10n.mediaFromGallery,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
        child: Icon(camera ? Icons.photo_camera_rounded : Icons.photo_library_rounded, color: Colors.white, size: size),
      ),
    );
  }
}
