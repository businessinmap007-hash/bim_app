import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../media/application/auto_watermark_service.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../../media/presentation/widgets/picked_media_tile.dart';
import '../../../settings/application/watermark_settings_controller.dart';
import '../../application/posts_controller.dart';

/// A new post — title/body plus photos, each auto-watermarked from the
/// same saved settings the media composer uses (Settings ->
/// "العلامة المائية"). Reuses MediaPickerService/PickedMediaTile so a
/// photo here picks and displays exactly like it does there.
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  // Mirrors PostController::store's `images` => max:10 validation.
  static const _maxImages = 10;

  final _pickerService = MediaPickerService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final List<PickedMedia> _items = [];
  bool _busy = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _addFromCamera() async {
    final media = await _pickerService.pickFromCamera();
    if (media != null) await _addAll([media]);
  }

  Future<void> _addFromGallery() async {
    final media = await _pickerService.pickFromGallery();
    if (media.isNotEmpty) await _addAll(media);
  }

  Future<void> _addAll(List<PickedMedia> picked) async {
    final room = _maxImages - _items.length;
    if (room <= 0) {
      _showMaxImagesNotice();
      return;
    }
    final accepted = picked.length > room ? picked.sublist(0, room) : picked;

    setState(() => _busy = true);
    try {
      final autoWatermark = ref.read(autoWatermarkServiceProvider);
      final processed = <PickedMedia>[];
      for (final media in accepted) {
        final original = await media.file.readAsBytes();
        final stamped = await autoWatermark.apply(original);
        processed.add(media.copyWith(processedBytes: stamped));
      }
      if (!mounted) return;
      setState(() => _items.addAll(processed));
      if (accepted.length < picked.length) _showMaxImagesNotice();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMaxImagesNotice() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.postsMaxImagesReached(_maxImages))));
  }

  void _remove(int index) => setState(() => _items.removeAt(index));

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    // The server requires a title whenever the post links no subject — which
    // this screen never sends — so title is effectively always required here
    // too, even though nothing in the UI used to say so.
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.validationRequired)));
      return;
    }

    setState(() => _busy = true);
    try {
      final images = <Uint8List>[];
      for (final item in _items) {
        images.add(item.processedBytes ?? await item.file.readAsBytes());
      }
      await ref.read(postsApiProvider).createPost(title: title, body: body, images: images);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final watermarkEnabled = ref.watch(watermarkSettingsControllerProvider).isEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postsCreateTitle),
        actions: [
          TextButton(
            onPressed: _busy ? null : _publish,
            child: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.postsPublish, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _titleController, decoration: InputDecoration(labelText: '${l10n.postsTitleLabel} *')),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 5,
            decoration: InputDecoration(labelText: '${l10n.postsBodyLabel} *'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _busy || _items.length >= _maxImages ? null : _addFromCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.mediaAddFromCamera),
              ),
              OutlinedButton.icon(
                onPressed: _busy || _items.length >= _maxImages ? null : _addFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.mediaAddFromGallery),
              ),
            ],
          ),
          if (!watermarkEnabled) ...[
            const SizedBox(height: 8),
            Text(l10n.mediaWatermarkDisabledHint, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) => PickedMediaTile(
                media: _items[index],
                onRemove: () => _remove(index),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
