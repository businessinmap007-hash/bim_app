import '../../../core/network/api_client.dart';
import 'models/auth_user.dart';

/// Talks to `/auth/*` exactly as documented in the backend's
/// docs/api/openapi-v2.yaml — the Postman collection (BIM-v2.postman_collection.json)
/// is the fastest way to double check a shape before changing this file.
class AuthApi {
  final ApiClient _client;

  const AuthApi(this._client);

  Future<({AuthUser user, String token})> login({
    required String email,
    required String password,
  }) async {
    final body = await _client.postForBody(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return (
      user: AuthUser.fromJson(body['data'] as Map<String, dynamic>),
      token: body['token'] as String,
    );
  }

  Future<({AuthUser user, String token})> register({
    required String name,
    String? nameEn,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String type, // 'client' | 'business'
    int? categoryId,
    int? categoryChildId,
  }) async {
    final body = await _client.postForBody(
      '/auth/register',
      data: {
        'name': name,
        'name_en': ?nameEn,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'type': type,
        'category_id': ?categoryId,
        'category_child_id': ?categoryChildId,
        'terms_accepted': true,
      },
    );
    return (
      user: AuthUser.fromJson(body['data'] as Map<String, dynamic>),
      token: body['token'] as String,
    );
  }

  Future<AuthUser> me() async {
    final data = await _client.get('/auth/me');
    return AuthUser.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() => _client.post('/auth/logout');

  Future<void> forgotPassword(String email) =>
      _client.post('/auth/password/forgot', data: {'email': email});

  Future<void> resendResetCode(String email) =>
      _client.post('/auth/password/resend', data: {'email': email});

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) => _client.post(
    '/auth/password/verify',
    data: {'email': email, 'code': code},
  );

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) => _client.post(
    '/auth/password/reset',
    data: {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    },
  );
}
