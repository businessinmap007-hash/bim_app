import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/medical_file_providers.dart';
import '../../data/medical_file.dart';
import '../../data/medical_share_crypto.dart';
import '../medical_labels.dart';

/// The patient picks what to show, for how long, then shows the QR code to the doctor or pharmacist. The
/// code holds the key; the server holds only the ciphertext, and only until the share ends.
class MedicalShareScreen extends ConsumerStatefulWidget {
  final MedicalFile file;

  /// A clinic's COPY for the patient: the patient's phone offers to keep it in their own medical file.
  final bool asCopy;
  const MedicalShareScreen({super.key, required this.file, this.asCopy = false});

  @override
  ConsumerState<MedicalShareScreen> createState() => _MedicalShareScreenState();
}

class _MedicalShareScreenState extends ConsumerState<MedicalShareScreen> {
  late final Set<MedicalSection> _sections = {for (final s in MedicalSection.values) if (widget.file.entries(s).isNotEmpty) s};
  late bool _bloodType = widget.file.bloodType.isNotEmpty;
  late bool _notes = widget.file.notes.trim().isNotEmpty;
  int _minutes = 15;
  bool _busy = false;
  String? _error;

  ({String id, String qr, DateTime expiresAt})? _share;
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
      final shown = widget.file.only(sections: _sections, bloodType: _bloodType, notes: _notes);
      final sealed = await MedicalShareCrypto.seal({...shown.toJson(), if (widget.asCopy) 'copy': true});
      final created = await ref.read(medicalShareApiProvider).create(sealed.ciphertext, minutes: _minutes);
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
      // It ends by itself at its time anyway.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.medicalShareEnded)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final share = _share;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalShare)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: share != null
            ? [
                Text(l10n.medicalShareShowCode, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: QrImageView(data: share.qr, size: 260, backgroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.medicalShareExpires(DateFormat.Hm().format(share.expiresAt)),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(onPressed: _end, icon: const Icon(Icons.stop_circle_outlined), label: Text(l10n.medicalShareEnd)),
              ]
            : [
                Text(l10n.medicalShareChoose, style: theme.textTheme.titleSmall),
                if (widget.file.bloodType.isNotEmpty)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _bloodType,
                    onChanged: (v) => setState(() => _bloodType = v ?? false),
                    title: Text('${l10n.medicalBloodType}: ${widget.file.bloodType}'),
                  ),
                for (final s in MedicalSection.values)
                  if (widget.file.entries(s).isNotEmpty)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _sections.contains(s),
                      onChanged: (v) => setState(() => v == true ? _sections.add(s) : _sections.remove(s)),
                      title: Text(medicalSectionLabel(l10n, s)),
                      subtitle: Text(widget.file.entries(s).map((e) => e.title).join('، ')),
                    ),
                if (widget.file.notes.trim().isNotEmpty)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _notes,
                    onChanged: (v) => setState(() => _notes = v ?? false),
                    title: Text(l10n.medicalNotes),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in const [15, 30, 60])
                      ChoiceChip(label: Text(l10n.medicalShareMinutes(m)), selected: _minutes == m, onSelected: (_) => setState(() => _minutes = m)),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _busy || (_sections.isEmpty && !_bloodType && !_notes) ? null : _create,
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(l10n.medicalShareCreate),
                ),
              ],
      ),
    );
  }
}
