import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/business_page_api.dart';
import '../data/models/business_post.dart';
import '../data/models/business_profile.dart';
import '../data/models/offering_item.dart';

final businessPageApiProvider = Provider<BusinessPageApi>((ref) {
  return BusinessPageApi(ref.watch(apiClientProvider));
});

/// The customer's chosen fulfillment method for this business visit —
/// 'delivery' / 'pickup' / 'dine_in', or null before they've picked one.
/// Session-only (not persisted): picked once above the menu via
/// FulfillmentSelectorBar, read by CheckoutScreen so it isn't asked again.
final businessFulfillmentChoiceProvider = StateProvider.family<String?, int>((ref, businessId) => null);

final businessProfileProvider =
    StateNotifierProvider.family<BusinessProfileController, AsyncValue<BusinessProfile>, int>((ref, businessId) {
      ref.watch(localeEpochProvider);
      return BusinessProfileController(ref.watch(businessPageApiProvider), businessId);
    });

/// The profile aggregate plus a follow toggle that updates in place —
/// re-fetching the whole page just to flip one boolean would flash the
/// header, and the count the button shows should move the instant it's
/// tapped, not after a round trip.
class BusinessProfileController extends StateNotifier<AsyncValue<BusinessProfile>> {
  final BusinessPageApi _api;
  final int businessId;

  BusinessProfileController(this._api, this.businessId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.profile(businessId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> toggleFollow() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final nextFollowing = !current.isFollowing;
    state = AsyncValue.data(
      current.copyWith(
        isFollowing: nextFollowing,
        followersCount: current.followersCount + (nextFollowing ? 1 : -1),
      ),
    );

    try {
      if (nextFollowing) {
        await _api.follow(businessId);
      } else {
        await _api.unfollow(businessId);
      }
    } catch (e) {
      // Roll back on failure — the optimistic flip didn't actually happen.
      state = AsyncValue.data(current);
      rethrow;
    }
  }
}

final businessMenuProvider = FutureProvider.family<MenuPageData, int>((ref, businessId) {
  ref.watch(localeEpochProvider);
  return ref.watch(businessPageApiProvider).menu(businessId);
});

final businessOfferingsProvider = FutureProvider.family<List<OfferingItem>, int>((ref, businessId) {
  ref.watch(localeEpochProvider);
  return ref.watch(businessPageApiProvider).offerings(businessId);
});

class BusinessPostsState {
  final List<BusinessPost> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const BusinessPostsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  BusinessPostsState copyWith({
    List<BusinessPost>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return BusinessPostsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Mirrors [BusinessListController]'s load/loadMore shape, against the
/// per-business posts wall instead of the discovery list.
class BusinessPostsController extends StateNotifier<BusinessPostsState> {
  final BusinessPageApi _api;
  final int businessId;
  int _page = 1;

  BusinessPostsController(this._api, this.businessId) : super(const BusinessPostsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.posts(businessId, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.posts(businessId, page: _page + 1);
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

final businessPostsControllerProvider =
    StateNotifierProvider.family<BusinessPostsController, BusinessPostsState, int>((ref, businessId) {
      return BusinessPostsController(ref.watch(businessPageApiProvider), businessId);
    });
