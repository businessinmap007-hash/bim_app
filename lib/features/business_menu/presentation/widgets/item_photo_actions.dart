import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cropped_network_image.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item_image.dart';

/// What the merchant can do with one saved photo of an item: make it the CARD's photo, set which part of it the card
/// shows, or delete it. Returns true when something changed (the caller reloads the item).
Future<bool> showItemPhotoActions(BuildContext context, WidgetRef ref, {required int itemId, required MenuItemImage image}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final api = ref.read(businessMenuApiProvider);

  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(image.isCover ? Icons.check_circle : Icons.star_outline, color: AppColors.accentGold),
            title: Text(image.isCover ? l10n.itemPhotoIsCover : l10n.itemPhotoSetCover),
            onTap: image.isCover ? null : () => Navigator.of(sheet).pop('cover'),
          ),
          ListTile(leading: const Icon(Icons.crop_outlined), title: Text(l10n.itemPhotoCropAdjust), onTap: () => Navigator.of(sheet).pop('crop')),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: Text(l10n.commonDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () => Navigator.of(sheet).pop('delete'),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return false;

  try {
    switch (choice) {
      case 'cover':
        await api.setItemCover(itemId, image.id);
        return true;
      case 'delete':
        await api.deleteImage(itemId, image.id);
        return true;
      case 'crop':
        final crop = await showPhotoCropEditor(context, url: image.url, initial: image.crop);
        if (crop == null) return false;
        await api.cropItemImage(itemId, image.id, crop);
        return true;
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
  }
  return false;
}

/// «اعدادات قص الصورة وأي جزء سيظهر حتى لا يظهر الجزء الذي لا يحتوي المنتج، والمنتج لا يكون مقصوصًا» — المالك،
/// 2026-10-06. The photo in a card-shaped window: drag it to put the product in the middle, zoom in to leave the empty
/// part out. What is seen here is what the card shows.
Future<PhotoCrop?> showPhotoCropEditor(BuildContext context, {required String url, PhotoCrop initial = PhotoCrop.whole}) {
  return showDialog<PhotoCrop>(context: context, builder: (_) => _PhotoCropDialog(url: url, initial: initial));
}

class _PhotoCropDialog extends StatefulWidget {
  final String url;
  final PhotoCrop initial;
  const _PhotoCropDialog({required this.url, required this.initial});

  @override
  State<_PhotoCropDialog> createState() => _PhotoCropDialogState();
}

class _PhotoCropDialogState extends State<_PhotoCropDialog> {
  late double _x = widget.initial.x;
  late double _y = widget.initial.y;
  late double _zoom = widget.initial.zoom;

  static const _window = 260.0;
  static const _windowHeight = _window / itemCardPhotoAspect;

  PhotoCrop get _crop => PhotoCrop(x: _x, y: _y, zoom: _zoom);

  /// The photo's own pixel size, once it has loaded (null until then).
  Size? _photoSize;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _stream = CachedNetworkImageProvider(widget.url).resolve(ImageConfiguration.empty);
    _listener = ImageStreamListener((info, _) {
      if (mounted) setState(() => _photoSize = Size(info.image.width.toDouble(), info.image.height.toDouble()));
    });
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    super.dispose();
  }

  /// The photo as the window draws it before zooming: cover-fitted into the window.
  Size get _shownPhotoSize {
    final photo = _photoSize;
    if (photo == null || photo.isEmpty) return const Size(_window, _windowHeight);
    final scale = (_window / photo.width) > (_windowHeight / photo.height) ? _window / photo.width : _windowHeight / photo.height;

    return Size(photo.width * scale, photo.height * scale);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.itemPhotoCropTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.itemPhotoCropHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                // Dragging the picture right moves the window left over it: the point kept in the middle goes left.
                // The photo follows the finger one-to-one: the focus moves by the finger's distance over the photo's own
                // size on screen (its cover-fitted size × the zoom), so a tall photo is not flung about.
                onPanUpdate: (d) => setState(() {
                  final shown = _shownPhotoSize;
                  _x = (_x - d.delta.dx / (shown.width * _zoom)).clamp(0.0, 1.0);
                  _y = (_y - d.delta.dy / (shown.height * _zoom)).clamp(0.0, 1.0);
                }),
                // the window is the card's own shape, so what is seen here is what the card shows
                child: Container(
                  width: _window,
                  height: _windowHeight,
                  decoration: BoxDecoration(border: Border.all(color: AppColors.accentGold, width: 2), borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CroppedNetworkImage(url: widget.url, crop: _crop),
                        // a light grid — five lines each way, the middle one is the exact centre
                        const IgnorePointer(child: CustomPaint(painter: _CropGridPainter())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // …and the small square the item has in a list
            Text(l10n.itemPhotoCropListPreview, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 64, height: 64, child: CroppedNetworkImage(url: widget.url, crop: _crop)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.zoom_out, size: 18),
                Expanded(
                  child: Slider(value: _zoom, min: 1, max: 4, divisions: 30, label: '×${_zoom.toStringAsFixed(1)}', onChanged: (v) => setState(() => _zoom = v)),
                ),
                const Icon(Icons.zoom_in, size: 18),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => setState(() {
          _x = 0.5;
          _y = 0.5;
          _zoom = 1.0;
        }), child: Text(l10n.itemPhotoCropReset)),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(PhotoCrop(x: double.parse(_x.toStringAsFixed(3)), y: double.parse(_y.toStringAsFixed(3)), zoom: double.parse(_zoom.toStringAsFixed(2)))), child: Text(l10n.commonSave)),
      ],
    );
  }
}

/// Five lines across and five down, evenly spaced: the third of each is the centre of the window.
class _CropGridPainter extends CustomPainter {
  const _CropGridPainter();

  static const lines = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 0.8;
    final shade = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;

    for (var i = 1; i <= lines; i++) {
      final x = size.width * i / (lines + 1);
      final y = size.height * i / (lines + 1);
      final centre = i == (lines + 1) ~/ 2;
      // a thin dark twin under each white line so the grid reads on a light photo too
      canvas.drawLine(Offset(x + 0.8, 0), Offset(x + 0.8, size.height), shade);
      canvas.drawLine(Offset(0, y + 0.8), Offset(size.width, y + 0.8), shade);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), centre ? (Paint.from(light)..strokeWidth = 1.4) : light);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), centre ? (Paint.from(light)..strokeWidth = 1.4) : light);
    }
  }

  @override
  bool shouldRepaint(covariant _CropGridPainter oldDelegate) => false;
}
