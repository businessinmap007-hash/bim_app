import 'package:flutter/material.dart';

import '../../../../core/env/env.dart';

/// A listing's photo (or a quiet placeholder when it has none / cannot load).
class OwnerListingPhoto extends StatelessWidget {
  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OwnerListingPhoto({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = Env.assetUrl(path);
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.image_outlined, color: Theme.of(context).hintColor),
    );

    if (url == null) return placeholder;

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
