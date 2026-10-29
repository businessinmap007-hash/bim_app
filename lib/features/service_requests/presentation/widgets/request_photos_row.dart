import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/full_screen_gallery.dart';

/// The photos of the problem as a row of thumbnails; a tap opens the app's one viewer. Network links (signed) or, while the
/// customer is still writing the request, the files he picked — then each carries a small ✕ to drop it.
class RequestPhotosRow extends StatelessWidget {
  final List<String> urls;
  final List<String> files;
  final ValueChanged<int>? onRemove;
  final double size;

  const RequestPhotosRow({
    super.key,
    this.urls = const [],
    this.files = const [],
    this.onRemove,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final count = urls.isNotEmpty ? urls.length : files.length;
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final image = urls.isNotEmpty
              ? Image.network(
                  urls[i],
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _broken(context),
                )
              : Image.file(
                  File(files[i]),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _broken(context),
                );

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: urls.isNotEmpty
                    ? InkWell(
                        onTap: () => FullScreenGallery.show(
                          context,
                          urls: urls,
                          initialIndex: i,
                        ),
                        child: image,
                      )
                    : image,
              ),
              if (onRemove != null)
                PositionedDirectional(
                  top: 2,
                  end: 2,
                  child: InkWell(
                    onTap: () => onRemove!(i),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _broken(BuildContext context) => Container(
    width: size,
    height: size,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Icon(Icons.broken_image_outlined),
  );
}
