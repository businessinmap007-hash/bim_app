import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../features/business_menu/data/models/menu_item_image.dart';

/// The shape of an item card's photo (merchant and customer grids alike) — the crop editor previews exactly this.
const itemCardPhotoAspect = 1.25;

/// A network photo filling its box, showing the part the merchant chose: the point [crop] keeps in the middle, and
/// how far in it goes — so the empty part of a photo is not what a card shows, and the product is not cut off.
/// The default crop is the plain `BoxFit.cover`.
class CroppedNetworkImage extends StatelessWidget {
  final String url;
  final PhotoCrop crop;
  final BoxFit fit;
  final Widget Function(BuildContext context, String url, Object error)? errorWidget;

  const CroppedNetworkImage({super.key, required this.url, this.crop = PhotoCrop.whole, this.fit = BoxFit.cover, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    final focus = Alignment(crop.x * 2 - 1, crop.y * 2 - 1);
    final image = CachedNetworkImage(imageUrl: url, fit: fit, alignment: focus, errorWidget: errorWidget);
    if (crop.zoom <= 1) return image;

    // Zoom IN on the chosen point: it is put in the MIDDLE of the box (as far as the photo's edges allow), so «the
    // product in the middle» is what the card shows — not only a bigger copy that keeps the point where it was.
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final z = crop.zoom;
        final cx = (crop.x * w).clamp(w / (2 * z), w - w / (2 * z)).toDouble();
        final cy = (crop.y * h).clamp(h / (2 * z), h - h / (2 * z)).toDouble();
        final matrix = Matrix4.identity()
          ..translateByDouble(w / 2, h / 2, 0, 1)
          ..scaleByDouble(z, z, 1, 1)
          ..translateByDouble(-cx, -cy, 0, 1);

        return ClipRect(child: Transform(transform: matrix, child: image));
      },
    );
  }
}
