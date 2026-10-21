import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/booking.dart';
import 'models/booking_financial_preview.dart';
import 'models/booking_form.dart';
import 'models/unit_discovery.dart';
import '../../booking_settings/data/models/room_models.dart';

String _dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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

  /// «تغيير الموعد»: the customer moves his own pending / accepted booking to a new start (the same length). [startsAt] is
  /// the platform's wall clock — sent as «yyyy-MM-dd HH:mm:ss», never as a UTC instant.
  Future<Booking> reschedule(int id, DateTime startsAt) async {
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp = '${startsAt.year.toString().padLeft(4, '0')}-${two(startsAt.month)}-${two(startsAt.day)} ${two(startsAt.hour)}:${two(startsAt.minute)}:00';
    final data = await _client.post('/bookings/$id/reschedule', data: {'starts_at': stamp}) as Map<String, dynamic>;
    return _booking(data);
  }

  Future<Booking> cancel(int id) async {
    final data =
        await _client.post('/bookings/$id/cancel') as Map<String, dynamic>;
    return _booking(data);
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
    return _booking(data);
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
    return _booking(data);
  }

  /// This party's own side of what the booking needs up front.
  Future<BookingFinancialPreview> financialPreview(int id) async {
    final data = await _client.get('/bookings/$id/financial-preview') as Map<String, dynamic>;
    return BookingFinancialPreview.fromJson(data);
  }

  Future<Booking> accept(int id) async {
    final data =
        await _client.post('/bookings/$id/accept') as Map<String, dynamic>;
    return _booking(data);
  }

  Future<Booking> reject(int id) async {
    final data =
        await _client.post('/bookings/$id/reject') as Map<String, dynamic>;
    return _booking(data);
  }

  /// The business's own commitment that it's ready to execute — start()
  /// refuses to move a booking to in-progress until both parties have
  /// confirmed (see ServiceExecutionEngine::moveBookingToInProgress).
  Future<Booking> businessConfirm(int id) async {
    final data =
        await _client.post('/bookings/$id/business-confirm')
            as Map<String, dynamic>;
    return _booking(data);
  }

  Future<Booking> start(int id) async {
    final data =
        await _client.post('/bookings/$id/start') as Map<String, dynamic>;
    return _booking(data);
  }

  Future<Booking> complete(int id) async {
    final data =
        await _client.post('/bookings/$id/complete') as Map<String, dynamic>;
    return _booking(data);
  }

  /// The client says they paid the booking in cash - also counts as their
  /// agreement to release the frozen deposit.
  Future<Booking> confirmPayment(int id) async {
    final data = await _client.post('/bookings/$id/confirm-payment') as Map<String, dynamic>;
    return _booking(data);
  }

  /// The business (or delegated staff, via [businessId]) says it received
  /// the cash - same effect on the deposit as the client's confirmation.
  Future<Booking> businessConfirmPayment(int id, {int? businessId}) async {
    final path = '/business/bookings/$id/confirm-payment${businessId == null ? '' : '?business_id=$businessId'}';
    final data = await _client.post(path) as Map<String, dynamic>;
    return _booking(data);
  }

  /// The rooms this stay could be put in (the free ones), and the one it has — the hotel's own view.
  Future<BookingRoomsPayload> stayRooms(int id) async {
    final data = await _client.get('/business/bookings/$id/rooms') as Map<String, dynamic>;
    return BookingRoomsPayload.fromJson(data);
  }

  Future<void> assignRoom(int id, int roomId) => _client.post('/business/bookings/$id/room', data: {'room_id': roomId});

  /// «قبول الديبوزت كدفعة»: the customer asks that the frozen deposit be taken as a payment…
  Future<Booking> requestDepositAsPayment(int id) async {
    final data = await _client.post('/bookings/$id/deposit/request-as-payment') as Map<String, dynamic>;
    return _booking(data);
  }

  /// …and the business accepts or declines (an optional term of the business).
  Future<Booking> acceptDepositAsPayment(int id) async {
    final data = await _client.post('/bookings/$id/deposit/accept-as-payment') as Map<String, dynamic>;
    return _booking(data);
  }

  Future<Booking> declineDepositAsPayment(int id) async {
    final data = await _client.post('/bookings/$id/deposit/decline-as-payment') as Map<String, dynamic>;
    return _booking(data);
  }

  /// «استلمت العربون»: the deposit taken outside the platform arrived ([method] `cash` | `transfer`).
  Future<Booking> confirmExternalDeposit(int id, String method, {int? businessId}) async {
    final path = '/business/bookings/$id/deposit/confirm-received${businessId == null ? '' : '?business_id=$businessId'}';
    final data = await _client.post(path, data: {'method': method}) as Map<String, dynamic>;
    return _booking(data);
  }

  /// «قبول العربون»: accepted with no deposit paid outside the platform.
  Future<Booking> waiveExternalDeposit(int id, {int? businessId}) async {
    final path = '/business/bookings/$id/deposit/waive${businessId == null ? '' : '?business_id=$businessId'}';
    final data = await _client.post(path) as Map<String, dynamic>;
    return _booking(data);
  }

  /// A booking out of a `{booking, deposit_as_payment, …}` reply — the deposit-as-payment state rides beside the booking.
  Booking _booking(Map<String, dynamic> data) {
    final booking = Map<String, dynamic>.from(data['booking'] as Map<String, dynamic>);
    if (data['deposit_as_payment'] != null) booking['deposit_as_payment'] = data['deposit_as_payment'];

    return Booking.fromJson(booking);
  }

  /// Either party agreeing the deal succeeded and the deposit should be
  /// released — once BOTH the client and business have agreed, the backend
  /// releases it automatically (BookingDepositService::agreeRelease).
  Future<Booking> agreeReleaseDeposit(int id) async {
    final data =
        await _client.post('/bookings/$id/deposit/agree-release')
            as Map<String, dynamic>;
    return _booking(data);
  }

  /// Either party agreeing the deal did NOT go through — once both agree,
  /// the deposit refunds to the client automatically.
  Future<Booking> agreeRefundDeposit(int id) async {
    final data =
        await _client.post('/bookings/$id/deposit/agree-refund')
            as Map<String, dynamic>;
    return _booking(data);
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
    // «Day use»: the guest names only a date — the room type names the window and the flat price
    DateTime? dayUseDate,
    // «كورس»: the group joined — the booking is the enrolment
    int? courseGroupId,
    // «كرسي وعليه الحلاق»: the person the customer chose; none = whoever is free
    int? chairId,
    // «اختر مقدّم الخدمة»: the staff member the customer wants; none = the business decides
    int? providerId,
    // «مصري أو مقيم» (`local`) / «أجنبي» (`foreign`): the guest's declaration for a room type sold to one of them only
    String? guestOrigin,
  }) async {
    final data =
        await _client.post(
              '/bookings',
              data: {
                'business_id': businessId,
                'service_id': serviceId,
                'bookable_id': ?bookableId,
                if (offeringId != null && offeringId > 0) ...{'offering_id': offeringId, 'offering_type': ?offeringType},
                if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
                if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
                if (dayUseDate != null) ...{'day_use': true, 'date': _dateOnly(dayUseDate)},
                'all_day': allDay,
                'party_size': ?partySize,
                'quantity': ?quantity,
                'guest_origin': ?guestOrigin,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                if (meta != null && meta.isNotEmpty) 'meta': meta,
                if (optionIds.isNotEmpty) 'option_ids': optionIds,
                'course_group_id': ?courseGroupId,
                'chair_id': ?chairId,
                'provider_id': ?providerId,
              },
            )
            as Map<String, dynamic>;
    return _booking(data);
  }

  /// «جاء عميل بدون حجز»: the business books a customer who is standing there. A phone that belongs to an account puts
  /// the booking on that account; with none it is a NAMED guest ([guestName] required), never counted or rated.
  Future<Booking> createForGuest({
    required int serviceId,
    int? bookableId,
    int? offeringId,
    DateTime? startsAt,
    DateTime? endsAt,
    int? partySize,
    int? quantity,
    String? notes,
    String? guestName,
    String? guestPhone,
    int? clientId,
  }) async {
    final data =
        await _client.post(
              '/bookings/by-business',
              data: {
                'service_id': serviceId,
                'bookable_id': ?bookableId,
                'offering_id': ?offeringId,
                if (offeringId != null) 'offering_type': 'service_price',
                if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
                if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
                'all_day': false,
                'party_size': ?partySize,
                'quantity': ?quantity,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                if (guestName != null && guestName.isNotEmpty) 'guest_name': guestName,
                if (guestPhone != null && guestPhone.isNotEmpty) 'guest_phone': guestPhone,
                'client_id': ?clientId,
              },
            )
            as Map<String, dynamic>;
    return _booking(data);
  }

  /// Does this phone belong to an account — and how many dealings has he already completed with this business.
  Future<CustomerLookup> customerLookup(String phone) async {
    final data = await _client.get('/bookings/customer-lookup', query: {'phone': phone}) as Map<String, dynamic>;
    final customer = data['customer'] as Map<String, dynamic>?;

    return CustomerLookup(
      found: data['found'] == true,
      customerId: (customer?['id'] as num?)?.toInt(),
      name: customer?['name'] as String?,
      previousDealings: (data['previous_dealings'] as num?)?.toInt() ?? 0,
    );
  }

  /// Same price math as [create] — line + selected modifiers per period,
  /// summed then multiplied by quantity — with no booking row created. See
  /// Api\V2\BookingController::preview. Null fields mean "not chosen yet"
  /// (e.g. no dates picked), which the backend prices as best it can (a
  /// single period) rather than rejecting.
  Future<BookingPreview> preview({
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
    DateTime? dayUseDate,
  }) async {
    final data =
        await _client.post(
              '/bookings/preview',
              data: {
                'business_id': businessId,
                'service_id': serviceId,
                'bookable_id': ?bookableId,
                if (offeringId != null && offeringId > 0) ...{'offering_id': offeringId, 'offering_type': ?offeringType},
                if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
                if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
                if (dayUseDate != null) ...{'day_use': true, 'date': _dateOnly(dayUseDate)},
                'quantity': ?quantity,
                'party_size': ?partySize,
                if (optionIds.isNotEmpty) 'option_ids': optionIds,
              },
            )
            as Map<String, dynamic>;
    return BookingPreview.fromJson(data);
  }

  /// The whole answer of `/discovery/units/{business}` — kinds, units and the booking shape the page is drawn in.
  Future<UnitCatalog> unitCatalog(int businessId) async {
    final data = await _client.get('/discovery/units/$businessId') as Map<String, dynamic>;
    return UnitCatalog.fromJson(data);
  }

  /// One day as a grid of start times and how many units are free from each (hourly venues, tables).
  Future<DayGrid> dayGrid({
    required int businessId,
    required DateTime date,
    int durationMinutes = 60,
    int stepMinutes = 60,
    int? partySize,
    int? serviceId,
    String? itemType,
  }) async {
    final day = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data =
        await _client.get(
              '/discovery/units/$businessId/day-grid',
              query: {
                'date': day,
                'duration_minutes': durationMinutes,
                'step_minutes': stepMinutes,
                'party_size': ?partySize,
                'service_id': ?serviceId,
                if (itemType != null && itemType.isNotEmpty) 'item_type': itemType,
              },
            )
            as Map<String, dynamic>;

    return DayGrid.fromJson(data);
  }

  /// One day of an appointment with the business itself as start times (`free` 0/1) — no units.
  Future<DayGrid> appointmentGrid({required int businessId, required DateTime date, int? offeringId, int? chairId, int? providerId}) async {
    final day = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data =
        await _client.get(
              '/discovery/appointments/$businessId/day-grid',
              query: {'date': day, 'offering_id': ?offeringId, 'chair_id': ?chairId, 'provider_id': ?providerId},
            )
            as Map<String, dynamic>;

    return DayGrid.fromJson(data);
  }

  /// «بالدور»: the turn a customer would get on [date] and when it should come. Nothing is taken until [createQueued].
  Future<QueuePreview> appointmentQueue({required int businessId, required DateTime date, int? offeringId, int? chairId}) async {
    final day = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data =
        await _client.get('/discovery/appointments/$businessId/queue', query: {'date': day, 'offering_id': ?offeringId, 'chair_id': ?chairId})
            as Map<String, dynamic>;

    return QueuePreview.fromJson(data);
  }

  /// «بالدور»: book by turn — the day is named, the business gives the turn and the time.
  Future<Booking> createQueued({
    required int businessId,
    required int serviceId,
    required int offeringId,
    required DateTime date,
    String? notes,
    Map<String, dynamic>? meta,
    int? chairId,
  }) async {
    final day = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data =
        await _client.post(
              '/bookings/queue',
              data: {
                'business_id': businessId,
                'service_id': serviceId,
                'offering_id': offeringId,
                'offering_type': 'service_price',
                'date': day,
                'chair_id': ?chairId,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                if (meta != null && meta.isNotEmpty) 'meta': meta,
              },
            )
            as Map<String, dynamic>;

    return _booking(data);
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

/// The answer to «does this phone belong to an account»: his name and his earlier dealings with the asking business.
class CustomerLookup {
  final bool found;
  final int? customerId;
  final String? name;
  final int previousDealings;

  const CustomerLookup({required this.found, this.customerId, this.name, this.previousDealings = 0});
}
