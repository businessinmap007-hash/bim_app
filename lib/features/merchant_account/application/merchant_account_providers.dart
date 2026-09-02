import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/merchant_account_api.dart';
import '../data/models/merchant_account_status.dart';

final merchantAccountApiProvider = Provider<MerchantAccountApi>((ref) {
  return MerchantAccountApi(ref.watch(apiClientProvider));
});

class MerchantAccountController extends StateNotifier<AsyncValue<MerchantAccountStatus>> {
  final MerchantAccountApi _api;

  MerchantAccountController(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.status());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> apply({String? note}) async {
    await _api.apply(note: note);
    await load();
  }
}

final merchantAccountControllerProvider =
    StateNotifierProvider<MerchantAccountController, AsyncValue<MerchantAccountStatus>>((ref) {
      return MerchantAccountController(ref.watch(merchantAccountApiProvider));
    });
