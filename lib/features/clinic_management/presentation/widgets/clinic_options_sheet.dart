import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// The two OPTIONAL levers of a clinic or hospital (never automatic):
///  - the arrival QR: shown at the door, scanned by the patient with the platform scanner to be activated in the queue;
///  - «اكتمل العدد اليوم»: close new bookings for today — a doctor may instead add working hours for more patients.
Future<void> showClinicOptionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ClinicOptionsSheet(),
  );
}

class _ClinicOptionsSheet extends ConsumerStatefulWidget {
  const _ClinicOptionsSheet();

  @override
  ConsumerState<_ClinicOptionsSheet> createState() => _ClinicOptionsSheetState();
}

class _ClinicOptionsSheetState extends ConsumerState<_ClinicOptionsSheet> {
  bool _loaded = false;
  bool _failed = false;
  bool _busy = false;
  bool _qrEnabled = false;
  String? _qrToken;
  String? _closedDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = ref.read(apiClientProvider);

    try {
      final qr = await client.get('/business/clinic-arrival-qr') as Map<String, dynamic>;
      final closure = await client.get('/business/booking-day-closure') as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _qrEnabled = qr['enabled'] == true;
        _qrToken = qr['token'] as String?;
        _closedDate = closure['closed_date'] as String?;
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _setQr({required bool enabled, bool rotate = false}) async {
    setState(() => _busy = true);

    try {
      final data = await ref.read(apiClientProvider).put(
        '/business/clinic-arrival-qr',
        data: {'enabled': enabled, if (rotate) 'rotate': true},
      ) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _qrEnabled = data['enabled'] == true;
        _qrToken = data['token'] as String?;
      });
    } catch (e) {
      if (mounted) _toast(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setClosure(bool closed) async {
    setState(() => _busy = true);

    try {
      final data = await ref.read(apiClientProvider).put('/business/booking-day-closure', data: {'closed': closed}) as Map<String, dynamic>;

      if (mounted) setState(() => _closedDate = data['closed_date'] as String?);
    } catch (e) {
      if (mounted) _toast(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(Object e) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: _failed
            ? Text(l10n.commonSomethingWentWrong)
            : !_loaded
            ? const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.clinicOptionsTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.clinicArrivalQrTitle),
                    subtitle: Text(l10n.clinicArrivalQrHint),
                    value: _qrEnabled,
                    onChanged: _busy ? null : (v) => _setQr(enabled: v),
                  ),
                  if (_qrEnabled && _qrToken != null) ...[
                    Center(child: QrImageView(data: _qrToken!, size: 200, backgroundColor: Colors.white)),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: _busy ? null : () => _setQr(enabled: true, rotate: true),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.clinicArrivalQrRotate),
                      ),
                    ),
                  ],
                  const Divider(height: 28),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.clinicDayClosureTitle),
                    subtitle: Text(_closedDate != null ? l10n.clinicDayClosureClosedOn(_closedDate!) : l10n.clinicDayClosureBody),
                    value: _closedDate != null,
                    onChanged: _busy ? null : _setClosure,
                  ),
                ],
              ),
      ),
    );
  }
}
