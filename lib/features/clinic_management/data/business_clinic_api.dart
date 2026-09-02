import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/business_clinic_appointment.dart';
import 'models/business_clinic_slot.dart';

/// /business/clinic-appointments, /business/clinic-slots — the clinic's own
/// side. See Api\V2\BusinessClinicAppointmentController. Gated server-side
/// on the "clinic" business capability (owner, or a delegate — e.g. the
/// secretary — granted it).
class BusinessClinicApi {
  final ApiClient _client;
  const BusinessClinicApi(this._client);

  // ─────────────────────────── Appointments ───────────────────────────

  Future<Paginated<BusinessClinicAppointment>> appointments({String? status, int page = 1}) async {
    final data = await _client.get(
      '/business/clinic-appointments',
      query: {if (status != null) 'status': status, 'page': page},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, BusinessClinicAppointment.fromJson);
  }

  Future<BusinessClinicAppointment> confirm(int id) => _act('$id/confirm');
  Future<BusinessClinicAppointment> reject(int id) => _act('$id/reject');
  Future<BusinessClinicAppointment> complete(int id) => _act('$id/complete');
  Future<BusinessClinicAppointment> noShow(int id) => _act('$id/no-show');

  Future<BusinessClinicAppointment> reschedule(int id, DateTime scheduledAt, {int? durationMinutes}) async {
    final data = await _client.post(
      '/business/clinic-appointments/$id/reschedule',
      data: {
        // Sent as the wall-clock digits the picker returned (no timezone
        // math) — matches ClinicApi.reschedule() on the patient side and
        // how the backend stores/echoes every scheduled_at in this app.
        'scheduled_at': scheduledAt.toIso8601String(),
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
      },
    ) as Map<String, dynamic>;
    return BusinessClinicAppointment.fromJson(data['appointment'] as Map<String, dynamic>);
  }

  Future<BusinessClinicAppointment> _act(String path) async {
    final data = await _client.post('/business/clinic-appointments/$path') as Map<String, dynamic>;
    return BusinessClinicAppointment.fromJson(data['appointment'] as Map<String, dynamic>);
  }

  // ─────────────────────────── Slots ───────────────────────────

  Future<Paginated<BusinessClinicSlot>> slots({bool includeBooked = false, int page = 1}) async {
    final data = await _client.get(
      '/business/clinic-slots',
      query: {'include_booked': includeBooked, 'page': page},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, BusinessClinicSlot.fromJson);
  }

  /// Publishes one slot (`startsAt`) or several at once (`slots`) — see
  /// [reschedule] for the wall-clock convention this follows.
  Future<({int created, int skipped})> publishSlots({DateTime? startsAt, List<DateTime>? slots}) async {
    final data = await _client.post(
      '/business/clinic-slots',
      data: {
        if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
        if (slots != null) 'slots': slots.map((d) => d.toIso8601String()).toList(),
      },
    ) as Map<String, dynamic>;
    return (created: data['created'] as int, skipped: data['skipped'] as int);
  }

  /// A recurring weekly grid: `weekdays` (0=Sun..6=Sat) over a start/end
  /// time range at `intervalMinutes` apart, repeated for `weeks` weeks.
  Future<Map<String, dynamic>> generateSlots({
    required List<int> weekdays,
    required String startTime,
    required String endTime,
    int? intervalMinutes,
    int weeks = 4,
  }) async {
    final data = await _client.post(
      '/business/clinic-slots/generate',
      data: {
        'weekdays': weekdays,
        'start_time': startTime,
        'end_time': endTime,
        if (intervalMinutes != null) 'interval_minutes': intervalMinutes,
        'weeks': weeks,
      },
    ) as Map<String, dynamic>;
    return data;
  }

  Future<void> deleteSlot(int slotId) => _client.delete('/business/clinic-slots/$slotId');
}
