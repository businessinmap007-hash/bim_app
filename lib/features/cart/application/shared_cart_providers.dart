import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/shared_cart.dart';
import '../data/shared_cart_api.dart';

final sharedCartApiProvider = Provider<SharedCartApi>((ref) {
  return SharedCartApi(ref.watch(apiClientProvider));
});

class SharedCartState {
  final SharedCart? cart;
  final bool isLoading;
  final String? error;

  const SharedCartState({this.cart, this.isLoading = false, this.error});

  SharedCartState copyWith({SharedCart? cart, bool? isLoading, String? error, bool clearError = false}) {
    return SharedCartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// One controller per shared-cart order id — every mutation swaps in the
/// server's fresh copy (fees/attribution are computed server-side), same
/// discipline as the solo CartController.
class SharedCartController extends StateNotifier<SharedCartState> {
  final SharedCartApi _api;
  final int orderId;

  SharedCartController(this._api, this.orderId) : super(const SharedCartState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cart = await _api.show(orderId);
      state = state.copyWith(cart: cart, isLoading: false);
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
    final cart = await _api.addItem(
      orderId: orderId,
      kind: kind,
      offeringId: offeringId,
      qty: qty,
      sizeId: sizeId,
      extras: extras,
    );
    state = state.copyWith(cart: cart);
  }

  Future<void> updateItemQty(int itemId, int qty) async {
    final cart = await _api.updateItemQty(orderId, itemId, qty);
    state = state.copyWith(cart: cart);
  }

  Future<void> removeItem(int itemId) async {
    final cart = await _api.removeItem(orderId, itemId);
    state = state.copyWith(cart: cart);
  }

  Future<SharedCart> checkout({String? fulfillmentType, String? address, String? notes}) {
    return _api.checkout(orderId, fulfillmentType: fulfillmentType, address: address, notes: notes);
  }

  /// Host-only: invites a friend by phone or email. Returns their name on
  /// success; throws ApiException (with a field error on 'identifier') if
  /// they're not found, are already a participant self-invite, etc.
  Future<String> invite(String identifier) => _api.invite(orderId, identifier);

  /// Host-only: invites a contact group — every member, or only [memberIds]
  /// when the caller picked a subset. Returns the names genuinely newly
  /// notified (may be fewer than the selection itself).
  Future<List<String>> inviteGroup(int groupId, {List<int>? memberIds}) =>
      _api.inviteGroup(orderId, groupId, memberIds: memberIds);

  Future<void> leave() => _api.leave(orderId);

  Future<void> cancel() => _api.cancel(orderId);
}

final sharedCartControllerProvider =
    StateNotifierProvider.family<SharedCartController, SharedCartState, int>((ref, orderId) {
      return SharedCartController(ref.watch(sharedCartApiProvider), orderId);
    });
