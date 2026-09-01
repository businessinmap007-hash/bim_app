import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
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
  }

  /// Replaces the signed-in user's data in place — called after a profile
  /// edit (name/phone/location/photo) so the rest of the app (app bars,
  /// business home header, ...) reflects the change without a full re-fetch.
  void setUser(AuthUser user) {
    if (state is AuthSignedIn) {
      state = AuthSignedIn(user);
    }
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
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.watch(authApiProvider), ref);
  },
);
