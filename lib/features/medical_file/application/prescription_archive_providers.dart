import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../prescriptions/application/prescriptions_providers.dart'
    show prescriptionsApiProvider;
import '../../prescriptions/data/models/prescription.dart';
import '../data/prescription_archive_store.dart';

final prescriptionArchiveStoreProvider = Provider<PrescriptionArchiveStore>(
  (ref) => PrescriptionArchiveStore(ref.watch(secureStorageProvider)),
);

/// The signed-in patient's archive on this phone: every prescription of his the app has ever seen, newest first.
/// A fresh copy from the server replaces the old one (its status moves on); nothing is ever dropped from here
/// when the server stops sending it — that is the point of keeping it on the phone.
class PrescriptionArchiveController
    extends StateNotifier<AsyncValue<List<Prescription>>> {
  final PrescriptionArchiveStore _store;
  final int? _userId;

  /// Tells the server this phone now holds the exact copy (so it may later drop the sensitive fields). Best effort:
  /// a failed call is simply repeated the next time the list is fetched.
  final Future<void> Function(int id, Map<String, dynamic> content)? _confirm;
  Map<int, Map<String, dynamic>> _raw = {};
  late final Future<void> _ready;

  PrescriptionArchiveController(
    this._store,
    this._userId, {
    Future<void> Function(int, Map<String, dynamic>)? confirm,
  }) : _confirm = confirm,
       super(const AsyncValue.loading()) {
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
      ..sort(
        (a, b) =>
            (b.issuedAt ?? DateTime(0)).compareTo(a.issuedAt ?? DateTime(0)),
      );
    state = AsyncValue.data(all);
  }

  /// What the encrypted backup carries.
  List<Map<String, dynamic>> get rawList => _raw.values.toList();

  /// The fields the server drops once it knows this phone holds them.
  static const _sensitive = [
    'diagnosis',
    'patient_condition',
    'notes',
    'verifiable',
  ];

  /// What this phone keeps of a prescription the server just sent. A copy the server has PURGED must never replace
  /// the full one already here — the phone's copy is then the only one: the fresh copy's status, prices and dates
  /// are taken, the diagnosis, condition, notes and verifiable content are kept from the old one.
  Map<String, dynamic> _merged(
    Map<String, dynamic> fresh,
    Map<String, dynamic>? old,
  ) {
    if (fresh['content_purged'] != true || old == null) return fresh;
    final merged = Map<String, dynamic>.from(fresh);
    for (final key in _sensitive) {
      if (old[key] != null) merged[key] = old[key];
    }
    return merged;
  }

  /// Remember what the server just sent (only this account's own prescriptions).
  Future<void> remember(Iterable<Prescription> fresh) async {
    final id = _userId;
    if (id == null) return;
    await _ready; // never write over what is still being read
    var changed = false;
    final toConfirm = <Prescription>[];
    for (final p in fresh) {
      if (p.patient.id != id || p.raw.isEmpty) continue;
      _raw[p.id] = _merged(p.raw, _raw[p.id]);
      changed = true;
      if (p.verifiableContent != null && !p.archivedByPatient) toConfirm.add(p);
    }
    if (!changed) return;
    await _store.write(id, _raw);
    _publish();

    // Only after the copy is durably on this phone is the server told so.
    for (final p in toConfirm) {
      try {
        await _confirm?.call(p.id, p.verifiableContent!);
      } catch (_) {
        // tried again on the next fetch
      }
    }
  }

  /// A restored backup brings back what this phone does not have — a newer copy already here wins.
  Future<void> restore(Iterable<Map<String, dynamic>> raws) async {
    final id = _userId;
    if (id == null) return;
    await _ready;
    for (final r in raws) {
      final rid = r['id'];
      if (rid is int && !_raw.containsKey(rid)) {
        _raw[rid] = Map<String, dynamic>.from(r);
      }
    }
    await _store.write(id, _raw);
    _publish();
  }
}

final prescriptionArchiveProvider =
    StateNotifierProvider<
      PrescriptionArchiveController,
      AsyncValue<List<Prescription>>
    >((ref) {
      final auth = ref.watch(authControllerProvider);
      return PrescriptionArchiveController(
        ref.watch(prescriptionArchiveStoreProvider),
        auth is AuthSignedIn ? auth.user.id : null,
        confirm: ref.read(prescriptionsApiProvider).confirmArchived,
      );
    });
