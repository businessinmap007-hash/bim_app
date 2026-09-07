import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/menu_bundle_api.dart';
import '../data/models/menu_bundle.dart';

final menuBundleApiProvider = Provider<MenuBundleApi>((ref) {
  return MenuBundleApi(ref.watch(apiClientProvider));
});

class MenuBundlesState {
  final List<MenuBundle> items;
  final bool isLoading;
  final String? error;

  const MenuBundlesState({this.items = const [], this.isLoading = false, this.error});

  MenuBundlesState copyWith({List<MenuBundle>? items, bool? isLoading, String? error, bool clearError = false}) {
    return MenuBundlesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MenuBundlesController extends StateNotifier<MenuBundlesState> {
  final MenuBundleApi _api;

  MenuBundlesController(this._api) : super(const MenuBundlesState()) {
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

  Future<void> create({
    required String nameAr,
    String? nameEn,
    required String pricingMode,
    double? fixedPrice,
    double? discountValue,
    required List<MapEntry<int, int>> items,
    bool isActive = true,
  }) async {
    await _api.create(
      nameAr: nameAr,
      nameEn: nameEn,
      pricingMode: pricingMode,
      fixedPrice: fixedPrice,
      discountValue: discountValue,
      items: items,
      isActive: isActive,
    );
    await load();
  }

  Future<void> update(
    int id, {
    required String nameAr,
    String? nameEn,
    required String pricingMode,
    double? fixedPrice,
    double? discountValue,
    required List<MapEntry<int, int>> items,
    bool isActive = true,
  }) async {
    await _api.update(
      id,
      nameAr: nameAr,
      nameEn: nameEn,
      pricingMode: pricingMode,
      fixedPrice: fixedPrice,
      discountValue: discountValue,
      items: items,
      isActive: isActive,
    );
    await load();
  }

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((b) => b.id != id).toList());
    try {
      await _api.delete(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    }
  }
}

final menuBundlesControllerProvider = StateNotifierProvider<MenuBundlesController, MenuBundlesState>((ref) {
  return MenuBundlesController(ref.watch(menuBundleApiProvider));
});
