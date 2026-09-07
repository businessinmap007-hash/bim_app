import '../../../core/network/api_client.dart';
import 'models/menu_bundle.dart';

/// /business/menu/bundles — see Api\V2\BusinessMenuBundleController. Gated
/// server-side on the "menu" business capability, same as
/// [BusinessMenuApi].
class MenuBundleApi {
  final ApiClient _client;
  const MenuBundleApi(this._client);

  Future<List<MenuBundle>> list() async {
    final data = await _client.get('/business/menu/bundles') as List<dynamic>;
    return data.map((e) => MenuBundle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MenuBundle> create({
    required String nameAr,
    String? nameEn,
    required String pricingMode,
    double? fixedPrice,
    double? discountValue,
    required List<MapEntry<int, int>> items,
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    final data = await _client.post('/business/menu/bundles', data: _payload(
      nameAr: nameAr,
      nameEn: nameEn,
      pricingMode: pricingMode,
      fixedPrice: fixedPrice,
      discountValue: discountValue,
      items: items,
      isActive: isActive,
      sortOrder: sortOrder,
    )) as Map<String, dynamic>;
    return MenuBundle.fromJson(data);
  }

  Future<MenuBundle> update(
    int id, {
    required String nameAr,
    String? nameEn,
    required String pricingMode,
    double? fixedPrice,
    double? discountValue,
    required List<MapEntry<int, int>> items,
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    final data = await _client.put('/business/menu/bundles/$id', data: _payload(
      nameAr: nameAr,
      nameEn: nameEn,
      pricingMode: pricingMode,
      fixedPrice: fixedPrice,
      discountValue: discountValue,
      items: items,
      isActive: isActive,
      sortOrder: sortOrder,
    )) as Map<String, dynamic>;
    return MenuBundle.fromJson(data);
  }

  Future<void> delete(int id) => _client.delete('/business/menu/bundles/$id');

  Map<String, dynamic> _payload({
    required String nameAr,
    String? nameEn,
    required String pricingMode,
    double? fixedPrice,
    double? discountValue,
    required List<MapEntry<int, int>> items,
    required bool isActive,
    required int sortOrder,
  }) {
    return {
      'name_ar': nameAr,
      if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
      'pricing_mode': pricingMode,
      'fixed_price': ?fixedPrice,
      'discount_value': ?discountValue,
      'is_active': isActive,
      'sort_order': sortOrder,
      'items': items.map((e) => {'menu_item_id': e.key, 'qty': e.value}).toList(),
    };
  }
}
