import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../prescriptions/data/models/prescription.dart';
import '../../../prescriptions/presentation/screens/prescriptions_screen.dart' show statusLabel;
import '../../application/medical_file_providers.dart';
import '../../application/prescription_archive_providers.dart';
import '../../data/medical_share_crypto.dart';

/// «روشتاتي المحفوظة على الهاتف» — المالك، 2026-10-05: «الروشتات تحفظ على الفون وعند مشاركتها تقرأ وتعرض
/// للصيدلي». Every prescription a doctor wrote for this patient, kept here as the server sent it; each can be
/// shown to a pharmacist by an encrypted QR code.
class PrescriptionArchiveScreen extends ConsumerWidget {
  const PrescriptionArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(prescriptionArchiveProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rxArchiveTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lock_outline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.rxArchiveNote, style: theme.textTheme.bodySmall)),
            ]),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Text(l10n.rxArchiveEmpty, textAlign: TextAlign.center)))
            else
              for (final p in items)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PrescriptionCopyScreen(prescription: p))),
                    title: Text(p.items.map((i) => i.name ?? '').where((n) => n.isNotEmpty).join('، ')),
                    subtitle: Text([
                      if (p.doctor?.name != null) p.doctor!.name!,
                      if (p.issuedAt != null) DateFormat.yMMMd().format(p.issuedAt!.toLocal()),
                    ].join(' — ')),
                    trailing: Text(statusLabel(p.status, l10n), style: theme.textTheme.bodySmall),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// One archived prescription, read from the phone, with «عرض على صيدلي».
class PrescriptionCopyScreen extends StatelessWidget {
  final Prescription prescription;
  const PrescriptionCopyScreen({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = prescription;

    return Scaffold(
      appBar: AppBar(title: Text('#${p.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p.doctor?.name != null) Text(l10n.rxIssuedBy(p.doctor!.name!), style: theme.textTheme.titleSmall),
          if (p.issuedAt != null) Text(DateFormat.yMMMd().add_Hm().format(p.issuedAt!.toLocal()), style: theme.textTheme.bodySmall),
          if (p.contentPurged) ...[
            const SizedBox(height: 8),
            Text(l10n.rxPurgedNote, style: theme.textTheme.bodySmall),
          ],
          if ((p.diagnosis ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.rxDiagnosis, style: theme.textTheme.labelLarge),
            Text(p.diagnosis!),
          ],
          const SizedBox(height: 12),
          for (final i in p.items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(i.name ?? ''),
                subtitle: Text([
                  if ((i.dosage ?? '').isNotEmpty) l10n.rxItemDosage(i.dosage!),
                  if ((i.quantity ?? '').isNotEmpty) l10n.rxItemQuantity(i.quantity!),
                  if ((i.instructions ?? '').isNotEmpty) i.instructions!,
                ].join(' — ')),
              ),
            ),
          if ((p.notes ?? '').isNotEmpty) ...[
            Text(l10n.rxNotes, style: theme.textTheme.labelLarge),
            Text(p.notes!),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: FilledButton.icon(
          onPressed: p.verifiableContent == null
              ? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.rxNoCopy)))
              : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PrescriptionShowScreen(prescription: p))),
          icon: const Icon(Icons.qr_code_2),
          label: Text(l10n.rxShowPharmacist),
        ),
      ),
    );
  }
}

/// Shows the QR code for ONE prescription: its canonical content, sealed with a key that lives only in the code.
class PrescriptionShowScreen extends ConsumerStatefulWidget {
  final Prescription prescription;
  const PrescriptionShowScreen({super.key, required this.prescription});

  @override
  ConsumerState<PrescriptionShowScreen> createState() => _PrescriptionShowScreenState();
}

class _PrescriptionShowScreenState extends ConsumerState<PrescriptionShowScreen> {
  ({String id, String qr, DateTime expiresAt})? _share;
  bool _busy = false;
  String? _error;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final sealed = await MedicalShareCrypto.seal({
        'kind': 'prescription',
        'id': widget.prescription.id,
        'content': widget.prescription.verifiableContent,
        'doctor_name': widget.prescription.doctor?.name,
      });
      final created = await ref.read(medicalShareApiProvider).create(sealed.ciphertext, minutes: 15);
      setState(() => _share = (id: created.id, qr: MedicalShareCrypto.qrPayload(created.id, sealed.key), expiresAt: created.expiresAt));
      _ticker = Timer.periodic(const Duration(seconds: 15), (_) {
        if (!mounted) return;
        if (_share != null && DateTime.now().isAfter(_share!.expiresAt)) {
          setState(() => _share = null);
          _ticker?.cancel();
        } else {
          setState(() {});
        }
      });
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _end() async {
    final share = _share;
    if (share == null) return;
    _ticker?.cancel();
    setState(() => _share = null);
    try {
      await ref.read(medicalShareApiProvider).end(share.id);
    } catch (_) {
      // it ends by itself at its time
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final share = _share;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rxShowTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: share == null
            ? [
                Text(l10n.rxShowHint, style: theme.textTheme.bodyMedium),
                if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: theme.colorScheme.error))],
                const SizedBox(height: 20),
                FilledButton.icon(onPressed: _busy ? null : _create, icon: const Icon(Icons.qr_code_2), label: Text(l10n.rxShowCreate)),
              ]
            : [
                Text(l10n.medicalShareShowCode, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: QrImageView(data: share.qr, size: 260, backgroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.medicalShareExpires(DateFormat.Hm().format(share.expiresAt)), textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
                const SizedBox(height: 16),
                OutlinedButton.icon(onPressed: _end, icon: const Icon(Icons.stop_circle_outlined), label: Text(l10n.medicalShareEnd)),
              ],
      ),
    );
  }
}
