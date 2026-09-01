import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/watermark_settings_controller.dart';
import '../../application/auto_watermark_service.dart';
import '../../application/media_picker_service.dart';
import '../../data/picked_media.dart';
import '../widgets/picked_media_tile.dart';
import 'image_cropper_screen.dart';

/// Ties the media pieces together end to end: pick from camera/gallery
/// (each tagged with its source), crop if needed, review in an adaptive
/// Instagram-style grid — with the owner's saved watermark (Settings ->
/// "العلامة المائية") stamped on automatically, nothing retyped per photo.
///
/// Not wired into a real "create post" flow yet — there isn't one built in
/// this app to attach it to. This screen is the working proof that the
/// pieces (MediaPickerService, AdaptiveImageBox, ImageCropperScreen,
/// AutoWatermarkService) function end to end; a real composer reuses them
/// rather than rebuilding them.
class MediaComposerScreen extends ConsumerStatefulWidget {
  const MediaComposerScreen({super.key});

  @override
  ConsumerState<MediaComposerScreen> createState() => _MediaComposerScreenState();
}

class _MediaComposerScreenState extends ConsumerState<MediaComposerScreen> {
  final _pickerService = MediaPickerService();
  final List<PickedMedia> _items = [];
  bool _busy = false;

  Future<void> _addFromCamera() async {
    final media = await _pickerService.pickFromCamera();
    if (media != null) await _addAll([media]);
  }

  Future<void> _addFromGallery() async {
    final media = await _pickerService.pickFromGallery();
    if (media.isNotEmpty) await _addAll(media);
  }

  Future<void> _addAll(List<PickedMedia> picked) async {
    setState(() => _busy = true);
    try {
      final autoWatermark = ref.read(autoWatermarkServiceProvider);
      final processed = <PickedMedia>[];
      for (final media in picked) {
        final original = await media.file.readAsBytes();
        final stamped = await autoWatermark.apply(original);
        processed.add(media.copyWith(processedBytes: stamped));
      }
      if (!mounted) return;
      setState(() => _items.addAll(processed));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _remove(int index) => setState(() => _items.removeAt(index));

  Future<void> _crop(int index) async {
    final media = _items[index];
    final original = await media.file.readAsBytes();
    if (!mounted) return;

    final croppedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => ImageCropperScreen(imageBytes: original)),
    );
    if (croppedBytes == null) return;

    setState(() => _busy = true);
    try {
      final stamped = await ref.read(autoWatermarkServiceProvider).apply(croppedBytes);
      if (!mounted) return;
      setState(() => _items[index] = media.copyWith(processedBytes: stamped));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final watermarkEnabled = ref.watch(watermarkSettingsControllerProvider).isEnabled;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mediaComposerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _addFromCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.mediaAddFromCamera),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _addFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.mediaAddFromGallery),
              ),
            ],
          ),
          if (!watermarkEnabled) ...[
            const SizedBox(height: 16),
            _WatermarkOffBanner(onOpenSettings: () => context.push('/settings')),
          ],
          const SizedBox(height: 20),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(l10n.mediaEmpty, style: Theme.of(context).textTheme.bodyMedium),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) => PickedMediaTile(
                media: _items[index],
                onRemove: () => _remove(index),
                onCrop: () => _crop(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _WatermarkOffBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _WatermarkOffBanner({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.mediaWatermarkDisabledHint, style: Theme.of(context).textTheme.bodySmall)),
          TextButton(onPressed: onOpenSettings, child: Text(l10n.mediaWatermarkOpenSettings)),
        ],
      ),
    );
  }
}
