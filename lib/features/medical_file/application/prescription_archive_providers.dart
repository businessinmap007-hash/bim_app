import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../prescriptions/data/models/prescription.dart';
import '../data/prescription_archive_store.dart';

final prescriptionArchiveStoreProvider =
    Provider<PrescriptionArchiveStore>((ref) => PrescriptionArchiveStore(ref.watch(secureStorageProvider)));

/// The signed-in patient's archive on this phone: every prescription of his the app has ever seen, newest first.
/// A fresh copy from the server replaces the old one (its status moves on); nothing is ever dropped from here
/// when the server stops sending it — that is the point of keeping it on the phone.
class PrescriptionArchiveController extends StateNotifier<AsyncValue<List<Prescription>>> {
  final PrescriptionArchiveStore _store;
  final int? _userId;
  Map<int, Map<String, dynamic>> _raw = {};
  late final Future<void> _ready;

  PrescriptionArchiveController(this._store, this._userId) : super(const AsyncValue.loading()) {
    _ready = _load();
  }

  Future<void> _load() async {
    final id = _userId;
    if (id == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      _raw = await _store.read(id);
      _publish();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _publish() {
    final all = _raw.values.map(Prescription.fromJson).toList()
      ..sort((a, b) => (b.issuedAt ?? DateTime(0)).compareTo(a.issuedAt ?? DateTime(0)));
    state = AsyncValue.data(all);
  }

  /// What the encrypted backup carries.
  List<Map<String, dynamic>> get rawList => _raw.values.toList();

  /// Remember what the server just sent (only this account's own prescriptions).
  Future<void> remember(Iterable<Prescription> fresh) async {
    final id = _userId;
    if (id == null) return;
    await _ready; // never write over what is still being read
    var changed = false;
    for (final p in fresh) {
      if (p.patient.id != id || p.raw.isEmpty) continue;
      _raw[p.id] = p.raw;
      changed = true;
    }
    if (!changed) return;
    await _store.write(id, _raw);
    _publish();
  }

  /// A restored backup brings back what this phone does not have — a newer copy already here wins.
  Future<void> restore(Iterable<Map<String, dynamic>> raws) async {
    final id = _userId;
    if (id == null) return;
    await _ready;
    for (final r in raws) {
      final rid = r['id'];
      if (rid is int && !_raw.containsKey(rid)) _raw[rid] = Map<String, dynamic>.from(r);
    }
    await _store.write(id, _raw);
    _publish();
  }
}

final prescriptionArchiveProvider =
    StateNotifierProvider<PrescriptionArchiveController, AsyncValue<List<Prescription>>>((ref) {
      final auth = ref.watch(authControllerProvider);
      return PrescriptionArchiveController(ref.watch(prescriptionArchiveStoreProvider), auth is AuthSignedIn ? auth.user.id : null);
    });
