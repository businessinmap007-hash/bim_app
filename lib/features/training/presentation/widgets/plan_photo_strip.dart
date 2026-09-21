import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../data/models/training_plan.dart';
import '../screens/trainer_photo_library_screen.dart';

/// The trainer's photos for one exercise or meal: thumbnails with a delete
/// button, plus an "add photo" tile (camera or gallery).
///
/// These pictures are private to the trainer and the plan's trainee — the
/// server stores them outside the public web root and only the two parties
/// are handed a link — which the caption says, so a trainer knows where a
/// picture of a client's meal goes.
class PlanPhotoStrip extends StatefulWidget {
  final List<PlanImage> images;
  final Future<void> Function(List<Uint8List> photos) onAdd;
  final Future<void> Function(int imageId) onRemove;

  /// Attach photos the trainer already keeps in his library (copied into this
  /// plan). Null hides the option.
  final Future<void> Function(List<int> photoIds)? onAttachLibrary;

  /// Mirrors the server's per-item limit (TrainingPlanController::MAX_IMAGES).
  static const maxPhotos = 6;

  const PlanPhotoStrip({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.onAttachLibrary,
  });

  @override
  State<PlanPhotoStrip> createState() => _PlanPhotoStripState();
}

class _PlanPhotoStripState extends State<PlanPhotoStrip> {
  final _picker = MediaPickerService();
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context)!.commonSomethingWentWrong;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.mediaAddFromCamera),
              onTap: () => Navigator.pop(sheetContext, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.mediaAddFromGallery),
              onTap: () => Navigator.pop(sheetContext, 'gallery'),
            ),
            if (widget.onAttachLibrary != null)
              ListTile(
                leading: const Icon(Icons.collections_outlined),
                title: Text(l10n.trainingPhotoFromLibrary),
                onTap: () => Navigator.pop(sheetContext, 'library'),
              ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final room = PlanPhotoStrip.maxPhotos - widget.images.length;

    if (source == 'library') {
      final ids = await pickLibraryPhotos(context, maxCount: room);
      if (ids == null || ids.isEmpty || !mounted) return;
      await _run(() => widget.onAttachLibrary!(ids));
      return;
    }

    final List<PickedMedia> picked;
    if (source == 'camera') {
      final shot = await _picker.pickFromCamera();
      picked = shot == null ? const [] : [shot];
    } else {
      picked = await _picker.pickFromGallery();
    }
    if (picked.isEmpty || !mounted) return;

    final bytes = <Uint8List>[];
    for (final media in picked.take(room)) {
      bytes.add(await media.file.readAsBytes());
    }
    if (bytes.isEmpty) return;

    await _run(() => widget.onAdd(bytes));
  }

  Future<void> _remove(PlanImage image) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.trainingRemoveRowConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() => widget.onRemove(image.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canAdd = widget.images.length < PlanPhotoStrip.maxPhotos;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 72,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final image in widget.images)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image.url,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            cacheWidth: 216,
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 72,
                              height: 72,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          child: InkWell(
                            onTap: _busy ? null : () => _remove(image),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (canAdd)
                  InkWell(
                    onTap: _busy ? null : _add,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _busy
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined),
                                Text(
                                  l10n.trainingAddPhoto,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.images.isNotEmpty || canAdd) ...[
            const SizedBox(height: 4),
            Text(
              l10n.trainingPhotoPrivateHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
