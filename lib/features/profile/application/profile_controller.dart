import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/models/auth_user.dart';
import '../data/profile_api.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(apiClientProvider));
});

/// Edits the signed-in user's own account and pushes the result back into
/// [authControllerProvider] so the change shows up everywhere immediately
/// (app bars, the business home header, ...) without a page refetch.
class ProfileController {
  final ProfileApi _api;
  final Ref _ref;

  ProfileController(this._api, this._ref);

  Future<AuthUser> update({
    String? name,
    String? nameEn,
    String? phone,
    String? about,
    double? latitude,
    double? longitude,
    int? countryId,
    int? governorateId,
    int? cityId,
    int? categoryId,
    int? categoryChildId,
    String? type,
  }) async {
    final user = await _api.update(
      name: name,
      nameEn: nameEn,
      phone: phone,
      about: about,
      latitude: latitude,
      longitude: longitude,
      countryId: countryId,
      governorateId: governorateId,
      cityId: cityId,
      categoryId: categoryId,
      categoryChildId: categoryChildId,
      type: type,
    );
    _ref.read(authControllerProvider.notifier).setUser(user);
    return user;
  }

  Future<AuthUser> uploadImage(String filePath) async {
    final user = await _api.uploadImage(filePath);
    _ref.read(authControllerProvider.notifier).setUser(user);
    return user;
  }

  Future<AuthUser> removeImage() async {
    final user = await _api.removeImage();
    _ref.read(authControllerProvider.notifier).setUser(user);
    return user;
  }
}

final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(ref.watch(profileApiProvider), ref);
});
