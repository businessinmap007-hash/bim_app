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
}
