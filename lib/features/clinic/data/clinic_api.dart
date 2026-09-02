import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/clinic_appointment.dart';
import 'models/clinic_slot.dart';

/// /clinics/{id}/slots, /clinic-slots/{id}/book, /clinic-appointments — the
/// patient side of clinic appointments. See Api\V2\ClinicAppointmentController.
/// Only slot-booking is wired up (immediately confirmed, no back-and-forth);
/// requesting an appointment at a preferred time for the clinic to decide
/// (`POST /clinic-appointments`) isn't built — slot-booking already covers
/// the common case and needs no extra clinic-side screen to make sense of.
class ClinicApi {
  final ApiClient _client;
  const ClinicApi(this._client);

  Future<Paginated<ClinicSlot>> slots(int clinicId, {int page = 1}) async {
    final data = await _client.get(
      '/clinics/$clinicId/slots',
      query: {'page': page},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, ClinicSlot.fromJson);
  }

  Future<ClinicAppointment> bookSlot(int slotId, {String? reason}) async {
    final data = await _client.post(
      '/clinic-slots/$slotId/book',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    ) as Map<String, dynamic>;
    return ClinicAppointment.fromJson(data['appointment'] as Map<String, dynamic>);
  }

  Future<Paginated<ClinicAppointment>> myAppointments({String? status, int page = 1}) async {
    final data = await _client.get(
      '/clinic-appointments',
      query: {if (status != null) 'status': status, 'page': page},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, ClinicAppointment.fromJson);
  }

  Future<ClinicAppointment> cancel(int id) async {
    final data = await _client.post('/clinic-appointments/$id/cancel') as Map<String, dynamic>;
    return ClinicAppointment.fromJson(data['appointment'] as Map<String, dynamic>);
  }

  Future<ClinicAppointment> reschedule(int id, DateTime scheduledAt) async {
    final data = await _client.post(
      '/clinic-appointments/$id/reschedule',
      data: {'scheduled_at': scheduledAt.toIso8601String()},
    ) as Map<String, dynamic>;
    return ClinicAppointment.fromJson(data['appointment'] as Map<String, dynamic>);
  }
}
