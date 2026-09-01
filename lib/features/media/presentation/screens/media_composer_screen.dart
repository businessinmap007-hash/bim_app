import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/media_picker_service.dart';
import '../../application/watermark_service.dart';
import '../../data/picked_media.dart';
import '../widgets/picked_media_tile.dart';
import '../widgets/watermark_repeat_selector.dart';

/// Ties the media pieces together end to end: pick from camera/gallery
/// (each tagged with its source), review in an adaptive Instagram-style
/// grid, then stamp a repeating watermark across every picked photo.
///
/// Not wired into a real "create post" flow yet — there isn't one built in
/// this app to attach it to. This screen is the working proof that the
/// pieces (MediaPickerService, AdaptiveImageBox, WatermarkService) function
/// end to end; a real composer reuses them rather than rebuilding them.
class MediaComposerScreen extends StatefulWidget {
  const MediaComposerScreen({super.key});

  @override
  State<MediaComposerScreen> createState() => _MediaComposerScreenState();
}

class _MediaComposerScreenState extends State<MediaComposerScreen> {
  final _pickerService = const _LazyPicker();
  final _watermarkService = const WatermarkService();
  final _watermarkController = TextEditingController();

  final List<PickedMedia> _items = [];
  int _repeatCount = 6;
  bool _applyingWatermark = false;

  @override
  void dispose() {
    _watermarkController.dispose();
    super.dispose();
  }

  Future<void> _addFromCamera() async {
    final media = await _pickerService.service.pickFromCamera();
    if (media != null) setState(() => _items.add(media));
  }

  Future<void> _addFromGallery() async {
    final media = await _pickerService.service.pickFromGallery();
    if (media.isNotEmpty) setState(() => _items.addAll(media));
  }

  void _remove(int index) => setState(() => _items.removeAt(index));

  Future<void> _applyWatermark() async {
    final text = _watermarkController.text.trim();
    if (text.isEmpty || _items.isEmpty) return;

    setState(() => _applyingWatermark = true);
    try {
      final updated = <PickedMedia>[];
      for (final item in _items) {
        final sourceBytes = item.watermarkedBytes ?? await item.file.readAsBytes();
        final stamped = await _watermarkService.apply(
          imageBytes: sourceBytes,
          text: text,
          repeatCount: _repeatCount,
        );
        updated.add(item.copyWith(watermarkedBytes: stamped));
      }
      if (!mounted) return;
      setState(() => _items
        ..clear()
        ..addAll(updated));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mediaWatermarkApplied)),
      );
    } finally {
      if (mounted) setState(() => _applyingWatermark = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                onPressed: _addFromCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.mediaAddFromCamera),
              ),
              OutlinedButton.icon(
                onPressed: _addFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.mediaAddFromGallery),
              ),
            ],
          ),
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
              ),
            ),
          const SizedBox(height: 28),
          Text(l10n.mediaWatermarkTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _watermarkController,
            decoration: InputDecoration(
              labelText: l10n.mediaWatermarkText,
              hintText: l10n.mediaWatermarkTextHint,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.mediaWatermarkRepeatCount, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          WatermarkRepeatSelector(
            value: _repeatCount,
            onChanged: (value) => setState(() => _repeatCount = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_items.isEmpty || _applyingWatermark) ? null : _applyWatermark,
            child: _applyingWatermark
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.mediaWatermarkApply),
          ),
        ],
      ),
    );
  }
}

/// Constructing MediaPickerService touches platform channels (image_picker)
/// — defer that until the screen actually needs it rather than at field
/// initialization, so the screen still builds cleanly on a
/// widget-test/no-platform-channel environment.
class _LazyPicker {
  const _LazyPicker();
  MediaPickerService get service => MediaPickerService();
}
