import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/patient_records_providers.dart';
import '../../data/patient_backup.dart';
import '../../data/patient_record.dart';

final patientBackupApiProvider = Provider<PatientBackupApi>((ref) => PatientBackupApi(ref.watch(apiClientProvider)));

/// «نسخة احتياطية مشفّرة» of the clinic's patient files — the answer to a lost or replaced clinic device. The files are
/// gzipped and sealed on THIS device with a passphrase only the clinic knows; the result is kept as a file of the
/// clinic's own (Drive, a flash drive, e-mail — wherever it chooses) and/or on the server, which can read nothing of it.
/// Restoring merges: a file the device lacks is added, one it has is replaced only by a NEWER copy.
class PatientBackupScreen extends ConsumerStatefulWidget {
  const PatientBackupScreen({super.key});

  @override
  ConsumerState<PatientBackupScreen> createState() => _PatientBackupScreenState();
}

class _PatientBackupScreenState extends ConsumerState<PatientBackupScreen> {
  bool _busy = false;

  void _say(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<String?> _askPassphrase({required bool confirm}) => showDialog<String>(
    context: context,
    builder: (_) => _PassphraseDialog(confirm: confirm),
  );

  List<PatientRecord> get _records => ref.read(patientRecordsProvider).valueOrNull ?? const [];

  Future<void> _run(Future<void> Function() job) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await job();
    } on ApiException catch (e) {
      _say(e.message);
    } catch (_) {
      _say(l10n.patientBackupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toFile() async {
    final l10n = AppLocalizations.of(context)!;
    final pass = await _askPassphrase(confirm: true);
    if (pass == null || !mounted) return;

    await _run(() async {
      final blob = await PatientBackupCrypto.seal(_records, pass);
      final stamp = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
      final name = 'patient-files-$stamp.bimbak';
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(Uint8List.fromList(utf8.encode(blob)), name: name, mimeType: 'application/octet-stream')],
          fileNameOverrides: [name],
        ),
      );
      await ref.read(patientRecordsProvider.notifier).markBackedUp(DateTime.now());
      _say(l10n.patientBackupFileMade);
    });
  }

  Future<void> _toServer() async {
    final l10n = AppLocalizations.of(context)!;
    final pass = await _askPassphrase(confirm: true);
    if (pass == null || !mounted) return;

    await _run(() async {
      final blob = await PatientBackupCrypto.seal(_records, pass);
      final at = await ref.read(patientBackupApiProvider).put(blob);
      await ref.read(patientRecordsProvider.notifier).markBackedUp(at);
      _say(l10n.patientBackupServerDone);
    });
  }

  Future<void> _restore(String blob) async {
    final l10n = AppLocalizations.of(context)!;
    final pass = await _askPassphrase(confirm: false);
    if (pass == null || !mounted) return;

    await _run(() async {
      final List<PatientRecord> records;
      try {
        records = await PatientBackupCrypto.open(blob, pass);
      } catch (_) {
        _say(l10n.patientBackupWrongPassphrase);
        return;
      }
      final outcome = await ref.read(patientRecordsProvider.notifier).restore(records);
      await ref.read(patientRecordsProvider.notifier).markBackedUp(DateTime.now());
      _say(l10n.patientBackupRestored(outcome.added, outcome.updated));
    });
  }

  Future<void> _restoreFromFile() async {
    final picked = await FilePicker.pickFiles(withData: true);
    final bytes = picked?.files.single.bytes;
    if (bytes == null) return;

    await _restore(utf8.decode(bytes, allowMalformed: true));
  }

  Future<void> _restoreFromServer() async {
    final l10n = AppLocalizations.of(context)!;
    String? blob;
    await _run(() async {
      final got = await ref.read(patientBackupApiProvider).get();
      if (got == null) {
        _say(l10n.patientBackupNoServerCopy);
      } else {
        blob = got.blob;
      }
    });
    if (blob != null && mounted) await _restore(blob!);
  }

  Future<void> _deleteServerCopy() {
    final done = AppLocalizations.of(context)!.patientBackupServerDeleted;

    return _run(() async {
      await ref.read(patientBackupApiProvider).delete();
      _say(done);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final controller = ref.watch(patientRecordsProvider.notifier);
    ref.watch(patientRecordsProvider);
    final at = controller.backupAt;
    final changed = controller.changedSinceBackup;
    final total = _records.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientBackupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.patientBackupIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, size: 18, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.patientBackupPassphraseWarning, style: theme.textTheme.bodySmall)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(at == null ? l10n.patientBackupNever : l10n.patientBackupLast(DateFormat.yMMMd(locale).add_Hm().format(at))),
              subtitle: Text(l10n.patientBackupChanged(changed, total)),
            ),
          ),
          const SizedBox(height: 12),
          if (_busy) const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator()),
          FilledButton.icon(
            onPressed: _busy || total == 0 ? null : _toFile,
            icon: const Icon(Icons.save_alt_outlined),
            label: Text(l10n.patientBackupToFile),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy || total == 0 ? null : _toServer,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(l10n.patientBackupToServer),
          ),
          const SizedBox(height: 24),
          Text(l10n.patientBackupRestoreTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _restoreFromFile,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(l10n.patientBackupFromFile),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _restoreFromServer,
            icon: const Icon(Icons.cloud_download_outlined),
            label: Text(l10n.patientBackupFromServer),
          ),
          const SizedBox(height: 8),
          Text(l10n.patientBackupMergeNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 16),
          TextButton(onPressed: _busy ? null : _deleteServerCopy, child: Text(l10n.patientBackupDeleteServerCopy)),
        ],
      ),
    );
  }
}

class _PassphraseDialog extends StatefulWidget {
  final bool confirm;
  const _PassphraseDialog({required this.confirm});

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  static const _min = 8;
  final _pass = TextEditingController();
  final _again = TextEditingController();
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    _again.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    if (_pass.text.length < _min) {
      setState(() => _error = l10n.patientBackupPassphraseShort(_min));
    } else if (widget.confirm && _pass.text != _again.text) {
      setState(() => _error = l10n.patientBackupPassphraseMismatch);
    } else {
      Navigator.of(context).pop(_pass.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.confirm ? l10n.patientBackupChoosePassphrase : l10n.patientBackupEnterPassphrase),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pass,
            obscureText: _hide,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.patientBackupPassphrase,
              suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _hide = !_hide)),
            ),
          ),
          if (widget.confirm) ...[
            const SizedBox(height: 8),
            TextField(controller: _again, obscureText: _hide, decoration: InputDecoration(labelText: l10n.patientBackupPassphraseAgain)),
          ],
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}
