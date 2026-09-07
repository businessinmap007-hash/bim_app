import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/business_post.dart';
import '../../../media/application/auto_watermark_service.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../../media/presentation/widgets/picked_media_tile.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../settings/application/watermark_settings_controller.dart';
import '../../application/posts_controller.dart';

/// Editing title/body is always allowed; the gallery is replace-only — see
/// PostsApi.updatePost's doc comment for why there's no partial "keep this
/// one, drop that one" middle ground on the wire. Starts showing the
/// existing photos read-only; "Replace photos" switches to the same
/// camera/gallery picker CreatePostScreen uses, and from then on saving
/// sends that new set in place of the old one.
class EditPostScreen extends ConsumerStatefulWidget {
  final BusinessPost post;
  const EditPostScreen({super.key, required this.post});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _pickerService = MediaPickerService();
  late final _titleController = TextEditingController(text: widget.post.title);
  late final _bodyController = TextEditingController(text: widget.post.body);
  final List<PickedMedia> _newItems = [];
  bool _replacingPhotos = false;
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
      setState(() => _newItems.addAll(processed));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _removeNew(int index) => setState(() => _newItems.removeAt(index));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.validationRequired)));
      return;
    }

    setState(() => _busy = true);
    try {
      List<Uint8List>? replaceImages;
      if (_replacingPhotos) {
        replaceImages = [];
        for (final item in _newItems) {
          replaceImages.add(item.processedBytes ?? await item.file.readAsBytes());
        }
      }
      await ref
          .read(postsApiProvider)
          .updatePost(widget.post.id, title: title, body: body, replaceImages: replaceImages);
      ref.read(myPostsControllerProvider.notifier).load();
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
    final currentImages = widget.post.images.isNotEmpty
        ? widget.post.images
        : (widget.post.imageUrl != null ? [PostImage(id: 0, url: widget.post.imageUrl!)] : const <PostImage>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postsEditTitle),
        actions: [
          TextButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                  )
                : Text(
                    l10n.postsSaveChanges,
                    style: TextStyle(
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
          if (!_replacingPhotos) ...[
            if (currentImages.isNotEmpty)
              SizedBox(
                height: 90,
                child: MouseWheelHorizontalScroll(
                  builder: (context, controller) => ListView.separated(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: currentImages.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(currentImages[index].url, width: 90, height: 90, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _replacingPhotos = true),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.postsReplacePhotos),
            ),
          ] else ...[
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
            TextButton(
              onPressed: () => setState(() {
                _replacingPhotos = false;
                _newItems.clear();
              }),
              child: Text(l10n.postsKeepCurrentPhotos),
            ),
            if (!watermarkEnabled) ...[
              const SizedBox(height: 8),
              Text(l10n.mediaWatermarkDisabledHint, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (_newItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _newItems.length,
                itemBuilder: (context, index) => PickedMediaTile(
                  media: _newItems[index],
                  onRemove: () => _removeNew(index),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
