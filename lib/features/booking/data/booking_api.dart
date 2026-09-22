import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/booking.dart';
import 'models/booking_financial_preview.dart';
import 'models/booking_form.dart';
import 'models/unit_discovery.dart';

/// /bookings — the customer's own booking requests. See Api\V2\BookingController.
class BookingApi {
  final ApiClient _client;
  const BookingApi(this._client);

  Future<Paginated<Booking>> list({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final data =
        await _client.get(
              '/bookings',
              query: {'status': ?status, 'page': page, 'per_page': perPage},
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(
      data['bookings'] as Map<String, dynamic>,
      Booking.fromJson,
    );
  }

  Future<Booking> cancel(int id) async {
    final data =
        await _client.post('/bookings/$id/cancel') as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// The customer's own "I'm ready" -- start() (the business's action) won't
  /// move a booking to in-progress until both this AND the business's own
  /// confirmation exist (Api\V2\BookingController::clientConfirm). Only
  /// needs [pin] when the booking actually holds a wallet deposit; call
  /// with no pin first and only prompt for one if the server comes back
  /// asking for it (an `errors.pin` field on the 422).
  Future<Booking> clientConfirm(int id, {String? pin}) async {
    final data =
        await _client.post(
              '/bookings/$id/client-confirm',
              data: {'pin': ?pin},
            )
            as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// The business's own incoming-booking queue. Reachable by the owner or a
  /// delegated staff member with the bookings capability — [businessId]
  /// disambiguates which membership this is for, same as
  /// StaffAttendanceApi's own `business_id` field, and is safely omitted
  /// when the caller is the business account itself.
  Future<Paginated<Booking>> listBusiness({
    String? status,
    int page = 1,
    int perPage = 20,
    int? businessId,
  }) async {
    final data =
        await _client.get(
              '/business/bookings',
              query: {
                'business_id': ?businessId,
                'status': ?status,
                'page': page,
                'per_page': perPage,
              },
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(
      data['bookings'] as Map<String, dynamic>,
      Booking.fromJson,
    );
  }

  Future<Booking> show(int id) async {
    final data = await _client.get('/bookings/$id') as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// This party's own side of what the booking needs up front.
  Future<BookingFinancialPreview> financialPreview(int id) async {
    final data = await _client.get('/bookings/$id/financial-preview') as Map<String, dynamic>;
    return BookingFinancialPreview.fromJson(data);
  }

  Future<Booking> accept(int id) async {
    final data =
        await _client.post('/bookings/$id/accept') as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  Future<Booking> reject(int id) async {
    final data =
        await _client.post('/bookings/$id/reject') as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// The business's own commitment that it's ready to execute — start()
  /// refuses to move a booking to in-progress until both parties have
  /// confirmed (see ServiceExecutionEngine::moveBookingToInProgress).
  Future<Booking> businessConfirm(int id) async {
    final data =
        await _client.post('/bookings/$id/business-confirm')
            as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  Future<Booking> start(int id) async {
    final data =
        await _client.post('/bookings/$id/start') as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  Future<Booking> complete(int id) async {
    final data =
        await _client.post('/bookings/$id/complete') as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// The client says they paid the booking in cash - also counts as their
  /// agreement to release the frozen deposit.
  Future<Booking> confirmPayment(int id) async {
    final data = await _client.post('/bookings/$id/confirm-payment') as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// The business (or delegated staff, via [businessId]) says it received
  /// the cash - same effect on the deposit as the client's confirmation.
  Future<Booking> businessConfirmPayment(int id, {int? businessId}) async {
    final path = '/business/bookings/$id/confirm-payment${businessId == null ? '' : '?business_id=$businessId'}';
    final data = await _client.post(path) as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// Either party agreeing the deal succeeded and the deposit should be
  /// released — once BOTH the client and business have agreed, the backend
  /// releases it automatically (BookingDepositService::agreeRelease).
  Future<Booking> agreeReleaseDeposit(int id) async {
    final data =
        await _client.post('/bookings/$id/deposit/agree-release')
            as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// Either party agreeing the deal did NOT go through — once both agree,
  /// the deposit refunds to the client automatically.
  Future<Booking> agreeRefundDeposit(int id) async {
    final data =
        await _client.post('/bookings/$id/deposit/agree-refund')
            as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// Bookings this account still owes a deposit-settlement decision on —
  /// drives the mandatory prompt shown on app open/resume (see
  /// PendingSettlementGate). Api\V2\BookingController::pendingSettlements.
  Future<List<Booking>> pendingSettlements() async {
    final data =
        await _client.get('/bookings/pending-settlements')
            as Map<String, dynamic>;
    final rows = data['bookings'] as List<dynamic>? ?? [];
    return rows.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// What this business's booking screen must ask (Api\V2\BookingController::form).
  Future<BookingFormPayload> form(int businessId) async {
    final data =
        await _client.get('/bookings/form/$businessId') as Map<String, dynamic>;
    return BookingFormPayload.fromJson(data);
  }

  Future<Booking> create({
    required int businessId,
    required int serviceId,
    int? bookableId,
    int? offeringId,
    String? offeringType,
    DateTime? startsAt,
    DateTime? endsAt,
    bool allDay = false,
    int? partySize,
    int? quantity,
    String? notes,
    Map<String, dynamic>? meta,
    List<int> optionIds = const [],
  }) async {
    final data =
        await _client.post(
              '/bookings',
              data: {
                'business_id': businessId,
                'service_id': serviceId,
                'bookable_id': ?bookableId,
                'offering_id': ?offeringId,
                'offering_type': ?offeringType,
                if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
                if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
                'all_day': allDay,
                'party_size': ?partySize,
                'quantity': ?quantity,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                if (meta != null && meta.isNotEmpty) 'meta': meta,
                if (optionIds.isNotEmpty) 'option_ids': optionIds,
              },
            )
            as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// Same price math as [create] — line + selected modifiers per period,
  /// summed then multiplied by quantity — with no booking row created. See
  /// Api\V2\BookingController::preview. Null fields mean "not chosen yet"
  /// (e.g. no dates picked), which the backend prices as best it can (a
  /// single period) rather than rejecting.
  Future<double> preview({
    required int businessId,
    required int serviceId,
    int? bookableId,
    int? offeringId,
    String? offeringType,
    DateTime? startsAt,
    DateTime? endsAt,
    int? quantity,
    int? partySize,
    List<int> optionIds = const [],
  }) async {
    final data =
        await _client.post(
              '/bookings/preview',
              data: {
                'business_id': businessId,
                'service_id': serviceId,
                'bookable_id': ?bookableId,
                'offering_id': ?offeringId,
                'offering_type': ?offeringType,
                if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
                if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
                'quantity': ?quantity,
                'party_size': ?partySize,
                if (optionIds.isNotEmpty) 'option_ids': optionIds,
              },
            )
            as Map<String, dynamic>;
    return (data['price'] as num).toDouble();
  }

  /// The real named units this business has (rooms/tables/pitches), grouped
  /// by kind with price and — when a date window is given — live
  /// availability. See Api\V2\UnitDiscoveryController. Public endpoint, no
  /// auth needed, but the app always calls it signed in anyway.
  Future<List<UnitKindGroup>> discoverUnits({
    required int businessId,
    int? serviceId,
    String? itemType,
    DateTime? startsAt,
    DateTime? endsAt,
  }) async {
    final data =
        await _client.get(
              '/discovery/units/$businessId',
              query: {
                'service_id': ?serviceId,
                if (itemType != null && itemType.isNotEmpty)
                  'item_type': itemType,
                if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
                if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
              },
            )
            as Map<String, dynamic>;
    final kinds = data['kinds'] as List<dynamic>? ?? [];
    return kinds
        .map((e) => UnitKindGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
