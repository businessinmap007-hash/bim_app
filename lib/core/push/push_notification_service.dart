import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../providers/core_providers.dart';

/// Wires the app up to Firebase Cloud Messaging. Every call here is written
/// to degrade to a silent no-op, because as of this writing there is no
/// Firebase project configured for this app at all -- no
/// `firebase_options.dart`, no `google-services.json` (Android), no
/// `GoogleService-Info.plist` (iOS). That absence was the actual root cause
/// behind "inconsistent push notification delivery": `user_push_tokens` had
/// zero rows ever recorded, so every server-side FCM send skipped with
/// `no_active_device_tokens` -- the backend pipeline (FirebasePushService,
/// NotificationChannelRule, the /admin/push-settings credentials page) was
/// always fully built and tested; only the client never registered a
/// device. In-app (polled) notifications kept working throughout, which is
/// why it read as "inconsistent" rather than "never worked at all".
///
/// To go live: run `flutterfire configure` against a real Firebase project
/// (generates `firebase_options.dart` plus the native config files this
/// service currently has none of), then paste that project's service-account
/// JSON into AdminV2's Push Settings screen. Nothing else needs to change --
/// `init()` already runs at app startup and `registerCurrentToken()` already
/// runs on sign-in; both are just no-ops until those files exist.
class PushNotificationService {
  final ApiClient _client;
  bool _initialized = false;

  PushNotificationService(this._client);

  /// Safe to call unconditionally at app startup, signed in or not.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (_) {
      // No firebase_options.dart / native config yet -- expected until a
      // real Firebase project is wired in. Everything below stays inert.
    }
  }

  /// Requests notification permission and, if granted, registers this
  /// device's FCM token with the backend (`POST /push-tokens`). Call once
  /// after a successful sign-in (login/register/session-restore) -- it's a
  /// no-op if [init] never managed to reach a real Firebase project.
  Future<void> registerCurrentToken() async {
    if (!_initialized) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token == null) return;

      await _send(token);

      messaging.onTokenRefresh.listen((refreshed) => _send(refreshed));
    } catch (_) {
      // Best-effort -- in-app notifications remain the fallback either way.
    }
  }

  /// Best-effort cleanup on sign-out, so a shared/reused device doesn't keep
  /// receiving push for an account it's no longer signed into.
  Future<void> unregisterCurrentToken() async {
    if (!_initialized) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _client.delete('/push-tokens', data: {'token': token});
    } catch (_) {
      // Not worth surfacing -- the token just goes stale server-side.
    }
  }

  Future<void> _send(String token) async {
    try {
      await _client.post('/push-tokens', data: {'platform': _platform, 'provider': 'fcm', 'token': token});
    } catch (_) {
      // Best-effort -- retried naturally on the next sign-in or token refresh.
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(apiClientProvider));
});
