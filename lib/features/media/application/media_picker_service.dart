import 'package:image_picker/image_picker.dart';

import '../data/picked_media.dart';

/// Wraps `image_picker` so every call site tags the result with where it
/// came from — the ordinary `image_picker` API returns just a file, with
/// no memory of which button the user tapped.
class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<PickedMedia?> pickFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (file == null) return null;
    return PickedMedia(file: file, source: MediaSource.camera);
  }

  Future<List<PickedMedia>> pickFromGallery({bool allowMultiple = true}) async {
    if (!allowMultiple) {
      final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (file == null) return const [];
      return [PickedMedia(file: file, source: MediaSource.gallery)];
    }
    final files = await _picker.pickMultiImage(imageQuality: 90);
    return files.map((f) => PickedMedia(file: f, source: MediaSource.gallery)).toList();
  }
}
