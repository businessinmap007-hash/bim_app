import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/medical_file.dart';
import '../data/medical_file_store.dart';
import '../data/medical_share_api.dart';

final medicalFileStoreProvider = Provider<MedicalFileStore>((ref) => MedicalFileStore(ref.watch(secureStorageProvider)));

final medicalShareApiProvider = Provider<MedicalShareApi>((ref) => MedicalShareApi(ref.watch(apiClientProvider)));

/// The signed-in account's medical file on this phone; every change is saved at once, on the phone only.
class MedicalFileController extends StateNotifier<AsyncValue<MedicalFile>> {
  final MedicalFileStore _store;
  final int? _userId;

  MedicalFileController(this._store, this._userId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final id = _userId;
    if (id == null) {
      state = const AsyncValue.data(MedicalFile());
      return;
    }
    try {
      state = AsyncValue.data(await _store.read(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(MedicalFile file) async {
    state = AsyncValue.data(file);
    final id = _userId;
    if (id != null) await _store.write(id, file);
  }
}

final medicalFileControllerProvider = StateNotifierProvider.autoDispose<MedicalFileController, AsyncValue<MedicalFile>>((ref) {
  final auth = ref.watch(authControllerProvider);
  return MedicalFileController(ref.watch(medicalFileStoreProvider), auth is AuthSignedIn ? auth.user.id : null);
});
