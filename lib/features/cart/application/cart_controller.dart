import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/cart_api.dart';
import '../data/models/cart_models.dart';

final cartApiProvider = Provider<CartApi>((ref) {
  return CartApi(ref.watch(apiClientProvider));
});

class CartState {
  final List<Cart> carts;
  final bool isLoading;
  final String? error;

  const CartState({this.carts = const [], this.isLoading = false, this.error});

  int get itemsCount => carts.fold(0, (sum, c) => sum + c.itemsCount);

  CartState copyWith({List<Cart>? carts, bool? isLoading, String? error, bool clearError = false}) {
    return CartState(
      carts: carts ?? this.carts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// One cart per business, kept in sync across every screen that can touch
/// it (menu tab, offerings tab, the cart screen itself) — each mutation
/// replaces state with the fresh server response rather than guessing the
/// new total locally, since fees/tax are computed server-side.
class CartController extends StateNotifier<CartState> {
  final CartApi _api;

  CartController(this._api) : super(const CartState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final carts = await _api.index();
      state = state.copyWith(carts: carts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem({
    required String kind,
    required int offeringId,
    int qty = 1,
    int? sizeId,
    List<int> extras = const [],
  }) async {
    final updated = await _api.addItem(kind: kind, offeringId: offeringId, qty: qty, sizeId: sizeId, extras: extras);
    _mergeCart(updated);
  }

  Future<void> updateItemQty(int itemId, int qty) async {
    final updated = await _api.updateItemQty(itemId, qty);
    _mergeCart(updated);
  }

  Future<void> removeItem(int itemId) async {
    final updated = await _api.removeItem(itemId);
    _mergeCart(updated);
  }

  Future<Cart> checkout(
    int businessId, {
    String? fulfillmentType,
    int? addressId,
    String? address,
    double? lat,
    double? lng,
    String? notes,
    String? paymentMethod,
    String? outOfStockPolicy,
    DateTime? pickupAt,
  }) async {
    final order = await _api.checkout(
      businessId,
      fulfillmentType: fulfillmentType,
      addressId: addressId,
      address: address,
      lat: lat,
      lng: lng,
      notes: notes,
      paymentMethod: paymentMethod,
      outOfStockPolicy: outOfStockPolicy,
      pickupAt: pickupAt,
    );
    // The business's cart is now a placed order — drop it from the open carts.
    state = state.copyWith(carts: state.carts.where((c) => c.business?.id != businessId).toList());
    return order;
  }

  /// Replaces the business's cart with the server's fresh copy, or drops it
  /// if the last item was just removed (an empty cart carries no `business`).
  void _mergeCart(Cart updated) {
    final businessId = updated.business?.id;
    final carts = [...state.carts];
    final index = businessId != null ? carts.indexWhere((c) => c.business?.id == businessId) : -1;

    if (updated.items.isEmpty) {
      if (index != -1) carts.removeAt(index);
    } else if (index != -1) {
      carts[index] = updated;
    } else {
      carts.add(updated);
    }
    state = state.copyWith(carts: carts);
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController(ref.watch(cartApiProvider));
});
