/// Build-time environment configuration.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2/testing/public/api/v2
///
/// Defaults to the XAMPP dev server reachable from an Android emulator
/// (10.0.2.2 is the emulator's alias for the host machine's localhost).
/// A physical device or desktop/web build needs the machine's LAN IP instead.
class Env {
  const Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/testing/public/api/v2',
  );

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
