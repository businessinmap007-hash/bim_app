import '../../../core/network/api_client.dart';
import 'models/address.dart';

/// /addresses — the customer's saved delivery addresses. See
/// Api\V2\AddressController. Reused wherever a delivery flow already accepts
/// an `address_id` alongside its free-text fallback (checkout, prescription
/// delivery).
class AddressesApi {
  final ApiClient _client;
  const AddressesApi(this._client);

  Future<List<Address>> list() async {
    final data = await _client.get('/addresses') as List<dynamic>;
    return data.map((e) => Address.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Address> create({
    required int governorateId,
    required int cityId,
    required String addressLine,
    String? zipCode,
    double? lat,
    double? lng,
    bool isPrimary = false,
  }) async {
    final data = await _client.post(
      '/addresses',
      data: {
        'governorate_id': governorateId,
        'city_id': cityId,
        'address_line': addressLine,
        if (zipCode != null && zipCode.isNotEmpty) 'zip_code': zipCode,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (isPrimary) 'is_primary': true,
      },
    ) as Map<String, dynamic>;
    return Address.fromJson(data);
  }

  Future<Address> update(
    int id, {
    int? governorateId,
    int? cityId,
    String? addressLine,
    String? zipCode,
    double? lat,
    double? lng,
    bool? isPrimary,
  }) async {
    final data = await _client.put(
      '/addresses/$id',
      data: {
        if (governorateId != null) 'governorate_id': governorateId,
        if (cityId != null) 'city_id': cityId,
        if (addressLine != null) 'address_line': addressLine,
        if (zipCode != null) 'zip_code': zipCode,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (isPrimary != null) 'is_primary': isPrimary,
      },
    ) as Map<String, dynamic>;
    return Address.fromJson(data);
  }

  Future<Address> setPrimary(int id) async {
    final data = await _client.post('/addresses/$id/primary') as Map<String, dynamic>;
    return Address.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.delete('/addresses/$id');
  }
}
