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
    final data =
        await _client.get('/clinics/$clinicId/slots', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, ClinicSlot.fromJson);
  }

  /// The next two weeks: every open time AND the strip of days (open by the clinic's weekly hours or not, how many
  /// times are left) — so the board can show the days the doctor sits, not only the ones that happen to have rows.
  Future<ClinicSlotsResult> slotsWithDays(int clinicId) async {
    final data = await _client.get('/clinics/$clinicId/slots') as Map<String, dynamic>;
    final rows = (data['data'] as List<dynamic>? ?? const [])
        .map((e) => ClinicSlot.fromJson(e as Map<String, dynamic>))
        .toList();
    final days = (data['days'] as List<dynamic>? ?? const [])
        .map((e) => ClinicDay.fromJson(e as Map<String, dynamic>))
        .toList();

    return ClinicSlotsResult(slots: rows, days: days);
  }

  /// [forName]/[forPhone]: the visit is for someone else — the account that books stays the patient of record.
  /// [specialtyServiceIds]: what the patient came for — one or several, from the specialty clinic's own list (optional).
  Future<ClinicAppointment> bookSlot(
    int slotId, {
    String? reason,
    List<int> specialtyServiceIds = const [],
    String? forName,
    String? forPhone,
  }) async {
    final data =
        await _client.post(
              '/clinic-slots/$slotId/book',
              data: {
                if (reason != null && reason.isNotEmpty) 'reason': reason,
                if (specialtyServiceIds.isNotEmpty) 'specialty_service_ids': specialtyServiceIds,
                if (forName != null && forName.isNotEmpty) 'for_name': forName,
                if (forName != null && forName.isNotEmpty && forPhone != null && forPhone.isNotEmpty) 'for_phone': forPhone,
              },
            )
            as Map<String, dynamic>;
    return ClinicAppointment.fromJson(
      data['appointment'] as Map<String, dynamic>,
    );
  }

  Future<Paginated<ClinicAppointment>> myAppointments({
    String? status,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/clinic-appointments',
              query: {'status': ?status, 'page': page},
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, ClinicAppointment.fromJson);
  }

  /// Every visit kind the clinic prices, and what the caller still owes it from earlier visits.
  Future<VisitKindsResult> visitKinds(int clinicId) async =>
      VisitKindsResult.fromJson(await _client.get('/clinics/$clinicId/visit-kinds') as Map<String, dynamic>);

  /// «نعم، دفعت هذا المبلغ».
  Future<ClinicAppointment> confirmPayment(int appointmentId, int paymentId) async {
    final data =
        await _client.post('/clinic-appointments/$appointmentId/payments/$paymentId/confirm') as Map<String, dynamic>;
    return ClinicAppointment.fromJson(data['appointment'] as Map<String, dynamic>);
  }

  /// «لم أدفع هذا المبلغ»: the clinic is told, the payment stays on record as disputed.
  Future<ClinicAppointment> disputePayment(int appointmentId, int paymentId, {String? note}) async {
    final data =
        await _client.post(
              '/clinic-appointments/$appointmentId/payments/$paymentId/dispute',
              data: {if (note != null && note.isNotEmpty) 'note': note},
            )
            as Map<String, dynamic>;
    return ClinicAppointment.fromJson(data['appointment'] as Map<String, dynamic>);
  }

  Future<ClinicAppointment> cancel(int id) async {
    final data =
        await _client.post('/clinic-appointments/$id/cancel')
            as Map<String, dynamic>;
    return ClinicAppointment.fromJson(
      data['appointment'] as Map<String, dynamic>,
    );
  }

  Future<ClinicAppointment> reschedule(int id, DateTime scheduledAt) async {
    final data =
        await _client.post(
              '/clinic-appointments/$id/reschedule',
              data: {'scheduled_at': scheduledAt.toIso8601String()},
            )
            as Map<String, dynamic>;
    return ClinicAppointment.fromJson(
      data['appointment'] as Map<String, dynamic>,
    );
  }
}
