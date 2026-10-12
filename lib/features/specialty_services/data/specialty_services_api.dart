import '../../../core/network/api_client.dart';
import 'models/specialty_service.dart';

/// «خدمات عيادة الأسنان» — a patient's read of a dental clinic's list, and the clinic's own management
/// (Api\V2\DentalServiceController).
class SpecialtyServicesApi {
  final ApiClient _client;
  const SpecialtyServicesApi(this._client);

  List<ServiceOfferingSection> _offerings(dynamic data) =>
      ((data as Map<String, dynamic>)['kinds'] as List<dynamic>? ?? [])
          .map((e) => ServiceOfferingSection.fromJson(e as Map<String, dynamic>))
          .toList();

  List<ServiceCatalogSection> _catalog(dynamic data) => ((data as Map<String, dynamic>)['kinds'] as List<dynamic>? ?? [])
      .map((e) => ServiceCatalogSection.fromJson(e as Map<String, dynamic>))
      .toList();

  /// What a patient reads on the clinic's page.
  Future<List<ServiceOfferingSection>> offered(int clinicId) async =>
      _offerings(await _client.get('/clinics/$clinicId/dental-services'));

  // the clinic
  Future<List<ServiceCatalogSection>> catalog() async => _catalog(await _client.get('/business/dental-services'));

  /// `{serviceId: price|null}` for every service to keep offered; [removed] are taken off the list.
  Future<List<ServiceCatalogSection>> save(Map<int, double?> offered, List<int> removed) async => _catalog(
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

  Future<List<ServiceCatalogSection>> addOwn(String kind, String name) async =>
      _catalog(await _client.post('/business/dental-services/custom', data: {'kind': kind, 'name': name}));

  Future<List<ServiceCatalogSection>> deleteOwn(int id) async =>
      _catalog(await _client.delete('/business/dental-services/custom/$id'));
}
