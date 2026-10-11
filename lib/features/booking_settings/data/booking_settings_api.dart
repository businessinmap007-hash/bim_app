import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/booking_settings_models.dart';
import 'models/booking_terms.dart';
import 'models/add_on_models.dart';
import 'models/room_models.dart';

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
