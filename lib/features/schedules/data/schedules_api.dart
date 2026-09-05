import '../../../core/env/env.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/trip_reservation.dart';
import 'models/trip_run.dart';
import 'models/trip_schedule.dart';

/// One "pick a business as this stop" search result — see
/// Api\V2\TripScheduleController::businessLookup.
class StopBusinessOption {
  final int id;
  final String name;
  final String? logoUrl;

  const StopBusinessOption({required this.id, required this.name, this.logoUrl});

  factory StopBusinessOption.fromJson(Map<String, dynamic> json) => StopBusinessOption(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    logoUrl: Env.assetUrl(json['logo'] as String?),
  );
}

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
    final data =
        await _client.get(
              '/search/schedules',
              query: {
                'origin_governorate_id': originGovernorateId,
                'destination_governorate_id': destinationGovernorateId,
                if (date != null) 'date': _dateOnly(date),
              },
            )
            as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? [])
        .map((e) => TripScheduleResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripReservation> reserve(
    int scheduleId, {
    int units = 1,
    String? notes,
  }) async {
    final data =
        await _client.post(
              '/schedules/$scheduleId/reserve',
              data: {
                'units': units,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
              },
            )
            as Map<String, dynamic>;
    return TripReservation.fromJson(
      data['reservation'] as Map<String, dynamic>,
    );
  }

  Future<Paginated<TripReservation>> myReservations({int page = 1}) async {
    final data =
        await _client.get('/schedules/my-reservations', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, TripReservation.fromJson);
  }

  Future<void> cancel(int reservationId) =>
      _client.post('/schedules/reservations/$reservationId/cancel');

  // ─────────────────────── Carrier (business) side ───────────────────────

  Future<Paginated<TripSchedule>> myTripSchedules({int page = 1}) async {
    final data =
        await _client.get('/business/schedules', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, TripSchedule.fromJson);
  }

  Future<TripSchedule> createTripSchedule(Map<String, dynamic> payload) async {
    final data =
        await _client.post('/business/schedules', data: payload)
            as Map<String, dynamic>;
    return TripSchedule.fromJson(data['schedule'] as Map<String, dynamic>);
  }

  Future<TripSchedule> updateTripSchedule(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final data =
        await _client.patch('/business/schedules/$id', data: payload)
            as Map<String, dynamic>;
    return TripSchedule.fromJson(data['schedule'] as Map<String, dynamic>);
  }

  Future<void> deleteTripSchedule(int id) =>
      _client.delete('/business/schedules/$id');

  /// Search-as-you-type for the "pick a business as this stop" field.
  Future<List<StopBusinessOption>> businessLookup(String q) async {
    if (q.trim().isEmpty) return const [];
    final data =
        await _client.get('/business/schedules/business-lookup', query: {'q': q.trim()})
            as Map<String, dynamic>;
    final businesses = data['businesses'] as List<dynamic>? ?? [];
    return businesses.map((e) => StopBusinessOption.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Paginated<TripReservation>> incomingReservations({
    String? status,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/business/schedules/reservations',
              query: {'status': ?status, 'page': page},
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, TripReservation.fromJson);
  }

  Future<TripReservation> confirmReservation(int id) async {
    final data =
        await _client.post('/business/schedules/reservations/$id/confirm')
            as Map<String, dynamic>;
    return TripReservation.fromJson(
      data['reservation'] as Map<String, dynamic>,
    );
  }

  Future<TripReservation> completeReservation(int id) async {
    final data =
        await _client.post('/business/schedules/reservations/$id/complete')
            as Map<String, dynamic>;
    return TripReservation.fromJson(
      data['reservation'] as Map<String, dynamic>,
    );
  }

  Future<void> rejectReservation(int id) =>
      _client.post('/business/schedules/reservations/$id/reject');

  // ─────────────────── Carrier: live run execution ───────────────────

  Future<TripRun> startRun(
    int scheduleId, {
    int? passengerCount,
    List<Map<String, dynamic>> manifest = const [],
  }) async {
    final data =
        await _client.post(
              '/business/schedules/$scheduleId/runs',
              data: {'passenger_count': passengerCount, if (manifest.isNotEmpty) 'manifest': manifest},
            )
            as Map<String, dynamic>;
    return TripRun.fromJson(data['run'] as Map<String, dynamic>);
  }

  Future<Paginated<TripRun>> myRuns({String? status, int page = 1}) async {
    final data =
        await _client.get('/business/schedules/runs', query: {'status': ?status, 'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, TripRun.fromJson);
  }

  Future<TripRun> run(int runId) async {
    final data = await _client.get('/business/schedules/runs/$runId') as Map<String, dynamic>;
    return TripRun.fromJson(data['run'] as Map<String, dynamic>);
  }

  Future<TripRun> arriveAtStop(int runId) async {
    final data = await _client.post('/business/schedules/runs/$runId/arrive') as Map<String, dynamic>;
    return TripRun.fromJson(data['run'] as Map<String, dynamic>);
  }

  Future<TripRun> advanceRun(int runId) async {
    final data = await _client.post('/business/schedules/runs/$runId/advance') as Map<String, dynamic>;
    return TripRun.fromJson(data['run'] as Map<String, dynamic>);
  }

  /// [items] keyed by manifest item id -> {delivered_qty, returned_qty}.
  Future<TripRun> reconcileRun(int runId, Map<int, ({int delivered, int returned})> items) async {
    final data =
        await _client.post(
              '/business/schedules/runs/$runId/reconcile',
              data: {
                'items': items.entries
                    .map((e) => {'manifest_item_id': e.key, 'delivered_qty': e.value.delivered, 'returned_qty': e.value.returned})
                    .toList(),
              },
            )
            as Map<String, dynamic>;
    return TripRun.fromJson(data['run'] as Map<String, dynamic>);
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
