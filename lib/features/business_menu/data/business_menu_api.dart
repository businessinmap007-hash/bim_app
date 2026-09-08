import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/menu_item.dart';
import 'models/menu_section.dart';
import 'models/menu_vocabulary.dart';

class MenuItemsPage {
  final List<BusinessMenuItem> items;
  final bool hasMore;
  const MenuItemsPage({required this.items, required this.hasMore});
}

/// One row from GET /business/menu/sale-units — a unit an item's price can
/// be "per" (كجم، لتر، قطعة...).
class SaleUnitOption {
  final String code;
  final String label;
  const SaleUnitOption({required this.code, required this.label});

  factory SaleUnitOption.fromJson(Map<String, dynamic> json) =>
      SaleUnitOption(code: json['code'] as String, label: json['label'] as String);
}

/// /business/menu/... — see Api\V2\BusinessMenuSectionController /
/// BusinessMenuItemController. Gated server-side on the "menu" business
/// capability (owner, or a delegate granted it) via business.member
/// middleware.
class BusinessMenuApi {
  final ApiClient _client;
  const BusinessMenuApi(this._client);

  // ─────────────────────────── Sections ───────────────────────────

  Future<List<BusinessMenuSection>> sections() async {
    final data = await _client.get('/business/menu/sections') as List<dynamic>;
    return data
        .map((e) => BusinessMenuSection.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BusinessMenuSection> createSection({
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data =
        await _client.post(
              '/business/menu/sections',
              data: {
                'name_ar': nameAr,
                if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
                'sort_order': sortOrder,
                'is_active': isActive,
              },
            )
            as Map<String, dynamic>;
    return BusinessMenuSection.fromJson(data);
  }

  Future<BusinessMenuSection> updateSection(
    int id, {
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data =
        await _client.put(
              '/business/menu/sections/$id',
              data: {
                'name_ar': nameAr,
                if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
                'sort_order': sortOrder,
                'is_active': isActive,
              },
            )
            as Map<String, dynamic>;
    return BusinessMenuSection.fromJson(data);
  }

  Future<void> deleteSection(int id) =>
      _client.delete('/business/menu/sections/$id');

  Future<List<SaleUnitOption>> saleUnits() async {
    final body = await _client.getForBody('/business/menu/sale-units');
    return (body['data']['units'] as List<dynamic>? ?? [])
        .map((e) => SaleUnitOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// What this merchant may say a catalog item IS (`lines`) and what may
  /// qualify it (`modifiers`) — narrowed to their own specialty.
  Future<MenuVocabulary> vocabulary() async {
    final body = await _client.getForBody('/business/menu/vocabulary');
    return MenuVocabulary.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// 'list' (the default) or 'grid' — how this business's menu renders for a
  /// customer. See Api\V2\BusinessMenuItemController::displayMode().
  Future<String> displayMode() async {
    final body = await _client.getForBody('/business/menu/display-mode');
    return body['data']['display_mode'] as String? ?? 'list';
  }

  Future<void> setDisplayMode(String mode) async {
    await _client.put('/business/menu/display-mode', data: {'display_mode': mode});
  }

  // ─────────────────────────── Items ───────────────────────────

  Future<MenuItemsPage> items({
    String? q,
    int? sectionId,
    bool? isActive,
    int page = 1,
  }) async {
    final body = await _client.getForBody(
      '/business/menu/items',
      query: {
        if (q != null && q.isNotEmpty) 'q': q,
        'menu_section_id': ?sectionId,
        // Laravel's `boolean` rule accepts 1/0/true/false only as real JSON
        // booleans or the digits '1'/'0' — the query string's literal word
        // "true"/"false" fails it with a 422. '1'/'0' works in both worlds.
        if (isActive != null) 'is_active': isActive ? '1' : '0',
        'page': page,
      },
    );
    final list = (body['data'] as List<dynamic>? ?? [])
        .map((e) => BusinessMenuItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return MenuItemsPage(items: list, hasMore: currentPage < lastPage);
  }

  Future<BusinessMenuItem> item(int id) async {
    final data =
        await _client.get('/business/menu/items/$id') as Map<String, dynamic>;
    return BusinessMenuItem.fromJson(data);
  }

  Future<BusinessMenuItem> createItem({
    required String nameAr,
    String? nameEn,
    int? menuSectionId,
    String? descriptionAr,
    String? descriptionEn,
    required double basePrice,
    double? supplyPrice,
    String? saleUnit,
    String? brandName,
    int? availableQuantity,
    int? lineOptionId,
    List<int> modifierOptionIds = const [],
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data =
        await _client.post(
              '/business/menu/items',
              data: _itemPayload(
                nameAr: nameAr,
                nameEn: nameEn,
                menuSectionId: menuSectionId,
                descriptionAr: descriptionAr,
                descriptionEn: descriptionEn,
                basePrice: basePrice,
                supplyPrice: supplyPrice,
                saleUnit: saleUnit,
                brandName: brandName,
                availableQuantity: availableQuantity,
                lineOptionId: lineOptionId,
                modifierOptionIds: modifierOptionIds,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
            )
            as Map<String, dynamic>;
    return BusinessMenuItem.fromJson(data);
  }

  Future<BusinessMenuItem> updateItem(
    int id, {
    required String nameAr,
    String? nameEn,
    int? menuSectionId,
    String? descriptionAr,
    String? descriptionEn,
    required double basePrice,
    double? supplyPrice,
    String? saleUnit,
    String? brandName,
    int? availableQuantity,
    int? lineOptionId,
    List<int> modifierOptionIds = const [],
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data =
        await _client.put(
              '/business/menu/items/$id',
              data: _itemPayload(
                nameAr: nameAr,
                nameEn: nameEn,
                menuSectionId: menuSectionId,
                descriptionAr: descriptionAr,
                descriptionEn: descriptionEn,
                basePrice: basePrice,
                supplyPrice: supplyPrice,
                saleUnit: saleUnit,
                brandName: brandName,
                availableQuantity: availableQuantity,
                lineOptionId: lineOptionId,
                modifierOptionIds: modifierOptionIds,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
            )
            as Map<String, dynamic>;
    return BusinessMenuItem.fromJson(data);
  }

  Map<String, dynamic> _itemPayload({
    required String nameAr,
    String? nameEn,
    int? menuSectionId,
    String? descriptionAr,
    String? descriptionEn,
    required double basePrice,
    double? supplyPrice,
    String? saleUnit,
    String? brandName,
    int? availableQuantity,
    int? lineOptionId,
    List<int> modifierOptionIds = const [],
    required int sortOrder,
    required bool isActive,
  }) {
    return {
      'name_ar': nameAr,
      if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
      'menu_section_id': ?menuSectionId,
      if (descriptionAr != null && descriptionAr.isNotEmpty)
        'description_ar': descriptionAr,
      if (descriptionEn != null && descriptionEn.isNotEmpty)
        'description_en': descriptionEn,
      'base_price': basePrice,
      'supply_price': ?supplyPrice,
      // A resubmitted form always carries the field's current state, so an
      // absent key here means "by the item" just as much as an empty one —
      // same convention as supply_price/brand_name above.
      'sale_unit': ?saleUnit,
      if (brandName != null && brandName.isNotEmpty) 'brand_name': brandName,
      'available_quantity': ?availableQuantity,
      // What this item IS/what qualifies it — see HasOfferingOptions. Always
      // sent (even empty) so clearing a pick on a resubmit actually clears it.
      'line_option_id': lineOptionId ?? 0,
      'modifier_option_ids': modifierOptionIds,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  Future<void> deleteItem(int id) => _client.delete('/business/menu/items/$id');

  // ─────────────────────────── Images ───────────────────────────

  Future<void> addImage(int itemId, String filePath) async {
    await _client.post(
      '/business/menu/items/$itemId/images',
      data: FormData.fromMap({
        'images[0]': await MultipartFile.fromFile(filePath),
      }),
    );
  }

  Future<void> deleteImage(int itemId, int imageId) =>
      _client.delete('/business/menu/items/$itemId/images/$imageId');

  // ─────────────────────────── Variants ───────────────────────────

  Future<void> addVariant(
    int itemId, {
    required String type,
    required String nameAr,
    String? nameEn,
    double? price,
    double? priceDelta,
    bool isDefault = false,
    bool isActive = true,
  }) async {
    await _client.post(
      '/business/menu/items/$itemId/variants',
      data: {
        'type': type,
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'price': ?price,
        'price_delta': ?priceDelta,
        'is_default': isDefault,
        'is_active': isActive,
      },
    );
  }

  Future<void> updateVariant(
    int itemId,
    int variantId, {
    required String type,
    required String nameAr,
    String? nameEn,
    double? price,
    double? priceDelta,
    bool isDefault = false,
    bool isActive = true,
  }) async {
    await _client.put(
      '/business/menu/items/$itemId/variants/$variantId',
      data: {
        'type': type,
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'price': ?price,
        'price_delta': ?priceDelta,
        'is_default': isDefault,
        'is_active': isActive,
      },
    );
  }

  Future<void> deleteVariant(int itemId, int variantId) =>
      _client.delete('/business/menu/items/$itemId/variants/$variantId');

  // ────────────────────────── Extra groups ──────────────────────────

  Future<void> addExtraGroup(
    int itemId, {
    required String nameAr,
    String? nameEn,
    required String selectionType,
    bool isActive = true,
  }) async {
    await _client.post(
      '/business/menu/items/$itemId/extra-groups',
      data: {
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'selection_type': selectionType,
        'is_active': isActive,
      },
    );
  }

  Future<void> updateExtraGroup(
    int itemId,
    int groupId, {
    required String nameAr,
    String? nameEn,
    required String selectionType,
    bool isActive = true,
  }) async {
    await _client.put(
      '/business/menu/items/$itemId/extra-groups/$groupId',
      data: {
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'selection_type': selectionType,
        'is_active': isActive,
      },
    );
  }

  Future<void> deleteExtraGroup(int itemId, int groupId) =>
      _client.delete('/business/menu/items/$itemId/extra-groups/$groupId');

  // ─────────────────────────── Extras ───────────────────────────

  Future<void> addExtra(
    int itemId, {
    int? extraGroupId,
    required String nameAr,
    String? nameEn,
    required double price,
    int maxQty = 1,
    bool isActive = true,
  }) async {
    await _client.post(
      '/business/menu/items/$itemId/extras',
      data: {
        'extra_group_id': ?extraGroupId,
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'price': price,
        'max_qty': maxQty,
        'is_active': isActive,
      },
    );
  }

  Future<void> updateExtra(
    int itemId,
    int extraId, {
    int? extraGroupId,
    required String nameAr,
    String? nameEn,
    required double price,
    int maxQty = 1,
    bool isActive = true,
  }) async {
    await _client.put(
      '/business/menu/items/$itemId/extras/$extraId',
      data: {
        'extra_group_id': ?extraGroupId,
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'price': price,
        'max_qty': maxQty,
        'is_active': isActive,
      },
    );
  }

  Future<void> deleteExtra(int itemId, int extraId) =>
      _client.delete('/business/menu/items/$itemId/extras/$extraId');
}
