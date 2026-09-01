import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../auth/data/models/auth_user.dart';

/// GET/PATCH /profile and POST /profile/image — always the caller's OWN
/// account (Api\V2\ProfileController::show/update take no id param), never
/// another user's. There is deliberately no "view another account" endpoint
/// on the backend at all — see the privacy rule this screen exists to honour.
class ProfileApi {
  final ApiClient _client;

  const ProfileApi(this._client);

  Future<AuthUser> update({
    String? name,
    String? phone,
    String? about,
    double? latitude,
    double? longitude,
  }) async {
    final data = await _client.put(
      '/profile',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (about != null) 'about': about,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return AuthUser.fromJson(data as Map<String, dynamic>);
  }

  Future<AuthUser> uploadImage(String filePath) async {
    final data = await _client.post(
      '/profile/image',
      data: FormData.fromMap({'image': await MultipartFile.fromFile(filePath)}),
    );
    return AuthUser.fromJson(data as Map<String, dynamic>);
  }

  Future<AuthUser> removeImage() async {
    final data = await _client.post('/profile/image', data: FormData.fromMap({'remove': true}));
    return AuthUser.fromJson(data as Map<String, dynamic>);
  }
}
