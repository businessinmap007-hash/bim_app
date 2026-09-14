import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/booking_api.dart';
import '../data/models/booking.dart';
import 'booking_providers.dart';

class BusinessBookingsState {
  final List<Booking> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const BusinessBookingsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  BusinessBookingsState copyWith({
    List<Booking>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return BusinessBookingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// A business's own incoming-booking queue — Api\V2\BookingController's
/// scope=business, mirrors BusinessOrdersController's own shape.
class BusinessBookingsController extends StateNotifier<BusinessBookingsState> {
  final BookingApi _api;
  int _page = 1;
  String? _status;

  BusinessBookingsController(this._api) : super(const BusinessBookingsState()) {
    load();
  }

  Future<void> load({String? status}) async {
    _status = status;
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.listBusiness(status: _status, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.listBusiness(status: _status, page: _page + 1);
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...result.items],
        isLoadingMore: false,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final businessBookingsControllerProvider =
    StateNotifierProvider<BusinessBookingsController, BusinessBookingsState>((ref) {
      return BusinessBookingsController(ref.watch(bookingApiProvider));
    });

class BusinessBookingDetailState {
  final Booking? booking;
  final bool isLoading;
  final bool isBusy;
  final String? error;

  const BusinessBookingDetailState({this.booking, this.isLoading = false, this.isBusy = false, this.error});

  BusinessBookingDetailState copyWith({
    Booking? booking,
    bool? isLoading,
    bool? isBusy,
    String? error,
    bool clearError = false,
  }) {
    return BusinessBookingDetailState(
      booking: booking ?? this.booking,
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BusinessBookingDetailController extends StateNotifier<BusinessBookingDetailState> {
  final BookingApi _api;
  final int bookingId;

  BusinessBookingDetailController(this._api, this.bookingId) : super(const BusinessBookingDetailState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final booking = await _api.show(bookingId);
      state = state.copyWith(booking: booking, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> accept() async {
    state = state.copyWith(isBusy: true);
    try {
      final booking = await _api.accept(bookingId);
      state = state.copyWith(booking: booking, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> reject() async {
    state = state.copyWith(isBusy: true);
    try {
      final booking = await _api.reject(bookingId);
      state = state.copyWith(booking: booking, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> businessConfirm() async {
    state = state.copyWith(isBusy: true);
    try {
      final booking = await _api.businessConfirm(bookingId);
      state = state.copyWith(booking: booking, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> start() async {
    state = state.copyWith(isBusy: true);
    try {
      final booking = await _api.start(bookingId);
      state = state.copyWith(booking: booking, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<void> complete() async {
    state = state.copyWith(isBusy: true);
    try {
      final booking = await _api.complete(bookingId);
      state = state.copyWith(booking: booking, isBusy: false);
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }
}

final businessBookingDetailControllerProvider =
    StateNotifierProvider.family<BusinessBookingDetailController, BusinessBookingDetailState, int>((ref, bookingId) {
      return BusinessBookingDetailController(ref.watch(bookingApiProvider), bookingId);
    });
