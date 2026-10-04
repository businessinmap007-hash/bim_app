import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/medical_file_providers.dart';
import '../../data/medical_file.dart';
import '../../data/medical_share_crypto.dart';
import 'prescription_shown_screen.dart';
import '../medical_labels.dart';

/// The doctor's or pharmacist's side: scan the patient's code, fetch the ciphertext, open it HERE with the key
/// the code carried. What is read is shown, never saved on this phone.
class MedicalScanScreen extends ConsumerStatefulWidget {
  const MedicalScanScreen({super.key});

  @override
  ConsumerState<MedicalScanScreen> createState() => _MedicalScanScreenState();
}

class _MedicalScanScreenState extends ConsumerState<MedicalScanScreen> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _handled = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;
    final l10n = AppLocalizations.of(context)!;
    final code = MedicalShareCrypto.parseQr(raw);
    if (code == null) {
      setState(() => _message = l10n.medicalShareInvalid);
      return;
    }
    _handled = true;
    try {
      final shared = await ref.read(medicalShareApiProvider).fetch(code.id);
      final opened = await MedicalShareCrypto.open(shared.ciphertext, code.key);
      if (!mounted) return;
      // The same code carries a medical file or ONE prescription: the payload says which.
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => opened['kind'] == 'prescription'
            ? PrescriptionShownScreen(payload: opened, sharedBy: shared.sharedBy)
            : MedicalFileViewScreen(file: MedicalFile.fromJson(opened), sharedBy: shared.sharedBy, sharedAt: shared.createdAt),
      ));
    } catch (_) {
      _handled = false;
      if (mounted) setState(() => _message = l10n.medicalShareUnreadable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalScan), backgroundColor: Colors.black, foregroundColor: Colors.white),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(border: Border.all(color: Colors.white70, width: 2), borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
              child: Text(_message ?? l10n.medicalScanHint, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

/// A shared medical file, read-only, on the doctor's phone for as long as this screen is open.
class MedicalFileViewScreen extends StatelessWidget {
  final MedicalFile file;
  final String sharedBy;
  final DateTime sharedAt;
  const MedicalFileViewScreen({super.key, required this.file, required this.sharedBy, required this.sharedAt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalSharedBy(sharedBy))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.medicalSharedAt(DateFormat.yMMMd().add_Hm().format(sharedAt)), style: theme.textTheme.bodySmall),
          Text(l10n.medicalViewNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          if (file.bloodType.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.bloodtype_outlined),
                title: Text(l10n.medicalBloodType),
                trailing: Directionality(textDirection: TextDirection.ltr, child: Text(file.bloodType, style: theme.textTheme.titleMedium)),
              ),
            ),
          ],
          for (final section in MedicalSection.values)
            if (file.entries(section).isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(medicalSectionLabel(l10n, section), style: theme.textTheme.titleSmall),
              for (final entry in file.entries(section))
                Card(
                  margin: const EdgeInsets.only(top: 6),
                  child: ListTile(title: Text(entry.title), subtitle: entry.detail.isEmpty ? null : Text(entry.detail)),
                ),
            ],
          if (file.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.medicalNotes, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(file.notes),
          ],
        ],
      ),
    );
  }
}
