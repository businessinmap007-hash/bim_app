import '../../../core/network/api_client.dart';
import 'models/hospital_department.dart';
import 'models/hospital_procedure.dart';

/// «الأطباء تحت الأقسام» — a patient's read of a hospital's departments, the hospital's own management, and a doctor's
/// invitations (Api\V2\HospitalDoctorController).
class HospitalApi {
  final ApiClient _client;
  const HospitalApi(this._client);

  List<HospitalDepartment> _departments(dynamic data) => ((data as Map<String, dynamic>)['departments'] as List<dynamic>? ?? [])
      .map((e) => HospitalDepartment.fromJson(e as Map<String, dynamic>))
      .toList();

  HospitalInvitations _invitations(dynamic data) => HospitalInvitations.fromJson(data as Map<String, dynamic>);

  /// What a patient reads on the hospital's page.
  Future<List<HospitalDepartment>> departments(int hospitalId) async => _departments(await _client.get('/hospitals/$hospitalId/departments'));

  // ── the hospital ──
  Future<List<HospitalDepartment>> myDepartments() async => _departments(await _client.get('/business/hospital-doctors'));

  Future<List<DoctorCandidate>> findDoctors(String query) async {
    final data = await _client.get('/business/hospital-doctors/find-doctors', query: {'q': query}) as Map<String, dynamic>;
    return (data['doctors'] as List<dynamic>? ?? []).map((e) => DoctorCandidate.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Either [userId] (a doctor with an account — asked to accept) or [name] (a doctor with no account — listed at once).
  Future<void> addDoctor({required int optionId, int? userId, String? name, String? title}) async {
    await _client.post('/business/hospital-doctors', data: {
      'option_id': optionId,
      'user_id': ?userId,
      if (name != null && name.isNotEmpty) 'name': name,
      if (title != null && title.isNotEmpty) 'title': title,
    });
  }

  Future<void> removeDoctor(int id) async {
    await _client.delete('/business/hospital-doctors/$id');
  }

  // ── the doctor ──
  Future<HospitalInvitations> invitations() async => _invitations(await _client.get('/business/hospital-invitations'));

  Future<HospitalInvitations> accept(int id) async => _invitations(await _client.post('/business/hospital-invitations/$id/accept'));

  Future<HospitalInvitations> leave(int id) async => _invitations(await _client.delete('/business/hospital-invitations/$id'));

  // ── procedures: «إجراء طبي في المستشفى» ──
  List<ProcedureOfferingSection> _offerings(dynamic data) => ((data as Map<String, dynamic>)['kinds'] as List<dynamic>? ?? [])
      .map((e) => ProcedureOfferingSection.fromJson(e as Map<String, dynamic>))
      .toList();

  List<ProcedureCatalogSection> _catalog(dynamic data) => ((data as Map<String, dynamic>)['kinds'] as List<dynamic>? ?? [])
      .map((e) => ProcedureCatalogSection.fromJson(e as Map<String, dynamic>))
      .toList();

  List<ProcedureRequestItem> _requests(dynamic data) => ((data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [])
      .map((e) => ProcedureRequestItem.fromJson(e as Map<String, dynamic>))
      .toList();

  ProcedureRequestItem _request(dynamic data) =>
      ProcedureRequestItem.fromJson((data as Map<String, dynamic>)['request'] as Map<String, dynamic>);

  /// What a patient reads on the hospital's page.
  Future<List<ProcedureOfferingSection>> offeredProcedures(int hospitalId) async =>
      _offerings(await _client.get('/hospitals/$hospitalId/procedures'));

  Future<ProcedureRequestItem> requestProcedure({required int offeringId, DateTime? preferredDate, String? notes}) async => _request(
    await _client.post('/procedure-requests', data: {
      'hospital_procedure_id': offeringId,
      if (preferredDate != null) 'preferred_date': preferredDate.toIso8601String().substring(0, 10),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    }),
  );

  Future<List<ProcedureRequestItem>> myProcedureRequests() async =>
      _requests(await _client.get('/procedure-requests', query: {'per_page': 50}));

  Future<ProcedureRequestItem> cancelProcedureRequest(int id) async => _request(await _client.post('/procedure-requests/$id/cancel'));

  // the hospital
  Future<List<ProcedureCatalogSection>> procedureCatalog() async => _catalog(await _client.get('/business/hospital-procedures'));

  /// `{procedureId: price|null}` for every procedure to keep offered; [removed] are taken off the list.
  Future<List<ProcedureCatalogSection>> saveProcedures(Map<int, double?> offered, List<int> removed) async => _catalog(
    await _client.put('/business/hospital-procedures', data: {
      'items': [
        for (final e in offered.entries) {'procedure_id': e.key, 'offered': true, 'price': e.value},
        for (final id in removed) {'procedure_id': id, 'offered': false},
      ],
    }),
  );

  Future<List<ProcedureCatalogSection>> addOwnProcedure(String kind, String name) async =>
      _catalog(await _client.post('/business/hospital-procedures/custom', data: {'kind': kind, 'name': name}));

  Future<List<ProcedureCatalogSection>> deleteOwnProcedure(int id) async =>
      _catalog(await _client.delete('/business/hospital-procedures/custom/$id'));

  Future<List<ProcedureRequestItem>> hospitalProcedureRequests(String tab) async =>
      _requests(await _client.get('/business/procedure-requests', query: {'tab': tab, 'per_page': 50}));

  Future<ProcedureRequestItem> acceptProcedure(int id, {required DateTime scheduledAt, double? price, String? note}) async => _request(
    await _client.post('/business/procedure-requests/$id/accept', data: {
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'price': ?price,
      if (note != null && note.isNotEmpty) 'note': note,
    }),
  );

  Future<ProcedureRequestItem> declineProcedure(int id, {String? note}) async => _request(
    await _client.post('/business/procedure-requests/$id/decline', data: {if (note != null && note.isNotEmpty) 'note': note}),
  );

  Future<ProcedureRequestItem> completeProcedure(int id) async => _request(await _client.post('/business/procedure-requests/$id/complete'));
}
