import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/booking_settings_models.dart';
import 'models/booking_terms.dart';
import 'models/add_on_models.dart';
import 'models/room_models.dart';
import '../../booking/data/models/child_policy.dart';
import '../../booking/data/models/gala_dinner.dart';
import '../../booking/data/models/hotel_season.dart';

/// /business/prices, /business/bookable-items, /business/working-hours —
/// business-only self-service (the `business` middleware gate on the
/// backend), always the caller's own account. See
/// Api\V2\BusinessServicePriceController / BusinessBookableItemController /
/// BusinessHoursController.
class BookingSettingsApi {
  final ApiClient _client;
  const BookingSettingsApi(this._client);

  Future<PricesOptionsPayload> pricesOptions() async {
    final data =
        await _client.get('/business/prices/options') as Map<String, dynamic>;
    return PricesOptionsPayload.fromJson(data);
  }

  Future<List<PriceRow>> prices() async {
    final data = await _client.get('/business/prices') as List<dynamic>;
    return data
        .map((e) => PriceRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PriceRow> createPrice({
    required int serviceId,
    required String bookableItemType,
    required double price,
    int? lineOptionId,
    String chargeMode = 'standard',
    double? chargeAmount,
  }) async {
    final data = await _client.post(
      '/business/prices',
      data: {
        'service_id': serviceId,
        'bookable_item_type': bookableItemType,
        'price': price,
        'line_option_id': ?lineOptionId,
        'charge_mode': chargeMode,
        'charge_amount': ?chargeAmount,
      },
    );
    return PriceRow.fromJson(data as Map<String, dynamic>);
  }

  Future<PriceRow> updatePrice(
    int id, {
    required int serviceId,
    required String bookableItemType,
    required double price,
    int? lineOptionId,
    required bool isActive,
    String chargeMode = 'standard',
    double? chargeAmount,
  }) async {
    final data = await _client.put(
      '/business/prices/$id',
      data: {
        'service_id': serviceId,
        'bookable_item_type': bookableItemType,
        'price': price,
        'line_option_id': ?lineOptionId,
        'is_active': isActive,
        'charge_mode': chargeMode,
        'charge_amount': ?chargeAmount,
      },
    );
    return PriceRow.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePrice(int id) => _client.delete('/business/prices/$id');

  Future<BookableItemsOptionsPayload> bookableItemsOptions() async {
    final data =
        await _client.get('/business/bookable-items/options')
            as Map<String, dynamic>;
    return BookableItemsOptionsPayload.fromJson(data);
  }

  Future<List<BookableItemRow>> bookableItems() async {
    final data = await _client.get('/business/bookable-items') as List<dynamic>;
    return data
        .map((e) => BookableItemRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BookableItemRow> createBookableItem({
    required int serviceId,
    required String itemType,
    required String code,
    int? lineOptionId,
    int? capacity,
    String? title,
    String? description,
    int? quantity,
  }) async {
    final data = await _client.post(
      '/business/bookable-items',
      data: {
        'service_id': serviceId,
        'item_type': itemType,
        'code': code,
        'line_option_id': ?lineOptionId,
        'capacity': ?capacity,
        'title': ?title,
        'description': ?description,
        'quantity': ?quantity,
      },
    );
    return BookableItemRow.fromJson(data as Map<String, dynamic>);
  }

  Future<BookableItemRow> updateBookableItem(
    int id, {
    required int serviceId,
    required String itemType,
    required String code,
    int? lineOptionId,
    String? description,
    int? capacity,
    int? quantity,
    String? status,
    String? guestScope,
    int? reserveRooms,
    // «إقامة فردية»: sent only when [sendSingle] — null then clears it
    bool sendSingle = false,
    double? singleOccupancyPercent,
  }) async {
    final data = await _client.put(
      '/business/bookable-items/$id',
      data: {
        'service_id': serviceId,
        'item_type': itemType,
        'code': code,
        'line_option_id': ?lineOptionId,
        'description': ?description,
        'capacity': ?capacity,
        'quantity': ?quantity,
        'status': ?status,
        'guest_scope': ?guestScope,
        'reserve_rooms': ?reserveRooms,
        if (sendSingle) 'single_occupancy_percent': singleOccupancyPercent,
      },
    );
    return BookableItemRow.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteBookableItem(int id) =>
      _client.delete('/business/bookable-items/$id');

  Future<void> addBookableItemImage(int itemId, String filePath) async {
    await _client.post(
      '/business/bookable-items/$itemId/images',
      data: FormData.fromMap({
        'images[0]': await MultipartFile.fromFile(filePath),
      }),
    );
  }

  Future<void> deleteBookableItemImage(int itemId, int imageId) =>
      _client.delete('/business/bookable-items/$itemId/images/$imageId');

  /// «إضافات الحجز»: meal plans (one choice by default) and the price of a room's own features.
  Future<BookingAddOns> bookingAddOns() async {
    final data = await _client.get('/business/booking-add-ons') as Map<String, dynamic>;
    return BookingAddOns.fromJson(data);
  }

  Future<BookingAddOns> saveBookingAddOns(BookingAddOns addOns) async {
    final data = await _client.put('/business/booking-add-ons', data: addOns.toJson()) as Map<String, dynamic>;
    return BookingAddOns.fromJson(data);
  }

  /// The features THIS room carries, and the ones it could.
  Future<List<UnitFeature>> unitFeatures(int itemId) async {
    final data = await _client.get('/business/bookable-items/$itemId/features') as Map<String, dynamic>;
    return parseUnitFeatures(data);
  }

  Future<List<UnitFeature>> saveUnitFeatures(int itemId, List<int> optionIds) async {
    final data = await _client.put('/business/bookable-items/$itemId/features', data: {'option_ids': optionIds}) as Map<String, dynamic>;
    return parseUnitFeatures(data);
  }

  /// «Day use» of a room type — the window and flat price the hotel set.
  Future<DayUseSettings> dayUse(int itemId) async {
    final data = await _client.get('/business/bookable-items/$itemId/day-use') as Map<String, dynamic>;
    return DayUseSettings.fromJson(data['day_use'] as Map<String, dynamic>);
  }

  Future<DayUseSettings> saveDayUse(int itemId, DayUseSettings settings) async {
    final data = await _client.put('/business/bookable-items/$itemId/day-use', data: settings.toJson()) as Map<String, dynamic>;
    return DayUseSettings.fromJson(data['day_use'] as Map<String, dynamic>);
  }

  /// «خصم الأسبوع والشهر» of a unit let by the period — percentages off the total for 7+ and 30+ days.
  Future<void> saveStayDiscounts(int itemId, {required double weekly, required double monthly}) {
    return _client.put('/business/bookable-items/$itemId/stay-discounts', data: {'weekly_percent': weekly, 'monthly_percent': monthly});
  }

  /// The hotel's own numbered rooms behind a room type (booking_stay only).
  Future<RoomsPayload> rooms(int itemId) async {
    final data = await _client.get('/business/bookable-items/$itemId/rooms') as Map<String, dynamic>;
    return RoomsPayload.fromJson(data);
  }

  Future<RoomsPayload> addRooms(int itemId, List<String> numbers) async {
    final data = await _client.post('/business/bookable-items/$itemId/rooms', data: {'numbers': numbers}) as Map<String, dynamic>;
    return RoomsPayload.fromJson(data);
  }

  Future<RoomsPayload> setRoomMaintenance(int itemId, int roomId, bool maintenance) async {
    final data = await _client.patch(
      '/business/bookable-items/$itemId/rooms/$roomId',
      data: {'status': maintenance ? 'maintenance' : 'available'},
    ) as Map<String, dynamic>;
    return RoomsPayload.fromJson(data);
  }

  Future<RoomsPayload> deleteRoom(int itemId, int roomId) async {
    final data = await _client.delete('/business/bookable-items/$itemId/rooms/$roomId') as Map<String, dynamic>;
    return RoomsPayload.fromJson(data);
  }

  /// «مواعيد الوجبات» — null until the hotel writes them.
  Future<Map<String, ({String? from, String? to})>?> mealTimes() async {
    final data = await _client.get('/business/meal-times') as Map<String, dynamic>;
    final t = data['times'];
    if (t is! Map<String, dynamic>) return null;
    return {
      for (final e in t.entries)
        e.key: (from: (e.value as Map<String, dynamic>?)?['from'] as String?, to: (e.value as Map<String, dynamic>?)?['to'] as String?),
    };
  }

  Future<void> saveMealTimes(Map<String, ({String? from, String? to})> times) =>
      _client.put('/business/meal-times', data: {for (final e in times.entries) e.key: {'from': e.value.from, 'to': e.value.to}});

  /// «المواسم»: the hotel's seasons, with its room types and meal plans for the form.
  Future<HotelSeasonsData> seasons() async =>
      HotelSeasonsData.fromJson(await _client.get('/business/seasons') as Map<String, dynamic>);

  Future<void> saveSeason(HotelSeason season) => season.id == 0
      ? _client.post('/business/seasons', data: season.toJson())
      : _client.put('/business/seasons/${season.id}', data: season.toJson());

  Future<void> deleteSeason(int id) => _client.delete('/business/seasons/$id');

  /// «غير قابل للاسترداد»: the hotel's discount for it — null when it sells only the flexible rate.
  Future<double?> nonRefundablePercent() async {
    final data = await _client.get('/business/booking-settings/rate-plans') as Map<String, dynamic>;
    return (data['non_refundable_percent'] as num?)?.toDouble();
  }

  Future<void> saveNonRefundablePercent(double? percent) =>
      _client.put('/business/booking-settings/rate-plans', data: {'non_refundable_percent': percent});

  /// «العشاء الإلزامي»: the hotel's gala nights from today on.
  Future<List<GalaDinner>> galaDinners() async {
    final data = await _client.get('/business/gala-dinners') as Map<String, dynamic>;
    return GalaDinner.listFrom(data['gala_dinners']);
  }

  /// Adds a gala night (id 0) or rewrites one.
  Future<void> saveGalaDinner(GalaDinner gala) => gala.id == 0
      ? _client.post('/business/gala-dinners', data: gala.toJson())
      : _client.put('/business/gala-dinners/${gala.id}', data: gala.toJson());

  Future<void> deleteGalaDinner(int id) => _client.delete('/business/gala-dinners/$id');

  /// «سياسة الأطفال» of the hotel — null until it writes one.
  Future<ChildPolicy?> childPolicy() async {
    final data = await _client.get('/business/child-policy') as Map<String, dynamic>;
    return ChildPolicy.fromJsonOrNull(data['policy']);
  }

  Future<ChildPolicy?> saveChildPolicy(ChildPolicy policy) async {
    final data = await _client.put('/business/child-policy', data: policy.toJson()) as Map<String, dynamic>;
    return ChildPolicy.fromJsonOrNull(data['policy']);
  }

  /// «مواصفات لكل رقم غرفة»: the feature vocabulary with what THIS numbered room carries ticked.
  Future<({double? base, List<UnitFeature> features})> roomFeatures(int itemId, int roomId) async {
    final data = await _client.get('/business/bookable-items/$itemId/rooms/$roomId/features') as Map<String, dynamic>;
    return (base: (data['base_price'] as num?)?.toDouble(), features: parseUnitFeatures(data));
  }

  Future<List<UnitFeature>> saveRoomFeatures(int itemId, int roomId, List<int> optionIds) async {
    final data = await _client.put('/business/bookable-items/$itemId/rooms/$roomId/features', data: {'option_ids': optionIds}) as Map<String, dynamic>;
    return parseUnitFeatures(data);
  }

  /// «شروط الحجز» — GET /business/booking-terms.
  Future<BookingTerms> bookingTerms() async {
    final data = await _client.get('/business/booking-terms') as Map<String, dynamic>;
    return BookingTerms.fromJson(data);
  }

  Future<BookingTerms> saveBookingTerms(BookingTerms terms) async {
    final data = await _client.put('/business/booking-terms', data: terms.toJson()) as Map<String, dynamic>;
    return BookingTerms.fromJson(data);
  }

  Future<CheckTimes> checkTimes() async {
    final data =
        await _client.get('/business/booking-settings/check-times') as Map<String, dynamic>;
    return CheckTimes.fromJson(data);
  }

  Future<CheckTimes> updateCheckTimes({String? checkInTime, String? checkOutTime}) async {
    final data = await _client.put(
      '/business/booking-settings/check-times',
      data: {'check_in_time': ?checkInTime, 'check_out_time': ?checkOutTime},
    );
    return CheckTimes.fromJson(data as Map<String, dynamic>);
  }

  /// «يجب التواجد قبل الموعد بـ ١٥ دقيقة» — the business's own notice on its bookings.
  Future<({int? minutes, String? text, String? message})> arrivalNotice() async {
    final data = await _client.get('/business/booking-settings/arrival-notice') as Map<String, dynamic>;

    return (minutes: (data['minutes'] as num?)?.toInt(), text: data['text'] as String?, message: data['message'] as String?);
  }

  Future<({int? minutes, String? text, String? message})> saveArrivalNotice({required int minutes, required String text}) async {
    final data =
        await _client.put('/business/booking-settings/arrival-notice', data: {'minutes': minutes, 'text': text})
            as Map<String, dynamic>;

    return (minutes: (data['minutes'] as num?)?.toInt(), text: data['text'] as String?, message: data['message'] as String?);
  }

  /// «بالموعد أم بالدور»: how the business takes its appointments — `slots` or `queue`.
  Future<String> bookingFlow() async {
    final data = await _client.get('/business/booking-settings/flow') as Map<String, dynamic>;

    return data['flow'] as String? ?? 'slots';
  }

  Future<String> saveBookingFlow(String flow) async {
    final data = await _client.put('/business/booking-settings/flow', data: {'flow': flow}) as Map<String, dynamic>;

    return data['flow'] as String? ?? 'slots';
  }

  Future<WorkingHours> hours() async {
    final data =
        await _client.get('/business/working-hours') as Map<String, dynamic>;
    return WorkingHours.fromJson(data);
  }

  Future<WorkingHours> updateHours(List<WorkingDay> days) async {
    final data = await _client.put(
      '/business/working-hours',
      data: {
        'days': days
            .map(
              (d) => {
                'day': d.day,
                if (d.isClosed != null) 'is_closed': d.isClosed,
                if (d.is24h) 'is_24h': true,
                if (d.open != null) 'open': d.open,
                if (d.close != null) 'close': d.close,
              },
            )
            .toList(),
      },
    );
    return WorkingHours.fromJson(data as Map<String, dynamic>);
  }
}
