import '../../../core/network/api_client.dart';
import 'models/hospital_department.dart';

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
}
