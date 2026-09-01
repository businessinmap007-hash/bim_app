import '../../../core/network/api_client.dart';
import 'models/location_models.dart';

/// GET /locations/* — public, no auth (an address is picked before there's
/// anything to authenticate with). See Api\V2\LocationController.
class LocationApi {
  final ApiClient _client;

  const LocationApi(this._client);

  Future<List<LocationCountry>> countries() async {
    final data = await _client.get('/locations/countries') as Map<String, dynamic>;
    final countries = data['countries'] as List<dynamic>? ?? [];
    return countries.map((e) => LocationCountry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LocationGovernorate>> governorates(int countryId) async {
    final data = await _client.get('/locations/governorates', query: {'country_id': countryId}) as Map<String, dynamic>;
    final governorates = data['governorates'] as List<dynamic>? ?? [];
    return governorates.map((e) => LocationGovernorate.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LocationCity>> cities(int governorateId) async {
    final data = await _client.get('/locations/cities', query: {'governorate_id': governorateId}) as Map<String, dynamic>;
    final cities = data['cities'] as List<dynamic>? ?? [];
    return cities.map((e) => LocationCity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<NearestLocationMatch?> nearest({required double latitude, required double longitude}) async {
    final data = await _client.get('/locations/nearest', query: {'lat': latitude, 'lng': longitude}) as Map<String, dynamic>;
    return NearestLocationMatch.fromJson(data['match'] as Map<String, dynamic>?);
  }
}
