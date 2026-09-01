import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/watermark_settings_controller.dart';
import 'watermark_service.dart';

final autoWatermarkServiceProvider = Provider<AutoWatermarkService>((ref) {
  return AutoWatermarkService(ref);
});

/// Applies the owner's saved watermark preferences (Settings ->
/// "العلامة المائية") to a freshly picked or freshly cropped photo. Returns
/// the source bytes unchanged when the watermark is off or no profile text
/// is available, so every call site can call this unconditionally instead
/// of branching on "is watermarking even enabled" itself.
class AutoWatermarkService {
  final Ref _ref;
  final WatermarkService _watermarkService;

  AutoWatermarkService(this._ref, {WatermarkService? watermarkService})
    : _watermarkService = watermarkService ?? const WatermarkService();

  Future<Uint8List> apply(Uint8List sourceBytes) async {
    final text = _ref.read(watermarkTextProvider);
    if (text == null) return sourceBytes;

    final repeatCount = _ref.read(watermarkSettingsControllerProvider).repeatCount;
    return _watermarkService.apply(imageBytes: sourceBytes, text: text, repeatCount: repeatCount);
  }
}
