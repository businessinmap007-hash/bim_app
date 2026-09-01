import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Where a picked photo came from — tracked from the moment it's picked so
/// the composer can show provenance (a camera badge vs a gallery badge) as
/// one signal toward "this is the photographer's own shot", not proof on
/// its own (EXIF can be stripped, a gallery photo can be a re-shared camera
/// shot) but still useful, cheap-to-show context.
enum MediaSource { camera, gallery }

/// One photo in a post/album composer, before upload. [processedBytes] is
/// the result of crop and/or the saved watermark settings running against
/// the original file — null only in the instant before either has run.
/// Callers display/upload that when set, the original file otherwise.
/// Re-cropping always starts again from the original file, not from a
/// previously processed result, so repeated edits never compound quality
/// loss or stack the watermark on itself.
class PickedMedia {
  final XFile file;
  final MediaSource source;
  final Uint8List? processedBytes;

  const PickedMedia({required this.file, required this.source, this.processedBytes});

  PickedMedia copyWith({Uint8List? processedBytes}) {
    return PickedMedia(
      file: file,
      source: source,
      processedBytes: processedBytes ?? this.processedBytes,
    );
  }
}
