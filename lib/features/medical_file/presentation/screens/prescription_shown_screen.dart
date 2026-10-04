import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../prescriptions/application/pharmacy_prescriptions_providers.dart';
import '../../../prescriptions/data/pharmacy_prescriptions_api.dart';

/// The pharmacist's side of a shown prescription (what the patient's QR carried). The content is read from
/// the code; when the viewer is a business account the server is asked whether it is EXACTLY what the doctor
/// wrote and whether it can still be dispensed — and a pharmacy may then record the hand-over, once.
class PrescriptionShownScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> payload;
  final String sharedBy;
  const PrescriptionShownScreen({super.key, required this.payload, required this.sharedBy});

  @override
  ConsumerState<PrescriptionShownScreen> createState() => _PrescriptionShownScreenState();
}

class _PrescriptionShownScreenState extends ConsumerState<PrescriptionShownScreen> {
  PrescriptionCheck? _check;
  bool _checking = false;
  bool _unavailable = false;
  bool _dispensing = false;
  String? _error;
  bool _done = false;

  int get _id => (widget.payload['id'] as num).toInt();
  Map<String, dynamic> get _content => Map<String, dynamic>.from(widget.payload['content'] as Map);

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    if (auth is AuthSignedIn && auth.user.isBusiness) {
      _verify();
    } else {
      _unavailable = true;
    }
  }

  Future<void> _verify() async {
    setState(() => _checking = true);
    try {
      final check = await ref.read(pharmacyPrescriptionsApiProvider).verify(_id, _content);
      if (mounted) setState(() => _check = check);
    } on ApiException catch (e) {
      // A business that is not a pharmacy has no door here (403): show the content unverified.
      if (mounted) setState(() => e.statusCode == 403 ? _unavailable = true : _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _dispense() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.rxDispenseConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.rxDispenseNow)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _dispensing = true;
      _error = null;
    });
    try {
      await ref.read(pharmacyPrescriptionsApiProvider).dispenseInPerson(_id, _content);
      if (mounted) setState(() => _done = true);
      await _verify();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _dispensing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [for (final i in _content['items'] as List<dynamic>? ?? const []) Map<String, dynamic>.from(i as Map)];
    final check = _check;

    Widget banner(Color color, IconData icon, String text) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)))]),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rxShownTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.rxShownBy(widget.sharedBy), style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          if (_checking) Row(children: [const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 10), Text(l10n.rxVerifyWorking)]),
          if (_unavailable) Text(l10n.rxCheckUnavailable, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          if (check != null && !check.authentic) banner(AppColors.error, Icons.gpp_bad_outlined, l10n.rxNotVerified),
          if (check != null && check.authentic) ...[
            banner(AppColors.success, Icons.verified_outlined, l10n.rxVerified),
            const SizedBox(height: 8),
            if (check.doctorName != null) Text(l10n.rxIssuedBy(check.doctorName!), style: theme.textTheme.titleSmall),
            if (check.issuedAt != null) Text(DateFormat.yMMMd().add_Hm().format(check.issuedAt!), style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            if (check.superseded)
              banner(AppColors.error, Icons.update_disabled, l10n.rxSuperseded)
            else if (check.status == 'dispensed')
              banner(AppColors.error, Icons.block, l10n.rxAlreadyDispensed)
            else if (check.canDispense)
              banner(AppColors.success, Icons.check_circle_outline, l10n.rxCanDispense)
            else
              banner(AppColors.error, Icons.block, l10n.rxCancelledOrOther),
          ],
          if (_done) ...[const SizedBox(height: 8), banner(AppColors.success, Icons.task_alt, l10n.rxDispensed)],
          if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: TextStyle(color: theme.colorScheme.error))],
          if (((_content['diagnosis'] ?? '') as Object).toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.rxDiagnosis, style: theme.textTheme.labelLarge),
            Text('${_content['diagnosis']}'),
          ],
          const SizedBox(height: 12),
          for (final i in items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${i['name'] ?? ''}'),
                subtitle: Text([
                  if ('${i['dosage'] ?? ''}'.isNotEmpty) l10n.rxItemDosage('${i['dosage']}'),
                  if ('${i['quantity'] ?? ''}'.isNotEmpty) l10n.rxItemQuantity('${i['quantity']}'),
                  if ('${i['instructions'] ?? ''}'.isNotEmpty) '${i['instructions']}',
                ].join(' — ')),
              ),
            ),
          if ('${_content['notes'] ?? ''}'.isNotEmpty) ...[
            Text(l10n.rxNotes, style: theme.textTheme.labelLarge),
            Text('${_content['notes']}'),
          ],
        ],
      ),
      bottomNavigationBar: check != null && check.authentic && check.canDispense && !_done
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: FilledButton.icon(
                onPressed: _dispensing ? null : _dispense,
                icon: const Icon(Icons.local_pharmacy_outlined),
                label: Text(l10n.rxDispenseNow),
              ),
            )
          : null,
    );
  }
}
