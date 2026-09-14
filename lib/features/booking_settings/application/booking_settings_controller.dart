import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/booking_settings_api.dart';
import '../data/models/booking_settings_models.dart';

final bookingSettingsApiProvider = Provider<BookingSettingsApi>((ref) {
  return BookingSettingsApi(ref.watch(apiClientProvider));
});

class BookingSettingsState {
  final PricesOptionsPayload? pricesOptions;
  final List<PriceRow> prices;
  final BookableItemsOptionsPayload? itemsOptions;
  final List<BookableItemRow> items;
  final WorkingHours? hours;
  final CheckTimes? checkTimes;
  final bool isLoading;
  final String? error;

  const BookingSettingsState({
    this.pricesOptions,
    this.prices = const [],
    this.itemsOptions,
    this.items = const [],
    this.hours,
    this.checkTimes,
    this.isLoading = false,
    this.error,
  });

  BookingSettingsState copyWith({
    PricesOptionsPayload? pricesOptions,
    List<PriceRow>? prices,
    BookableItemsOptionsPayload? itemsOptions,
    List<BookableItemRow>? items,
    WorkingHours? hours,
    CheckTimes? checkTimes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BookingSettingsState(
      pricesOptions: pricesOptions ?? this.pricesOptions,
      prices: prices ?? this.prices,
      itemsOptions: itemsOptions ?? this.itemsOptions,
      items: items ?? this.items,
      hours: hours ?? this.hours,
      checkTimes: checkTimes ?? this.checkTimes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// A business's own booking configuration — prices (what a room type
/// costs), bookable units (which specific rooms exist) and weekly hours.
/// Loads everything once so the three-tab screen has no per-tab spinner
/// flicker when switching.
class BookingSettingsController extends StateNotifier<BookingSettingsState> {
  final BookingSettingsApi _api;

  BookingSettingsController(this._api) : super(const BookingSettingsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _api.pricesOptions(),
        _api.prices(),
        _api.bookableItemsOptions(),
        _api.bookableItems(),
        _api.hours(),
        _api.checkTimes(),
      ]);
      state = state.copyWith(
        pricesOptions: results[0] as PricesOptionsPayload,
        prices: results[1] as List<PriceRow>,
        itemsOptions: results[2] as BookableItemsOptionsPayload,
        items: results[3] as List<BookableItemRow>,
        hours: results[4] as WorkingHours,
        checkTimes: results[5] as CheckTimes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPrice({
    required int serviceId,
    required String bookableItemType,
    required double price,
    int? lineOptionId,
    String chargeMode = 'standard',
  }) async {
    final row = await _api.createPrice(
      serviceId: serviceId,
      bookableItemType: bookableItemType,
      price: price,
      lineOptionId: lineOptionId,
      chargeMode: chargeMode,
    );
    state = state.copyWith(prices: [row, ...state.prices]);
  }

  Future<void> deletePrice(int id) async {
    await _api.deletePrice(id);
    state = state.copyWith(prices: state.prices.where((p) => p.id != id).toList());
  }

  Future<void> createBookableItem({
    required int serviceId,
    required String itemType,
    required String code,
    int? lineOptionId,
    int? capacity,
  }) async {
    final row = await _api.createBookableItem(
      serviceId: serviceId,
      itemType: itemType,
      code: code,
      lineOptionId: lineOptionId,
      capacity: capacity,
    );
    state = state.copyWith(items: [row, ...state.items]);
  }

  Future<void> updateBookableItem(
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
    final row = await _api.updateBookableItem(
      id,
      serviceId: serviceId,
      itemType: itemType,
      code: code,
      lineOptionId: lineOptionId,
      description: description,
      capacity: capacity,
      quantity: quantity,
      status: status,
    );
    state = state.copyWith(items: [for (final i in state.items) i.id == id ? row : i]);
  }

  Future<void> deleteBookableItem(int id) async {
    await _api.deleteBookableItem(id);
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
  }

  Future<void> addBookableItemImage(int itemId, String filePath) async {
    await _api.addBookableItemImage(itemId, filePath);
    await _refreshOneItem(itemId);
  }

  Future<void> deleteBookableItemImage(int itemId, int imageId) async {
    await _api.deleteBookableItemImage(itemId, imageId);
    await _refreshOneItem(itemId);
  }

  /// The images/upload doors return no full resource body — re-fetch this
  /// one item so its gallery reflects what the server now holds.
  Future<void> _refreshOneItem(int itemId) async {
    final all = await _api.bookableItems();
    final matches = all.where((i) => i.id == itemId);
    if (matches.isEmpty) return;
    final fresh = matches.first;
    state = state.copyWith(items: [for (final i in state.items) i.id == itemId ? fresh : i]);
  }

  Future<void> saveCheckTimes({String? checkInTime, String? checkOutTime}) async {
    final updated = await _api.updateCheckTimes(checkInTime: checkInTime, checkOutTime: checkOutTime);
    state = state.copyWith(checkTimes: updated);
  }

  Future<void> saveHours(List<WorkingDay> days) async {
    final updated = await _api.updateHours(days);
    state = state.copyWith(hours: updated);
  }
}

final bookingSettingsControllerProvider =
    StateNotifierProvider<BookingSettingsController, BookingSettingsState>((ref) {
      return BookingSettingsController(ref.watch(bookingSettingsApiProvider));
    });
