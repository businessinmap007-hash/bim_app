import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Sanctum bearer token across app restarts. Secure storage
/// (Keychain/Keystore) is used because this token is a full login session,
/// not a cache value — never move it to shared_preferences.
class TokenStorage {
  static const _tokenKey = 'bim_auth_token';

  final FlutterSecureStorage _storage;

  const TokenStorage(this._storage);

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
