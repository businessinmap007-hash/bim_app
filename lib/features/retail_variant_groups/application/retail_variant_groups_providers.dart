import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/retail_variant_group.dart';
import '../data/retail_variant_groups_api.dart';

final retailVariantGroupsApiProvider = Provider<RetailVariantGroupsApi>((ref) {
  return RetailVariantGroupsApi(ref.watch(apiClientProvider));
});

class RetailVariantGroupsState {
  final List<RetailVariantGroup> items;
  final bool isLoading;
  final String? error;

  const RetailVariantGroupsState({this.items = const [], this.isLoading = false, this.error});

  RetailVariantGroupsState copyWith({List<RetailVariantGroup>? items, bool? isLoading, String? error, bool clearError = false}) {
    return RetailVariantGroupsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RetailVariantGroupsController extends StateNotifier<RetailVariantGroupsState> {
  final RetailVariantGroupsApi _api;

  RetailVariantGroupsController(this._api) : super(const RetailVariantGroupsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.list();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final retailVariantGroupsControllerProvider =
    StateNotifierProvider<RetailVariantGroupsController, RetailVariantGroupsState>((ref) {
      return RetailVariantGroupsController(ref.watch(retailVariantGroupsApiProvider));
    });
