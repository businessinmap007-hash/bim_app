import '../../../core/network/api_client.dart';
import 'models/dental_service.dart';

/// «خدمات عيادة الأسنان» — a patient's read of a dental clinic's list, and the clinic's own management
/// (Api\V2\DentalServiceController).
class DentalApi {
  final ApiClient _client;
  const DentalApi(this._client);

  List<DentalOfferingSection> _offerings(dynamic data) =>
      ((data as Map<String, dynamic>)['kinds'] as List<dynamic>? ?? [])
          .map((e) => DentalOfferingSection.fromJson(e as Map<String, dynamic>))
          .toList();

  List<DentalCatalogSection> _catalog(dynamic data) => ((data as Map<String, dynamic>)['kinds'] as List<dynamic>? ?? [])
      .map((e) => DentalCatalogSection.fromJson(e as Map<String, dynamic>))
      .toList();

  /// What a patient reads on the clinic's page.
  Future<List<DentalOfferingSection>> offered(int clinicId) async =>
      _offerings(await _client.get('/clinics/$clinicId/dental-services'));

  // the clinic
  Future<List<DentalCatalogSection>> catalog() async => _catalog(await _client.get('/business/dental-services'));

  /// `{serviceId: price|null}` for every service to keep offered; [removed] are taken off the list.
  Future<List<DentalCatalogSection>> save(Map<int, double?> offered, List<int> removed) async => _catalog(
    await _client.put(
      '/business/dental-services',
      data: {
        'items': [
          for (final e in offered.entries) {'service_id': e.key, 'offered': true, 'price': e.value},
          for (final id in removed) {'service_id': id, 'offered': false},
        ],
      },
    ),
  );

  Future<List<DentalCatalogSection>> addOwn(String kind, String name) async =>
      _catalog(await _client.post('/business/dental-services/custom', data: {'kind': kind, 'name': name}));

  Future<List<DentalCatalogSection>> deleteOwn(int id) async =>
      _catalog(await _client.delete('/business/dental-services/custom/$id'));
}
