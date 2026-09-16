import '../../../core/network/api_client.dart';

class AttendanceQrCode {
  final String token;
  final DateTime expiresAt;
  const AttendanceQrCode({required this.token, required this.expiresAt});

  factory AttendanceQrCode.fromJson(Map<String, dynamic> json) => AttendanceQrCode(
    token: json['token'] as String,
    expiresAt: DateTime.parse(json['expires_at'] as String),
  );
}

/// The owner-only half of GPS+QR attendance verification —
/// StaffAttendanceController::currentQr/updateSettings. `current()` always
/// returns the SAME code until it's scanned or expires, so the display
/// screen polling this periodically costs one request per business, not
/// per employee.
class AttendanceQrApi {
  final ApiClient _client;
  const AttendanceQrApi(this._client);

  Future<AttendanceQrCode> current() async {
    final data = await _client.get('/business/staff/attendance-qr') as Map<String, dynamic>;
    return AttendanceQrCode.fromJson(data);
  }

  Future<bool> settings() async {
    final data = await _client.get('/business/staff/attendance-settings') as Map<String, dynamic>;
    return data['enabled'] as bool;
  }

  Future<bool> updateSettings(bool enabled) async {
    final data = await _client.patch('/business/staff/attendance-settings', data: {'enabled': enabled}) as Map<String, dynamic>;
    return data['enabled'] as bool;
  }
}
