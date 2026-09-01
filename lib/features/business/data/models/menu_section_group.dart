import 'menu_item_summary.dart';

/// One heading in a business's menu — either a merchant-curated section or a
/// taxonomy-derived heading (MenuDiscoveryController groups items with no
/// hand-written section by the option combination they were registered
/// under, so nothing is ever left ungrouped).
class MenuSectionGroup {
  final int? id;
  final String name;
  final List<MenuItemSummary> items;

  const MenuSectionGroup({required this.id, required this.name, required this.items});

  factory MenuSectionGroup.fromJson(Map<String, dynamic> json) => MenuSectionGroup(
    id: json['id'] as int?,
    name: json['name'] as String? ?? '',
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => MenuItemSummary.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
