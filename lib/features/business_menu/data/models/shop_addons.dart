/// «خدمات المحل» — a service the shop adds on top of what it sells («طريقة الطهي»), priced ONCE for the
/// whole shop and per unit bought. [price] null = the shop does not offer it.
class ShopAddonOption {
  final int id;
  final String name;
  final double? price;

  const ShopAddonOption({required this.id, required this.name, this.price});

  factory ShopAddonOption.fromJson(Map<String, dynamic> json) => ShopAddonOption(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble(),
  );
}

class ShopAddonGroup {
  final int groupId;
  final String name;
  final List<ShopAddonOption> options;

  const ShopAddonGroup({required this.groupId, required this.name, required this.options});

  factory ShopAddonGroup.fromJson(Map<String, dynamic> json) => ShopAddonGroup(
    groupId: (json['group_id'] as num).toInt(),
    name: json['group_name'] as String? ?? '',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => ShopAddonOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  static List<ShopAddonGroup> listFrom(Object? json) =>
      (json as List<dynamic>? ?? []).map((e) => ShopAddonGroup.fromJson(e as Map<String, dynamic>)).toList();
}
