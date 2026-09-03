import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../addresses/application/addresses_providers.dart';
import '../../business_menu/application/business_menu_providers.dart';
import '../../business_offers/application/business_offers_providers.dart';
import '../../business_prices/application/business_prices_providers.dart';
import '../../cart/application/cart_controller.dart';
import '../../clinic_management/application/business_clinic_providers.dart';
import '../../deposits/application/deposits_providers.dart';
import '../../disputes/application/disputes_providers.dart';
import '../../fines/application/fines_providers.dart';
import '../../general_chat/application/general_chat_providers.dart';
import '../../jobs/application/jobs_providers.dart';
import '../../offers/application/offers_providers.dart';
import '../../orders/application/business_orders_providers.dart';
import '../../orders/application/orders_providers.dart';
import '../../posts/application/posts_controller.dart';
import '../../prescriptions/application/pharmacy_prescriptions_providers.dart';
import '../../projects/application/projects_providers.dart';
import '../../ratings/application/ratings_providers.dart';
import '../../retail_discovery/application/retail_discovery_providers.dart';
import '../../retail_listings/application/retail_listings_providers.dart';
import '../../schedules/application/schedules_providers.dart';
import '../../staff/application/staff_providers.dart';
import '../data/auth_api.dart';
import '../data/models/auth_user.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

/// Whole-app auth state: unknown while the stored token is being checked on
/// launch, then either signed out or holding the current [AuthUser].
sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

class AuthSignedIn extends AuthState {
  final AuthUser user;
  const AuthSignedIn(this.user);
}

class AuthController extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final Ref _ref;

  AuthController(this._authApi, this._ref) : super(const AuthUnknown()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await _ref.read(tokenStorageProvider).read();
      if (token == null || token.isEmpty) {
        state = const AuthSignedOut();
        return;
      }
      final user = await _authApi.me();
      state = AuthSignedIn(user);
    } catch (_) {
      // Covers both a stale/revoked token (me() 401s) and secure storage
      // being unavailable — either way, fall back to signed-out rather than
      // looping the app on something that will keep failing.
      try {
        await _ref.read(tokenStorageProvider).clear();
      } catch (_) {
        /* storage itself is the thing that failed */
      }
      state = const AuthSignedOut();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final result = await _authApi.login(email: email, password: password);
    await _ref.read(tokenStorageProvider).write(result.token);
    state = AuthSignedIn(result.user);
    _resetAccountScopedProviders();
  }

  Future<void> register({
    required String name,
    String? nameEn,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String type,
    int? categoryId,
    int? categoryChildId,
  }) async {
    final result = await _authApi.register(
      name: name,
      nameEn: nameEn,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      type: type,
      categoryId: categoryId,
      categoryChildId: categoryChildId,
    );
    await _ref.read(tokenStorageProvider).write(result.token);
    state = AuthSignedIn(result.user);
    _resetAccountScopedProviders();
  }

  /// Replaces the signed-in user's data in place — called after a profile
  /// edit (name/phone/location/photo) so the rest of the app (app bars,
  /// business home header, ...) reflects the change without a full re-fetch.
  void setUser(AuthUser user) {
    if (state is AuthSignedIn) {
      state = AuthSignedIn(user);
    }
  }

  /// Restore an account soft-deleted within its grace window. `cancel()`
  /// only returns a token (the account had none while deleted) — fetch the
  /// user separately, same as session restore on launch.
  Future<void> restoreDeletedAccount({required String email, required String password}) async {
    final token = await _authApi.cancelDeletion(email: email, password: password);
    await _ref.read(tokenStorageProvider).write(token);
    final user = await _authApi.me();
    state = AuthSignedIn(user);
    _resetAccountScopedProviders();
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // Best-effort server-side revoke — clear the local session regardless,
      // otherwise a network blip would trap the user signed in forever.
    }
    await _ref.read(tokenStorageProvider).clear();
    state = const AuthSignedOut();
    _resetAccountScopedProviders();
  }

  /// Every plain (non-autoDispose) provider that holds one account's own
  /// data — posts, orders, cart, and so on. None of these are `.family`ed
  /// by user id, so left alone they outlive a logout/login cycle: the next
  /// account to sign in would see whichever account loaded them first,
  /// confirmed as a real bug (a fresh login showed the PREVIOUS account's
  /// own posts). Invalidating forces each to reconstruct — and reload for
  /// whoever is actually signed in — on both logout and a fresh sign-in,
  /// belt-and-braces against whichever screen happened to still be
  /// watching one through the transition.
  void _resetAccountScopedProviders() {
    _ref.invalidate(addressesControllerProvider);
    _ref.invalidate(menuSectionsControllerProvider);
    _ref.invalidate(menuItemsControllerProvider);
    _ref.invalidate(businessOffersControllerProvider);
    _ref.invalidate(boostPurchasesControllerProvider);
    _ref.invalidate(businessPricesControllerProvider);
    _ref.invalidate(cartControllerProvider);
    _ref.invalidate(clinicSlotsControllerProvider);
    _ref.invalidate(depositsControllerProvider);
    _ref.invalidate(myDisputesControllerProvider);
    _ref.invalidate(finesControllerProvider);
    _ref.invalidate(chatsListControllerProvider);
    _ref.invalidate(jobsControllerProvider);
    _ref.invalidate(jobFollowsControllerProvider);
    _ref.invalidate(offersControllerProvider);
    _ref.invalidate(myOrdersControllerProvider);
    _ref.invalidate(businessOrdersControllerProvider);
    _ref.invalidate(myPostsControllerProvider);
    _ref.invalidate(followedFeedControllerProvider);
    _ref.invalidate(myJobsControllerProvider);
    _ref.invalidate(myFollowsControllerProvider);
    _ref.invalidate(pharmacyQueueControllerProvider);
    _ref.invalidate(projectsControllerProvider);
    _ref.invalidate(myRatingControllerProvider);
    _ref.invalidate(shopProductsControllerProvider);
    _ref.invalidate(retailListingsControllerProvider);
    _ref.invalidate(tripSearchControllerProvider);
    _ref.invalidate(staffControllerProvider);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.watch(authApiProvider), ref);
  },
);
