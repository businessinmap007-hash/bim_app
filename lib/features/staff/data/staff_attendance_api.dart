import '../../../core/network/api_client.dart';
import 'models/staff_membership.dart';

/// /staff/attendance/{check-in,check-out,today} — a staff member's own
/// check-in/check-out, on the app itself. See StaffAttendanceController.
/// `businessId` disambiguates which membership this is for, same as the
/// `business.member` middleware's `business_id` field everywhere else.
class StaffAttendanceApi {
  final ApiClient _client;
  const StaffAttendanceApi(this._client);

  Future<AttendanceStatus> checkIn(int businessId) async {
    final data = await _client.post(
          '/staff/attendance/check-in',
          data: {'business_id': businessId},
        )
        as Map<String, dynamic>;
    return AttendanceStatus.fromJson(data);
  }

  Future<AttendanceStatus> checkOut(int businessId) async {
    final data = await _client.post(
          '/staff/attendance/check-out',
          data: {'business_id': businessId},
        )
        as Map<String, dynamic>;
    return AttendanceStatus.fromJson(data);
  }

  Future<AttendanceStatus> today(int businessId) async {
    final data = await _client.get(
          '/staff/attendance/today',
          query: {'business_id': businessId},
        )
        as Map<String, dynamic>?;
    return AttendanceStatus.fromJson(data);
  }
}
