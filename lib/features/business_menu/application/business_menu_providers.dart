import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/business_menu_api.dart';
import '../data/models/menu_available_types.dart';
import '../data/models/menu_item.dart';
import '../data/models/menu_section.dart';
import '../data/models/menu_vocabulary.dart';

final businessMenuApiProvider = Provider<BusinessMenuApi>((ref) {
  return BusinessMenuApi(ref.watch(apiClientProvider));
});

/// The shared catalog_units vocabulary — small and effectively static per
/// session, so one fetch per app run is enough.
final saleUnitOptionsProvider = FutureProvider<List<SaleUnitOption>>((ref) {
  return ref.watch(businessMenuApiProvider).saleUnits();
});

/// What THIS business may say a catalog item is/what qualifies it — narrowed
/// server-side to its own specialty, so one fetch per app run is enough.
final menuVocabularyProvider = FutureProvider<MenuVocabulary>((ref) {
  return ref.watch(businessMenuApiProvider).vocabulary();
});

/// The FULL `line` catalog (not narrowed by ticks) — autoDispose so the
/// "which types do you carry" screen always sees a fresh selection state
/// instead of a stale one from a previous visit.
final menuAvailableTypesProvider = FutureProvider.autoDispose<List<AvailableTypeGroup>>((ref) {
  return ref.watch(businessMenuApiProvider).availableTypes();
});

/// 'list' or 'grid' — this business's own choice for how customers see the
/// menu. A StateNotifier (not a plain FutureProvider) since the settings
/// screen changes it in place and every reader should see that change
/// immediately, without waiting for a refetch.
class MenuDisplayModeController extends StateNotifier<AsyncValue<String>> {
  final BusinessMenuApi _api;
  MenuDisplayModeController(this._api) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = AsyncValue.data(await _api.displayMode());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setMode(String mode) async {
    final previous = state;
    state = AsyncValue.data(mode);
    try {
      await _api.setDisplayMode(mode);
    } catch (e, st) {
      state = previous;
      state = AsyncValue.error(e, st);
    }
  }
}

final menuDisplayModeControllerProvider =
    StateNotifierProvider<MenuDisplayModeController, AsyncValue<String>>((ref) {
      return MenuDisplayModeController(ref.watch(businessMenuApiProvider));
    });

// ─────────────────────────── Sections ───────────────────────────

class MenuSectionsState {
  final List<BusinessMenuSection> items;
  final bool isLoading;
  final String? error;

  const MenuSectionsState({this.items = const [], this.isLoading = false, this.error});

  MenuSectionsState copyWith({List<BusinessMenuSection>? items, bool? isLoading, String? error, bool clearError = false}) {
    return MenuSectionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MenuSectionsController extends StateNotifier<MenuSectionsState> {
  final BusinessMenuApi _api;

  MenuSectionsController(this._api) : super(const MenuSectionsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.sections();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create({required String nameAr, String? nameEn, int sortOrder = 0, bool isActive = true}) async {
    await _api.createSection(nameAr: nameAr, nameEn: nameEn, sortOrder: sortOrder, isActive: isActive);
    await load();
  }

  Future<void> update(int id, {required String nameAr, String? nameEn, int sortOrder = 0, bool isActive = true}) async {
    await _api.updateSection(id, nameAr: nameAr, nameEn: nameEn, sortOrder: sortOrder, isActive: isActive);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.deleteSection(id);
    await load();
  }
}

final menuSectionsControllerProvider = StateNotifierProvider<MenuSectionsController, MenuSectionsState>((ref) {
  return MenuSectionsController(ref.watch(businessMenuApiProvider));
});

// ─────────────────────────── Items list ───────────────────────────

class MenuItemsState {
  final List<BusinessMenuItem> items;
  final String query;
  final int? sectionId;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MenuItemsState({
    this.items = const [],
    this.query = '',
    this.sectionId,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  MenuItemsState copyWith({
    List<BusinessMenuItem>? items,
    String? query,
    int? sectionId,
    bool clearSectionId = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MenuItemsState(
      items: items ?? this.items,
      query: query ?? this.query,
      sectionId: clearSectionId ? null : (sectionId ?? this.sectionId),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MenuItemsController extends StateNotifier<MenuItemsState> {
  final BusinessMenuApi _api;
  int _page = 1;

  MenuItemsController(this._api) : super(const MenuItemsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _page = 1;
    try {
      final result = await _api.items(q: state.query, sectionId: state.sectionId, page: _page);
      state = state.copyWith(items: result.items, isLoading: false, hasMore: result.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.items(q: state.query, sectionId: state.sectionId, page: _page + 1);
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

  Future<void> setQuery(String q) async {
    state = state.copyWith(query: q);
    await load();
  }

  Future<void> filterBySection(int? sectionId) async {
    state = sectionId == null ? state.copyWith(clearSectionId: true) : state.copyWith(sectionId: sectionId);
    await load();
  }

  Future<void> delete(int id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((i) => i.id != id).toList());
    try {
      await _api.deleteItem(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
      rethrow;
    }
  }
}

final menuItemsControllerProvider = StateNotifierProvider<MenuItemsController, MenuItemsState>((ref) {
  return MenuItemsController(ref.watch(businessMenuApiProvider));
});

// ─────────────────────────── One item's edit state ───────────────────────────

/// The full item (with images/variants/extras) plus every mutation that
/// screen offers — each sub-resource action (image/variant/extra) reloads
/// the whole item afterward rather than patching state locally, since the
/// backend recomputes derived bits (e.g. is_default exclusivity) server-side.
class MenuItemEditController extends StateNotifier<AsyncValue<BusinessMenuItem>> {
  final BusinessMenuApi _api;
  final int itemId;

  MenuItemEditController(this._api, this.itemId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.item(itemId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addImage(String filePath) async {
    await _api.addImage(itemId, filePath);
    await load();
  }

  Future<void> deleteImage(int imageId) async {
    await _api.deleteImage(itemId, imageId);
    await load();
  }

  Future<void> addVariant({
    required String type,
    required String nameAr,
    String? nameEn,
    double? price,
    double? priceDelta,
    bool isDefault = false,
    bool isActive = true,
  }) async {
    await _api.addVariant(
      itemId,
      type: type,
      nameAr: nameAr,
      nameEn: nameEn,
      price: price,
      priceDelta: priceDelta,
      isDefault: isDefault,
      isActive: isActive,
    );
    await load();
  }

  Future<void> updateVariant(
    int variantId, {
    required String type,
    required String nameAr,
    String? nameEn,
    double? price,
    double? priceDelta,
    bool isDefault = false,
    bool isActive = true,
  }) async {
    await _api.updateVariant(
      itemId,
      variantId,
      type: type,
      nameAr: nameAr,
      nameEn: nameEn,
      price: price,
      priceDelta: priceDelta,
      isDefault: isDefault,
      isActive: isActive,
    );
    await load();
  }

  Future<void> deleteVariant(int variantId) async {
    await _api.deleteVariant(itemId, variantId);
    await load();
  }

  Future<void> addExtra({
    int? extraGroupId,
    required String nameAr,
    String? nameEn,
    required double price,
    int maxQty = 1,
    bool isActive = true,
  }) async {
    await _api.addExtra(itemId, extraGroupId: extraGroupId, nameAr: nameAr, nameEn: nameEn, price: price, maxQty: maxQty, isActive: isActive);
    await load();
  }

  Future<void> updateExtra(
    int extraId, {
    int? extraGroupId,
    required String nameAr,
    String? nameEn,
    required double price,
    int maxQty = 1,
    bool isActive = true,
  }) async {
    await _api.updateExtra(itemId, extraId, extraGroupId: extraGroupId, nameAr: nameAr, nameEn: nameEn, price: price, maxQty: maxQty, isActive: isActive);
    await load();
  }

  Future<void> deleteExtra(int extraId) async {
    await _api.deleteExtra(itemId, extraId);
    await load();
  }

  Future<void> addExtraGroup({
    required String nameAr,
    String? nameEn,
    required String selectionType,
    bool isActive = true,
  }) async {
    await _api.addExtraGroup(itemId, nameAr: nameAr, nameEn: nameEn, selectionType: selectionType, isActive: isActive);
    await load();
  }

  Future<void> updateExtraGroup(
    int groupId, {
    required String nameAr,
    String? nameEn,
    required String selectionType,
    bool isActive = true,
  }) async {
    await _api.updateExtraGroup(itemId, groupId, nameAr: nameAr, nameEn: nameEn, selectionType: selectionType, isActive: isActive);
    await load();
  }

  Future<void> deleteExtraGroup(int groupId) async {
    await _api.deleteExtraGroup(itemId, groupId);
    await load();
  }
}

final menuItemEditControllerProvider =
    StateNotifierProvider.family<MenuItemEditController, AsyncValue<BusinessMenuItem>, int>((ref, itemId) {
      return MenuItemEditController(ref.watch(businessMenuApiProvider), itemId);
    });
