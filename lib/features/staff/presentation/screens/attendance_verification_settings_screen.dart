import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/attendance_qr_providers.dart';
import 'attendance_qr_display_screen.dart';

/// Owner-only: the on/off switch for GPS + rotating-QR attendance
/// verification (StaffAttendanceController::updateSettings), plus the way
/// in to the physical display screen. A business that never opens this
/// screen never turns the toggle on, so its staff keep the plain
/// self-service check-in they always had.
class AttendanceVerificationSettingsScreen extends ConsumerStatefulWidget {
  const AttendanceVerificationSettingsScreen({super.key});

  @override
  ConsumerState<AttendanceVerificationSettingsScreen> createState() => _AttendanceVerificationSettingsScreenState();
}

class _AttendanceVerificationSettingsScreenState extends ConsumerState<AttendanceVerificationSettingsScreen> {
  bool? _enabled;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final enabled = await ref.read(attendanceQrApiProvider).settings();
      if (mounted) setState(() => _enabled = enabled);
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _saving = true);
    try {
      final enabled = await ref.read(attendanceQrApiProvider).updateSettings(value);
      if (mounted) setState(() => _enabled = enabled);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendanceVerificationSettingsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  value: _enabled ?? false,
                  onChanged: _saving ? null : _toggle,
                  title: Text(l10n.attendanceVerificationToggleLabel),
                  subtitle: Text(l10n.attendanceVerificationToggleHint),
                ),
                const SizedBox(height: 16),
                if (_enabled == true)
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AttendanceQrDisplayScreen()),
                    ),
                    icon: const Icon(Icons.qr_code_2),
                    label: Text(l10n.attendanceOpenDisplayScreen),
                  ),
              ],
            ),
    );
  }
}
