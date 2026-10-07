import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/investigation.dart';

/// «طلب تحاليل وأشعة» — the doctor, the patient and the centre sides of one module (Api\V2\InvestigationOrderController).
class InvestigationsApi {
  final ApiClient _client;
  const InvestigationsApi(this._client);

  Future<InvestigationCatalog> catalog() async {
    final data = await _client.get('/investigations/catalog') as Map<String, dynamic>;
    return InvestigationCatalog.fromJson(data);
  }

  List<InvestigationOrder> _orders(dynamic data) => ((data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [])
      .map((e) => InvestigationOrder.fromJson(e as Map<String, dynamic>))
      .toList();

  InvestigationOrder _order(dynamic data) => InvestigationOrder.fromJson((data as Map<String, dynamic>)['order'] as Map<String, dynamic>);

  // ── the patient ──
  Future<List<InvestigationOrder>> myOrders() async => _orders(await _client.get('/investigation-orders', query: {'per_page': 50}));

  Future<InvestigationOrder> order(int id) async => _order(await _client.get('/investigation-orders/$id'));

  Future<List<InvestigationCenter>> centers(int orderId) async {
    final data = await _client.get('/investigation-orders/$orderId/centers') as Map<String, dynamic>;
    return (data['centers'] as List<dynamic>? ?? []).map((e) => InvestigationCenter.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InvestigationOrder> send(int orderId, int centerId) async =>
      _order(await _client.post('/investigation-orders/$orderId/send', data: {'center_id': centerId}));

  Future<InvestigationOrder> cancel(int orderId) async => _order(await _client.post('/investigation-orders/$orderId/cancel'));

  /// The patient asks a centre directly, optionally with a photo of a paper request.
  Future<InvestigationOrder> requestFromCenter({
    required int centerId,
    required List<int> optionIds,
    String? notes,
    String? photoPath,
  }) async {
    final fields = {'center_id': centerId, 'option_ids': optionIds, if (notes != null && notes.isNotEmpty) 'notes': notes};
    final body = photoPath == null
        ? fields
        : FormData.fromMap({
            'center_id': '$centerId',
            for (var i = 0; i < optionIds.length; i++) 'option_ids[$i]': '${optionIds[i]}',
            if (notes != null && notes.isNotEmpty) 'notes': notes,
            'photo': await MultipartFile.fromFile(photoPath),
          });

    return _order(await _client.post('/investigation-orders/request', data: body));
  }

  /// What a lab or radiology centre does and charges, for its page.
  Future<List<CenterTest>> centerTests(int centerId) async {
    final data = await _client.get('/investigation-centers/$centerId/tests') as Map<String, dynamic>;
    return (data['tests'] as List<dynamic>? ?? []).map((e) => CenterTest.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── the doctor ──
  Future<InvestigationOrder> issue({required int patientId, required List<int> optionIds, String? notes}) async => _order(
    await _client.post('/investigation-orders', data: {
      'patient_id': patientId,
      'option_ids': optionIds,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    }),
  );

  Future<List<InvestigationOrder>> issued() async => _orders(await _client.get('/investigation-orders/issued', query: {'per_page': 50}));

  // ── the centre ──
  Future<List<InvestigationOrder>> centerOrders(String tab) async =>
      _orders(await _client.get('/business/investigation-orders', query: {'tab': tab, 'per_page': 50}));

  Future<InvestigationOrder> accept(int id, {DateTime? appointmentAt, String? note}) async => _order(
    await _client.post('/business/investigation-orders/$id/accept', data: {
      if (appointmentAt != null) 'appointment_at': appointmentAt.toUtc().toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    }),
  );

  Future<InvestigationOrder> decline(int id, {String? note}) async => _order(
    await _client.post('/business/investigation-orders/$id/decline', data: {if (note != null && note.isNotEmpty) 'note': note}),
  );

  Future<InvestigationOrder> attachResults(int id, List<String> photoPaths, {String? note}) async => _order(
    await _client.post(
      '/business/investigation-orders/$id/results',
      data: FormData.fromMap({
        if (note != null && note.isNotEmpty) 'note': note,
        for (var i = 0; i < photoPaths.length; i++) 'images[$i]': await MultipartFile.fromFile(photoPaths[i]),
      }),
    ),
  );

  Future<List<CenterTest>> priceList() async {
    final data = await _client.get('/business/investigation-prices') as Map<String, dynamic>;
    return (data['tests'] as List<dynamic>? ?? []).map((e) => CenterTest.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `{optionId: price}`; a null price removes the test from this centre's list.
  Future<List<CenterTest>> savePrices(Map<int, double?> prices) async {
    final data =
        await _client.put('/business/investigation-prices', data: {'prices': {for (final e in prices.entries) '${e.key}': e.value}})
            as Map<String, dynamic>;
    return (data['tests'] as List<dynamic>? ?? []).map((e) => CenterTest.fromJson(e as Map<String, dynamic>)).toList();
  }
}
