import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../auth/data/models/auth_user.dart';
import 'models/profile_options.dart';

/// GET/PATCH /profile and POST /profile/image — always the caller's OWN
/// account (Api\V2\ProfileController::show/update take no id param), never
/// another user's. There is deliberately no "view another account" endpoint
/// on the backend at all — see the privacy rule this screen exists to honour.
class ProfileApi {
  final ApiClient _client;

  const ProfileApi(this._client);

  Future<AuthUser> update({
    String? name,
    String? nameEn,
    String? phone,
    String? about,
    double? latitude,
    double? longitude,
    // The administrative location — independent of the GPS point above.
    // Settable together (after a GET /locations/nearest GPS lookup) or on
    // their own (a manual picker).
    int? countryId,
    int? governorateId,
    int? cityId,
    int? categoryId,
    int? categoryChildId,
    // Only 'business' is ever sent — see ProfileController::update on the
    // backend for why a business can't self-downgrade through this call.
    String? type,
  }) async {
    final data = await _client.put(
      '/profile',
      data: {
        if (name != null) 'name': name,
        if (nameEn != null) 'name_en': nameEn,
        if (phone != null) 'phone': phone,
        if (about != null) 'about': about,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (countryId != null) 'country_id': countryId,
        if (governorateId != null) 'governorate_id': governorateId,
        if (cityId != null) 'city_id': cityId,
        if (categoryId != null) 'category_id': categoryId,
        if (categoryChildId != null) 'category_child_id': categoryChildId,
        if (type != null) 'type': type,
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

  /// Business only — the backend 403s a client account. Only called once
  /// the profile screen already knows `isBusiness`, so that never surfaces.
  Future<ProfileOptionsPayload> showOptions() async {
    final data = await _client.get('/profile/options');
    return ProfileOptionsPayload.fromJson(data as Map<String, dynamic>);
  }

  Future<ProfileOptionsPayload> updateOptions(List<int> optionIds) async {
    final data = await _client.put('/profile/options', data: {'option_ids': optionIds});
    return ProfileOptionsPayload.fromJson(data as Map<String, dynamic>);
  }
}
