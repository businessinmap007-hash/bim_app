import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/market_catalog_api.dart';
import '../data/models/market_catalog_group.dart';

final marketCatalogApiProvider = Provider<MarketCatalogApi>((ref) {
  return MarketCatalogApi(ref.watch(apiClientProvider));
});

class MarketCatalogController extends StateNotifier<AsyncValue<MarketCatalog>> {
  final MarketCatalogApi _api;

  MarketCatalogController(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Saves a batch and merges the result back into the current groups
  /// locally (no full reload — a market can carry thousands of rows).
  Future<({int saved, int cleared})> saveGroup(
    int groupId,
    Map<int, ({int? quantity, double? supplyPrice, double? basePrice, String? saleUnit, String? brandName})> rows,
  ) async {
    final result = await _api.save(rows);

    final current = state.value;
    if (current == null) return result;

    final updatedGroups = current.groups.map((g) {
      if (g.groupId != groupId) return g;

      final updatedRows = g.rows.map((row) {
        if (!rows.containsKey(row.optionId)) return row;
        final edited = rows[row.optionId]!;
        final priced = edited.basePrice != null;

        return MarketCatalogRow(
          optionId: row.optionId,
          nameAr: row.nameAr,
          nameEn: row.nameEn,
          item: priced
              ? MarketCatalogItem(
                  id: row.item?.id ?? 0,
                  basePrice: edited.basePrice,
                  supplyPrice: edited.supplyPrice,
                  saleUnit: edited.saleUnit,
                  brandName: edited.brandName,
                  availableQuantity: edited.quantity,
                  isActive: true,
                )
              : null,
        );
      }).toList();

      return MarketCatalogGroup(
        groupId: g.groupId,
        nameAr: g.nameAr,
        nameEn: g.nameEn,
        rows: updatedRows,
        filled: updatedRows.where((r) => r.item != null).length,
        total: g.total,
      );
    }).toList();

    state = AsyncValue.data(current.copyWith(groups: updatedGroups));

    return result;
  }

  Future<void> updateLowStockThreshold(int? threshold) async {
    final saved = await _api.updateLowStockThreshold(threshold);

    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(lowStockThreshold: saved, clearLowStockThreshold: saved == null));
  }
}

final marketCatalogControllerProvider = StateNotifierProvider<MarketCatalogController, AsyncValue<MarketCatalog>>((ref) {
  return MarketCatalogController(ref.watch(marketCatalogApiProvider));
});
