import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/menu_item.dart';
import 'models/menu_section.dart';

class MenuItemsPage {
  final List<BusinessMenuItem> items;
  final bool hasMore;
  const MenuItemsPage({required this.items, required this.hasMore});
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
    return data.map((e) => BusinessMenuSection.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BusinessMenuSection> createSection({
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data = await _client.post(
      '/business/menu/sections',
      data: {
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'sort_order': sortOrder,
        'is_active': isActive,
      },
    ) as Map<String, dynamic>;
    return BusinessMenuSection.fromJson(data);
  }

  Future<BusinessMenuSection> updateSection(
    int id, {
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data = await _client.put(
      '/business/menu/sections/$id',
      data: {
        'name_ar': nameAr,
        if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
        'sort_order': sortOrder,
        'is_active': isActive,
      },
    ) as Map<String, dynamic>;
    return BusinessMenuSection.fromJson(data);
  }

  Future<void> deleteSection(int id) => _client.delete('/business/menu/sections/$id');

  // ─────────────────────────── Items ───────────────────────────

  Future<MenuItemsPage> items({String? q, int? sectionId, bool? isActive, int page = 1}) async {
    final body = await _client.getForBody(
      '/business/menu/items',
      query: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (sectionId != null) 'menu_section_id': sectionId,
        if (isActive != null) 'is_active': isActive,
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
    final data = await _client.get('/business/menu/items/$id') as Map<String, dynamic>;
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
    String? brandName,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data = await _client.post('/business/menu/items', data: _itemPayload(
      nameAr: nameAr,
      nameEn: nameEn,
      menuSectionId: menuSectionId,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      basePrice: basePrice,
      supplyPrice: supplyPrice,
      brandName: brandName,
      sortOrder: sortOrder,
      isActive: isActive,
    )) as Map<String, dynamic>;
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
    String? brandName,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data = await _client.put('/business/menu/items/$id', data: _itemPayload(
      nameAr: nameAr,
      nameEn: nameEn,
      menuSectionId: menuSectionId,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      basePrice: basePrice,
      supplyPrice: supplyPrice,
      brandName: brandName,
      sortOrder: sortOrder,
      isActive: isActive,
    )) as Map<String, dynamic>;
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
    String? brandName,
    required int sortOrder,
    required bool isActive,
  }) {
    return {
      'name_ar': nameAr,
      if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
      if (menuSectionId != null) 'menu_section_id': menuSectionId,
      if (descriptionAr != null && descriptionAr.isNotEmpty) 'description_ar': descriptionAr,
      if (descriptionEn != null && descriptionEn.isNotEmpty) 'description_en': descriptionEn,
      'base_price': basePrice,
      if (supplyPrice != null) 'supply_price': supplyPrice,
      if (brandName != null && brandName.isNotEmpty) 'brand_name': brandName,
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
    await _client.post('/business/menu/items/$itemId/variants', data: {
      'type': type,
      'name_ar': nameAr,
      if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
      if (price != null) 'price': price,
      if (priceDelta != null) 'price_delta': priceDelta,
      'is_default': isDefault,
      'is_active': isActive,
    });
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
    await _client.put('/business/menu/items/$itemId/variants/$variantId', data: {
      'type': type,
      'name_ar': nameAr,
      if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
      if (price != null) 'price': price,
      if (priceDelta != null) 'price_delta': priceDelta,
      'is_default': isDefault,
      'is_active': isActive,
    });
  }

  Future<void> deleteVariant(int itemId, int variantId) =>
      _client.delete('/business/menu/items/$itemId/variants/$variantId');

  // ─────────────────────────── Extras ───────────────────────────

  Future<void> addExtra(
    int itemId, {
    String? groupKey,
    required String nameAr,
    String? nameEn,
    required double price,
    int maxQty = 1,
    bool isActive = true,
  }) async {
    await _client.post('/business/menu/items/$itemId/extras', data: {
      if (groupKey != null && groupKey.isNotEmpty) 'group_key': groupKey,
      'name_ar': nameAr,
      if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
      'price': price,
      'max_qty': maxQty,
      'is_active': isActive,
    });
  }

  Future<void> updateExtra(
    int itemId,
    int extraId, {
    String? groupKey,
    required String nameAr,
    String? nameEn,
    required double price,
    int maxQty = 1,
    bool isActive = true,
  }) async {
    await _client.put('/business/menu/items/$itemId/extras/$extraId', data: {
      if (groupKey != null && groupKey.isNotEmpty) 'group_key': groupKey,
      'name_ar': nameAr,
      if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
      'price': price,
      'max_qty': maxQty,
      'is_active': isActive,
    });
  }

  Future<void> deleteExtra(int itemId, int extraId) =>
      _client.delete('/business/menu/items/$itemId/extras/$extraId');
}
