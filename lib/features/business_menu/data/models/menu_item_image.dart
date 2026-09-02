import '../../../../core/env/env.dart';

class MenuItemImage {
  final int id;
  final String url;

  const MenuItemImage({required this.id, required this.url});

  factory MenuItemImage.fromJson(Map<String, dynamic> json) =>
      MenuItemImage(id: json['id'] as int, url: Env.assetUrl(json['image'] as String)!);
}
