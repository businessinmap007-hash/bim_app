import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/booking_api.dart';
import '../data/models/booking.dart';
import '../data/models/booking_financial_preview.dart';
import '../data/models/booking_form.dart';
import '../data/models/unit_discovery.dart';

final bookingApiProvider = Provider<BookingApi>((ref) {
  return BookingApi(ref.watch(apiClientProvider));
});

final bookingFinancialPreviewProvider = FutureProvider.autoDispose.family<BookingFinancialPreview, int>((ref, bookingId) {
  return ref.watch(bookingApiProvider).financialPreview(bookingId);
});

final bookingFormProvider = FutureProvider.family<BookingFormPayload, int>((ref, businessId) {
  return ref.watch(bookingApiProvider).form(businessId);
});

typedef UnitDiscoveryParams = ({int businessId, int? serviceId, String? itemType, DateTime? startsAt, DateTime? endsAt});

final unitDiscoveryProvider = FutureProvider.autoDispose.family<List<UnitKindGroup>, UnitDiscoveryParams>((
  ref,
  params,
) {
  return ref.watch(bookingApiProvider).discoverUnits(
    businessId: params.businessId,
    serviceId: params.serviceId,
    itemType: params.itemType,
    startsAt: params.startsAt,
    endsAt: params.endsAt,
  );
});

/// The units a business sells and the booking shape its page is drawn in (no dates — «what exists and what it costs»).
final unitCatalogProvider = FutureProvider.autoDispose.family<UnitCatalog, int>((ref, businessId) {
  return ref.watch(bookingApiProvider).unitCatalog(businessId);
});

class MyBookingsState {
  final List<Booking> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyBookingsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MyBookingsState copyWith({
    List<Booking>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MyBookingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyBookingsController extends StateNotifier<MyBookingsState> {
  final BookingApi _api;
  int _page = 1;

  MyBookingsController(this._api) : super(const MyBookingsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.list(page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(page: _page + 1);
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

  Future<void> cancel(int id) async {
    final updated = await _api.cancel(id);
    state = state.copyWith(items: [for (final b in state.items) b.id == id ? updated : b]);
  }

  Future<void> confirm(int id, {String? pin}) async {
    final updated = await _api.clientConfirm(id, pin: pin);
    state = state.copyWith(items: [for (final b in state.items) b.id == id ? updated : b]);
  }

  Future<Booking> confirmPayment(int id) async {
    final updated = await _api.confirmPayment(id);
    state = state.copyWith(items: [for (final b in state.items) b.id == id ? updated : b]);
    return updated;
  }

  Future<void> agreeReleaseDeposit(int id) async {
    final updated = await _api.agreeReleaseDeposit(id);
    state = state.copyWith(items: [for (final b in state.items) b.id == id ? updated : b]);
  }

  Future<void> requestDepositAsPayment(int id) async {
    final updated = await _api.requestDepositAsPayment(id);
    state = state.copyWith(items: [for (final b in state.items) b.id == id ? updated : b]);
  }

  Future<void> agreeRefundDeposit(int id) async {
    final updated = await _api.agreeRefundDeposit(id);
    state = state.copyWith(items: [for (final b in state.items) b.id == id ? updated : b]);
  }
}

final myBookingsControllerProvider =
    StateNotifierProvider<MyBookingsController, MyBookingsState>((ref) {
      return MyBookingsController(ref.watch(bookingApiProvider));
    });

typedef DayGridParams = ({
  int businessId,
  String date,
  int durationMinutes,
  int stepMinutes,
  int? partySize,
  int? serviceId,
  String? itemType,
});

/// One day of a venue or a restaurant as start times with their free counts (the date is `yyyy-MM-dd` so equal
/// requests share one answer).
final dayGridProvider = FutureProvider.autoDispose.family<DayGrid, DayGridParams>((ref, p) {
  return ref.watch(bookingApiProvider).dayGrid(
    businessId: p.businessId,
    date: DateTime.parse(p.date),
    durationMinutes: p.durationMinutes,
    stepMinutes: p.stepMinutes,
    partySize: p.partySize,
    serviceId: p.serviceId,
    itemType: p.itemType,
  );
});
