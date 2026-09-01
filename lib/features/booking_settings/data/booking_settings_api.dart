import '../../../core/network/api_client.dart';
import 'models/booking_settings_models.dart';

/// /business/prices, /business/bookable-items, /business/working-hours —
/// business-only self-service (the `business` middleware gate on the
/// backend), always the caller's own account. See
/// Api\V2\BusinessServicePriceController / BusinessBookableItemController /
/// BusinessHoursController.
class BookingSettingsApi {
  final ApiClient _client;
  const BookingSettingsApi(this._client);

  Future<PricesOptionsPayload> pricesOptions() async {
    final data = await _client.get('/business/prices/options') as Map<String, dynamic>;
    return PricesOptionsPayload.fromJson(data);
  }

  Future<List<PriceRow>> prices() async {
    final data = await _client.get('/business/prices') as List<dynamic>;
    return data.map((e) => PriceRow.fromJson(e as Map<String, dynamic>)).toList();
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
        if (lineOptionId != null) 'line_option_id': lineOptionId,
        'charge_mode': chargeMode,
        if (chargeAmount != null) 'charge_amount': chargeAmount,
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
        if (lineOptionId != null) 'line_option_id': lineOptionId,
        'is_active': isActive,
        'charge_mode': chargeMode,
        if (chargeAmount != null) 'charge_amount': chargeAmount,
      },
    );
    return PriceRow.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePrice(int id) => _client.delete('/business/prices/$id');

  Future<BookableItemsOptionsPayload> bookableItemsOptions() async {
    final data = await _client.get('/business/bookable-items/options') as Map<String, dynamic>;
    return BookableItemsOptionsPayload.fromJson(data);
  }

  Future<List<BookableItemRow>> bookableItems() async {
    final data = await _client.get('/business/bookable-items') as List<dynamic>;
    return data.map((e) => BookableItemRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BookableItemRow> createBookableItem({
    required int serviceId,
    required String itemType,
    required String code,
    int? lineOptionId,
    int? capacity,
  }) async {
    final data = await _client.post(
      '/business/bookable-items',
      data: {
        'service_id': serviceId,
        'item_type': itemType,
        'code': code,
        if (lineOptionId != null) 'line_option_id': lineOptionId,
        if (capacity != null) 'capacity': capacity,
      },
    );
    return BookableItemRow.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteBookableItem(int id) => _client.delete('/business/bookable-items/$id');

  Future<WorkingHours> hours() async {
    final data = await _client.get('/business/working-hours') as Map<String, dynamic>;
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
