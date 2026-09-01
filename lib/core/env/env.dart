import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Build-time environment configuration.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://192.168.x.x/testing/public/api/v2
///
/// Without an override, the default is platform-aware: an Android emulator
/// needs 10.0.2.2 (its alias for the host machine's localhost) — every other
/// target (web, desktop, iOS simulator) reaches the host directly as
/// localhost. Getting this wrong on web isn't a slow request, it's a dead
/// one: 10.0.2.2 resolves to nothing in a real browser, so every screen that
/// needs the API just times out (15s) with no visible error.
/// A physical device still needs the machine's LAN IP via the dart-define.
class Env {
  const Env._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/testing/public/api/v2';
    }
    return 'http://localhost/testing/public/api/v2';
  }

  static const bool logNetwork = bool.fromEnvironment(
    'LOG_NETWORK',
    defaultValue: true,
  );

  /// The server's document root (no `/api/v2`) — image paths like `logo`
  /// come back as paths relative to this (e.g. `files/uploads/x.jpg`), not
  /// full URLs. Derived from [apiBaseUrl] so there's one source of truth.
  static String get assetBaseUrl {
    const suffix = '/api/v2';
    return apiBaseUrl.endsWith(suffix)
        ? apiBaseUrl.substring(0, apiBaseUrl.length - suffix.length)
        : apiBaseUrl;
  }

  /// Builds a full URL for a relative asset path the backend returned, or
  /// null if there isn't one — callers decide the placeholder.
  static String? assetUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }
    return '$assetBaseUrl/$relativePath';
  }
}
