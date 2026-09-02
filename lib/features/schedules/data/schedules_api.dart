import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/trip_reservation.dart';
import 'models/trip_schedule.dart';

/// Trip-leg search (GET /search/schedules) + reservation (POST/GET under
/// /schedules — a different prefix, not a typo). See
/// Api\V2\TripScheduleController::search + Api\V2\TripReservationController.
/// Domestic (governorate-pair) search only; international routes and the
/// vehicle-type/day-of-week filters aren't wired up in this app yet.
class SchedulesApi {
  final ApiClient _client;
  const SchedulesApi(this._client);

  Future<List<TripScheduleResult>> search({
    required int originGovernorateId,
    required int destinationGovernorateId,
    DateTime? date,
  }) async {
    final data = await _client.get(
      '/search/schedules',
      query: {
        'origin_governorate_id': originGovernorateId,
        'destination_governorate_id': destinationGovernorateId,
        if (date != null) 'date': _dateOnly(date),
      },
    ) as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? [])
        .map((e) => TripScheduleResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripReservation> reserve(int scheduleId, {int units = 1, String? notes}) async {
    final data = await _client.post(
      '/schedules/$scheduleId/reserve',
      data: {'units': units, if (notes != null && notes.isNotEmpty) 'notes': notes},
    ) as Map<String, dynamic>;
    return TripReservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  Future<Paginated<TripReservation>> myReservations({int page = 1}) async {
    final data = await _client.get(
      '/schedules/my-reservations',
      query: {'page': page},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, TripReservation.fromJson);
  }

  Future<void> cancel(int reservationId) => _client.post('/schedules/reservations/$reservationId/cancel');

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
