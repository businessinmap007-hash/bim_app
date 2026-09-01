import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Where a picked photo came from — tracked from the moment it's picked so
/// the composer can show provenance (a camera badge vs a gallery badge) as
/// one signal toward "this is the photographer's own shot", not proof on
/// its own (EXIF can be stripped, a gallery photo can be a re-shared camera
/// shot) but still useful, cheap-to-show context.
enum MediaSource { camera, gallery }

/// One photo in a post/album composer, before upload. `watermarkedBytes` is
/// null until [WatermarkService] has run — callers upload that when set,
/// the original file otherwise.
class PickedMedia {
  final XFile file;
  final MediaSource source;
  final Uint8List? watermarkedBytes;

  const PickedMedia({required this.file, required this.source, this.watermarkedBytes});

  PickedMedia copyWith({Uint8List? watermarkedBytes}) {
    return PickedMedia(
      file: file,
      source: source,
      watermarkedBytes: watermarkedBytes ?? this.watermarkedBytes,
    );
  }
}
