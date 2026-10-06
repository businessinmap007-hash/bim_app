import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../features/business_menu/data/models/menu_item_image.dart';

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

    return ClipRect(child: Transform.scale(scale: crop.zoom, alignment: focus, child: image));
  }
}
