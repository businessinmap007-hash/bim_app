import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/attendance_qr_providers.dart';

/// Meant to stay open on a physical device at the business premises — staff
/// scan this to check in/out (StaffAttendanceQrService). The code rotates
/// itself server-side the instant it's scanned or after
/// StaffAttendanceQrService::TTL_MINUTES; this screen just polls for
/// whatever is current right now (attendance_qr_providers.dart) so the
/// screen always shows a live, unscanned code.
class AttendanceQrDisplayScreen extends ConsumerWidget {
  const AttendanceQrDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(attendanceQrDisplayControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendanceQrDisplayTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.attendanceQrDisplayHint, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              state.when(
                data: (code) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: QrImageView(data: code.token, size: 260, backgroundColor: Colors.white),
                ),
                loading: () => const SizedBox(height: 260, width: 260, child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SizedBox(
                  height: 260,
                  width: 260,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40),
                        const SizedBox(height: 8),
                        Text(l10n.commonSomethingWentWrong, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
