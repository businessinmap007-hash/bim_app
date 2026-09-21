import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../application/business_training_providers.dart';
import '../../application/training_providers.dart';
import '../../data/models/set_log.dart';

/// The trainer's private photo library — the machine, the grip, the plated
/// meal — kept once and attached to as many clients' exercises as he likes.
/// Only he (and a training delegate of his gym) sees it; a client only ever
/// sees a copy attached to their own plan.
class TrainerPhotoLibraryScreen extends ConsumerStatefulWidget {
  const TrainerPhotoLibraryScreen({super.key});

  @override
  ConsumerState<TrainerPhotoLibraryScreen> createState() => _TrainerPhotoLibraryScreenState();
}

class _TrainerPhotoLibraryScreenState extends ConsumerState<TrainerPhotoLibraryScreen> {
  final _picker = MediaPickerService();
  bool _busy = false;

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final camera = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.mediaAddFromCamera),
              onTap: () => Navigator.pop(sheetContext, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.mediaAddFromGallery),
              onTap: () => Navigator.pop(sheetContext, false),
            ),
          ],
        ),
      ),
    );
    if (camera == null) return;

    final List<PickedMedia> picked;
    if (camera) {
      final shot = await _picker.pickFromCamera();
      picked = shot == null ? const [] : [shot];
    } else {
      picked = await _picker.pickFromGallery();
    }
    if (picked.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      final bytes = [for (final m in picked.take(10)) await m.file.readAsBytes()];
      await ref.read(trainingApiProvider).addTrainerPhotos(bytes);
      ref.invalidate(trainerPhotosProvider);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(LibraryPhoto photo) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.trainingPhotoLibraryDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(trainingApiProvider).deleteTrainerPhoto(photo.id);
      ref.invalidate(trainerPhotosProvider);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photos = ref.watch(trainerPhotosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingPhotoLibrary)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        icon: _busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.trainingAddPhoto),
      ),
      body: photos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => ref.invalidate(trainerPhotosProvider), child: Text(l10n.commonRetry)),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.trainingPhotoLibraryEmpty, textAlign: TextAlign.center),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 140,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => _PhotoTile(photo: items[i], trailing: _DeleteButton(onTap: () => _delete(items[i]))),
              ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      padding: const EdgeInsets.all(3),
      child: const Icon(Icons.close, size: 16, color: Colors.white),
    ),
  );
}

class _PhotoTile extends StatelessWidget {
  final LibraryPhoto photo;
  final bool selected;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _PhotoTile({required this.photo, this.selected = false, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              cacheWidth: 420,
              errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
          if (selected)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.primary, width: 3),
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
              ),
              child: const Align(alignment: Alignment.topRight, child: Icon(Icons.check_circle, color: Colors.white)),
            ),
          if (trailing != null) PositionedDirectional(top: 4, end: 4, child: trailing!),
        ],
      ),
    );
  }
}

/// Opens the library so the trainer can tick photos to attach to an exercise
/// or meal. Returns the chosen photo ids, or null when dismissed.
Future<List<int>?> pickLibraryPhotos(BuildContext context, {required int maxCount}) {
  return showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _LibraryPickerSheet(maxCount: maxCount),
  );
}

class _LibraryPickerSheet extends ConsumerStatefulWidget {
  final int maxCount;
  const _LibraryPickerSheet({required this.maxCount});

  @override
  ConsumerState<_LibraryPickerSheet> createState() => _LibraryPickerSheetState();
}

class _LibraryPickerSheetState extends ConsumerState<_LibraryPickerSheet> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photos = ref.watch(trainerPhotosProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.trainingPhotoPickTitle, style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: photos.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
              data: (items) => items.isEmpty
                  ? Center(child: Text(l10n.trainingPhotoLibraryEmpty))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 120,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final photo = items[i];
                        return _PhotoTile(
                          photo: photo,
                          selected: _selected.contains(photo.id),
                          onTap: () => setState(() {
                            if (!_selected.remove(photo.id) && _selected.length < widget.maxCount) {
                              _selected.add(photo.id);
                            }
                          }),
                        );
                      },
                    ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.isEmpty ? null : () => Navigator.of(context).pop(_selected.toList()),
                  child: Text(l10n.trainingPhotoAttach(_selected.length)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
