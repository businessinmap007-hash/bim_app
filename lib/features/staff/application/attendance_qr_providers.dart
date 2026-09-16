import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/attendance_qr_api.dart';

final attendanceQrApiProvider = Provider<AttendanceQrApi>((ref) {
  return AttendanceQrApi(ref.watch(apiClientProvider));
});

/// The current owner-only display code, refreshed on a modest fixed
/// interval rather than pushed — see AttendanceQrApi's own doc comment.
/// One device per business polling every 30s is a negligible request rate;
/// the endpoint itself only actually rotates the code when it's scanned or
/// expires, so most polls just re-confirm the same code is still showing.
class AttendanceQrDisplayController extends StateNotifier<AsyncValue<AttendanceQrCode>> {
  final AttendanceQrApi _api;
  Timer? _timer;

  AttendanceQrDisplayController(this._api) : super(const AsyncValue.loading()) {
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  Future<void> _load() async {
    try {
      final code = await _api.current();
      if (mounted) state = AsyncValue.data(code);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final attendanceQrDisplayControllerProvider =
    StateNotifierProvider.autoDispose<AttendanceQrDisplayController, AsyncValue<AttendanceQrCode>>((ref) {
      return AttendanceQrDisplayController(ref.watch(attendanceQrApiProvider));
    });
