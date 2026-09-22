import '../../../core/network/api_client.dart';
import 'models/retail_variant_group.dart';

/// One variant line sent to the server — a label plus one of the business's
/// own listing ids (Api\V2\BusinessRetailVariantGroupController validates
/// ownership and that it isn't already promised to another group).
class VariantOptionInput {
  final int listingId;
  final String labelAr;
  final String? labelEn;

  const VariantOptionInput({required this.listingId, required this.labelAr, this.labelEn});

  Map<String, dynamic> toJson() => {
    'listing_id': listingId,
    'label_ar': labelAr,
    if (labelEn != null && labelEn!.isNotEmpty) 'label_en': labelEn,
  };
}

/// /business/retail/variant-groups — see BusinessRetailVariantGroupController.
/// Gated server-side on the "retail" business capability, same as My Products.
class RetailVariantGroupsApi {
  final ApiClient _client;
  const RetailVariantGroupsApi(this._client);

  Future<List<RetailVariantGroup>> list() async {
    final data = await _client.get('/business/retail/variant-groups') as List<dynamic>;
    return data.map((e) => RetailVariantGroup.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RetailVariantGroup> create({
    required String nameAr,
    String? nameEn,
    required List<VariantOptionInput> options,
  }) async {
    final data =
        await _client.post(
              '/business/retail/variant-groups',
              data: {
                'name_ar': nameAr,
                if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
                'options': options.map((o) => o.toJson()).toList(),
              },
            )
            as Map<String, dynamic>;
    return RetailVariantGroup.fromJson(data);
  }

  Future<RetailVariantGroup> update(
    int id, {
    required String nameAr,
    String? nameEn,
    required List<VariantOptionInput> options,
  }) async {
    final data =
        await _client.put(
              '/business/retail/variant-groups/$id',
              data: {
                'name_ar': nameAr,
                if (nameEn != null && nameEn.isNotEmpty) 'name_en': nameEn,
                'options': options.map((o) => o.toJson()).toList(),
              },
            )
            as Map<String, dynamic>;
    return RetailVariantGroup.fromJson(data);
  }

  Future<void> delete(int id) => _client.delete('/business/retail/variant-groups/$id');
}
