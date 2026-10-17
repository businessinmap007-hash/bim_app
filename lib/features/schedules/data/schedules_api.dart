import '../../../core/env/env.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/trip_parcel.dart';
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
/// Search covers domestic (governorate pair) and international (country pair)
/// routes, optionally by vehicle type; the carrier form publishes both kinds.
class SchedulesApi {
  final ApiClient _client;
  const SchedulesApi(this._client);

  /// Domestic: a governorate pair. International: a country pair. [vehicleTypeId]
  /// narrows either.
  Future<List<TripScheduleResult>> search({
    int? originGovernorateId,
    int? destinationGovernorateId,
    int? originCountryId,
    int? destinationCountryId,
    int? vehicleTypeId,
    DateTime? date,
  }) async {
    final data =
        await _client.get(
              '/search/schedules',
              query: {
                'origin_governorate_id': ?originGovernorateId,
                'destination_governorate_id': ?destinationGovernorateId,
                if (originCountryId != null) ...{
                  'scope': 'international',
                  'origin_country_id': originCountryId,
                  'destination_country_id': ?destinationCountryId,
                },
                'vehicle_type_id': ?vehicleTypeId,
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
    bool friendGuarantee = false,
  }) async {
    final data =
        await _client.post(
              '/schedules/$scheduleId/reserve',
              data: {
                'units': units,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                // short of the deposit and a friend will stand for him: invited right after
                if (friendGuarantee) 'friend_guarantee': true,
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

  /// The scheduling service's vehicle/cargo classes, optionally for one mode.
  Future<List<VehicleTypeOption>> vehicleTypes({String? mode}) async {
    final data = await _client.get('/schedules/vehicle-types', query: {'mode': ?(mode == null || mode.isEmpty ? null : mode)}) as Map<String, dynamic>;
    return (data['vehicle_types'] as List<dynamic>? ?? []).map((e) => VehicleTypeOption.fromJson(e as Map<String, dynamic>)).toList();
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

  /// «لم يحضر»: the seats are freed and the deposit stays held until given back or disputed.
  Future<TripReservation> noShowReservation(int id) async {
    final data = await _client.post('/business/schedules/reservations/$id/no-show') as Map<String, dynamic>;

    return TripReservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  /// The customer says he is there — always before the carrier.
  Future<TripReservation> confirmAttendance(int id) async {
    final data = await _client.post('/schedules/reservations/$id/attendance') as Map<String, dynamic>;

    return TripReservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  /// The carrier confirms the passenger boarded (after the customer; an off-app seat needs only the carrier).
  Future<TripReservation> carrierAttendance(int id) async {
    final data = await _client.post('/business/schedules/reservations/$id/attendance') as Map<String, dynamic>;

    return TripReservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  /// An off-app passenger appears in ratings once the fee is paid — taken from the carrier's wallet.
  Future<TripReservation> ratingVisibility(int id) async {
    final data = await _client.post('/business/schedules/reservations/$id/rating-visibility') as Map<String, dynamic>;

    return TripReservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  /// Holds seats for a passenger sold directly, outside the app: always a NAMED person.
  Future<TripReservation> addOfflinePassenger(int scheduleId, {required String name, String? phone, int units = 1}) async {
    final data = await _client.post(
      '/business/schedules/$scheduleId/block',
      data: {'units': units, 'passenger_name': name, if (phone != null && phone.isNotEmpty) 'passenger_phone': phone},
    ) as Map<String, dynamic>;

    return TripReservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  // ───────────────────────────── Parcels ─────────────────────────────

  Future<TripParcel> requestParcel(
    int scheduleId, {
    required String description,
    int? receiverUserId,
    String? receiverName,
    String? receiverPhone,
    String payer = 'receiver',
  }) async {
    final data = await _client.post(
      '/schedules/$scheduleId/parcels',
      data: {
        'description': description,
        'payer': payer,
        'receiver_user_id': ?receiverUserId,
        if (receiverName != null && receiverName.isNotEmpty) 'receiver_name': receiverName,
        if (receiverPhone != null && receiverPhone.isNotEmpty) 'receiver_phone': receiverPhone,
      },
    ) as Map<String, dynamic>;

    return TripParcel.fromJson(data['parcel'] as Map<String, dynamic>);
  }

  /// Parcels I send and parcels sent to me.
  Future<Paginated<TripParcel>> myParcels({int page = 1}) async {
    final data = await _client.get('/schedules/my-parcels', query: {'page': page}) as Map<String, dynamic>;

    return Paginated.fromJson(data, TripParcel.fromJson);
  }

  Future<TripParcel> _parcelAction(String path) async {
    final data = await _client.post(path) as Map<String, dynamic>;

    return TripParcel.fromJson(data['parcel'] as Map<String, dynamic>);
  }

  Future<TripParcel> acceptParcel(int id) => _parcelAction('/schedules/parcels/$id/accept');
  Future<TripParcel> regenerateParcelCode(int id) => _parcelAction('/schedules/parcels/$id/code');
  Future<TripParcel> cancelParcel(int id) => _parcelAction('/schedules/parcels/$id/cancel');

  Future<Paginated<TripParcel>> carrierParcels({String? status, int page = 1}) async {
    final data = await _client.get('/business/schedules/parcels', query: {'status': ?status, 'page': page}) as Map<String, dynamic>;

    return Paginated.fromJson(data, TripParcel.fromJson);
  }

  Future<TripParcel> priceParcel(int id, {required double price, int seats = 0, DateTime? expectedArrivalAt}) async {
    final data = await _client.post(
      '/business/schedules/parcels/$id/price',
      data: {'price': price, 'seats': seats, if (expectedArrivalAt != null) 'expected_arrival_at': expectedArrivalAt.toIso8601String()},
    ) as Map<String, dynamic>;

    return TripParcel.fromJson(data['parcel'] as Map<String, dynamic>);
  }

  /// Taken from the sender: the code he shows as a QR (scanned) or reads out (typed).
  Future<TripParcel> loadParcel(int id, String code, {bool cashCollected = false}) async {
    final data = await _client.post(
      '/business/schedules/parcels/$id/load',
      data: {'code': code, if (cashCollected) 'cash_collected': true},
    ) as Map<String, dynamic>;

    return TripParcel.fromJson(data['parcel'] as Map<String, dynamic>);
  }

  /// A parcel is a paid service: either side may dispute it through the shared dispute flow.
  Future<void> disputeParcel(int id, {required String reasonCode, String? reasonText}) =>
      _client.post('/schedules/parcels/$id/disputes', data: {'reason_code': reasonCode, if (reasonText != null && reasonText.isNotEmpty) 'reason_text': reasonText});
  Future<TripParcel> rejectParcel(int id) => _parcelAction('/business/schedules/parcels/$id/reject');

  /// Handed over against the code the receiver told the driver.
  Future<TripParcel> deliverParcel(int id, String code, {bool cashCollected = false}) async {
    final data = await _client.post(
      '/business/schedules/parcels/$id/deliver',
      data: {'code': code, if (cashCollected) 'cash_collected': true},
    ) as Map<String, dynamic>;

    return TripParcel.fromJson(data['parcel'] as Map<String, dynamic>);
  }

  // ─────────────────── Carrier: live run execution ───────────────────

  Future<TripRun> startRun(
    int scheduleId, {
    int? passengerCount,
    List<Map<String, dynamic>> manifest = const [],
    bool acknowledgePartial = false,
  }) async {
    final data =
        await _client.post(
              '/business/schedules/$scheduleId/runs',
              data: {
                'passenger_count': passengerCount,
                if (manifest.isNotEmpty) 'manifest': manifest,
                // leaving short of full, or with attendance unconfirmed, is the carrier's own explicit word
                if (acknowledgePartial) 'acknowledge_partial': true,
              },
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
