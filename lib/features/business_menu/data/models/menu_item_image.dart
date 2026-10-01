import '../../../../core/env/env.dart';

class MenuItemImage {
  final int id;
  final String url;
  /// 'camera' = a live shot (badged in the app); 'upload' otherwise.
  final String source;

  const MenuItemImage({required this.id, required this.url, this.source = 'upload'});

  bool get isFromCamera => source == 'camera';

  factory MenuItemImage.fromJson(Map<String, dynamic> json) =>
      MenuItemImage(
        id: json['id'] as int,
        url: Env.assetUrl(json['image'] as String)!,
        source: json['source'] as String? ?? 'upload',
      );
}
