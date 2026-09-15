import '../../../core/network/api_client.dart';
import 'models/staff_group.dart';
import 'models/staff_member.dart';
import 'models/staff_membership.dart';

/// /business/{capabilities,staff} — a business owner delegating page
/// management to staff. See Api\V2\BusinessStaffController.
class StaffApi {
  final ApiClient _client;
  const StaffApi(this._client);

  Future<List<CapabilityOption>> capabilities() async {
    final data =
        await _client.get('/business/capabilities') as Map<String, dynamic>;
    return (data['capabilities'] as List<dynamic>? ?? [])
        .map((e) => CapabilityOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StaffMember>> list() async {
    final data = await _client.get('/business/staff') as Map<String, dynamic>;
    return (data['staff'] as List<dynamic>? ?? [])
        .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Grants (or re-grants) a staff member, resolved by phone — the owner
  /// knows their employee's phone number, not their internal user id.
  Future<StaffMember> add({
    required String phone,
    String? title,
    required List<String> capabilities,
    bool isActive = true,
  }) async {
    final data =
        await _client.post(
              '/business/staff',
              data: {
                'phone': phone,
                if (title != null && title.isNotEmpty) 'title': title,
                'capabilities': capabilities,
                'is_active': isActive,
              },
            )
            as Map<String, dynamic>;
    return StaffMember.fromJson(data['staff'] as Map<String, dynamic>);
  }

  Future<StaffMember> update(
    int userId, {
    String? title,
    List<String>? capabilities,
    bool? isActive,
  }) async {
    final data =
        await _client.patch(
              '/business/staff/$userId',
              data: {
                'title': ?title,
                'capabilities': ?capabilities,
                'is_active': ?isActive,
              },
            )
            as Map<String, dynamic>;
    return StaffMember.fromJson(data['staff'] as Map<String, dynamic>);
  }

  Future<void> remove(int userId) => _client.delete('/business/staff/$userId');

  /// GET /business/staff/groups — the roster grouped by capability, each
  /// card carrying today's operation count, attendance, and (drivers only)
  /// live delivery workload. Owner-only.
  Future<List<StaffGroup>> groups() async {
    final data = await _client.get('/business/staff/groups') as Map<String, dynamic>;
    return (data['groups'] as List<dynamic>? ?? [])
        .map((e) => StaffGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /business/memberships — the businesses I work for as staff, with
  /// what I'm allowed to do at each. May be called by any account.
  Future<List<StaffMembership>> memberships() async {
    final data = await _client.get('/business/memberships') as Map<String, dynamic>;
    return (data['memberships'] as List<dynamic>? ?? [])
        .map((e) => StaffMembership.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
