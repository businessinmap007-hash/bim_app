import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/business_page_api.dart';
import '../data/models/business_post.dart';
import '../data/models/business_profile.dart';
import '../data/models/menu_section_group.dart';
import '../data/models/offering_item.dart';

final businessPageApiProvider = Provider<BusinessPageApi>((ref) {
  return BusinessPageApi(ref.watch(apiClientProvider));
});

final businessProfileProvider = FutureProvider.family<BusinessProfile, int>((ref, businessId) {
  return ref.watch(businessPageApiProvider).profile(businessId);
});

final businessMenuProvider = FutureProvider.family<List<MenuSectionGroup>, int>((ref, businessId) {
  return ref.watch(businessPageApiProvider).menu(businessId);
});

final businessOfferingsProvider = FutureProvider.family<List<OfferingItem>, int>((ref, businessId) {
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
