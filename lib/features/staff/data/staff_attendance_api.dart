import '../../../core/network/api_client.dart';
import 'models/staff_membership.dart';

/// /staff/attendance/{check-in,check-out,today} — a staff member's own
/// check-in/check-out, on the app itself. See StaffAttendanceController.
/// `businessId` disambiguates which membership this is for, same as the
/// `business.member` middleware's `business_id` field everywhere else.
///
/// When that business opted into GPS+QR verification
/// (StaffMembership.attendanceVerificationEnabled), check-in/check-out also
/// need [qrToken] (from scanning the business's display, see
/// AttendanceQrApi.current) and the caller's own [lat]/[lng] — omitted
/// entirely for a business that never turned verification on, so the plain
/// request shape is unchanged for everyone else.
class StaffAttendanceApi {
  final ApiClient _client;
  const StaffAttendanceApi(this._client);

  Future<AttendanceStatus> checkIn(int businessId, {String? qrToken, double? lat, double? lng}) async {
    final data = await _client.post(
          '/staff/attendance/check-in',
          data: {'business_id': businessId, 'qr_token': ?qrToken, 'lat': ?lat, 'lng': ?lng},
        )
        as Map<String, dynamic>;
    return AttendanceStatus.fromJson(data);
  }

  Future<AttendanceStatus> checkOut(int businessId, {String? qrToken, double? lat, double? lng}) async {
    final data = await _client.post(
          '/staff/attendance/check-out',
          data: {'business_id': businessId, 'qr_token': ?qrToken, 'lat': ?lat, 'lng': ?lng},
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
