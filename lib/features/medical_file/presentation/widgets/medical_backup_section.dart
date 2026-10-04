import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/medical_file_providers.dart';
import '../../data/medical_backup_crypto.dart';
import '../../data/medical_file.dart';

/// «نسخة احتياطية مشفّرة» — the answer to a lost phone. The file is sealed on THIS phone with a passphrase only
/// the patient knows, and the server keeps the opaque result; restoring on a new phone asks for the same
/// passphrase. The passphrase is kept nowhere, so forgetting it loses the backup — said so in plain words
/// before it is made.
class MedicalBackupSection extends ConsumerStatefulWidget {
  final MedicalFile file;
  const MedicalBackupSection({super.key, required this.file});

  @override
  ConsumerState<MedicalBackupSection> createState() => _MedicalBackupSectionState();
}

class _MedicalBackupSectionState extends ConsumerState<MedicalBackupSection> {
  bool _busy = false;

  void _say(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<String?> _askPassphrase({required bool confirm}) => showDialog<String>(
    context: context,
    builder: (_) => _PassphraseDialog(confirm: confirm),
  );

  Future<void> _backup() async {
    final l10n = AppLocalizations.of(context)!;
    final pass = await _askPassphrase(confirm: true);
    if (pass == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final blob = await MedicalBackupCrypto.seal(widget.file, pass);
      final at = await ref.read(medicalBackupApiProvider).put(blob);
      await ref.read(medicalFileControllerProvider.notifier).markBackedUp(at);
      if (mounted) _say(l10n.medicalBackupDone);
    } catch (e) {
      if (mounted) _say(e is ApiException ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(medicalFileControllerProvider.notifier);
    if (!widget.file.isEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.medicalBackupReplace),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.medicalBackupRestore)),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    final pass = await _askPassphrase(confirm: false);
    if (pass == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final stored = await ref.read(medicalBackupApiProvider).get();
      if (stored == null) {
        if (mounted) _say(l10n.medicalBackupNothing);
        return;
      }
      final file = await MedicalBackupCrypto.open(stored.blob, pass);
      await controller.restore(file, stored.updatedAt);
      if (mounted) _say(l10n.medicalBackupRestored);
    } on ApiException catch (e) {
      if (mounted) _say(e.message);
    } catch (_) {
      // A wrong passphrase and a damaged blob fail the same way: the authentication tag.
      if (mounted) _say(l10n.medicalBackupWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.medicalBackupDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(medicalBackupApiProvider).delete();
      ref.read(medicalFileControllerProvider.notifier).backupAt = null;
      ref.invalidate(medicalFileControllerProvider);
      if (mounted) _say(l10n.medicalBackupDeleted);
    } catch (_) {
      if (mounted) _say(l10n.commonSomethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final backupAt = ref.read(medicalFileControllerProvider.notifier).backupAt;
    final changed = backupAt != null && widget.file.updatedAt != null && widget.file.updatedAt!.isAfter(backupAt);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.cloud_done_outlined, size: 20),
              const SizedBox(width: 8),
              Text(l10n.medicalBackupTitle, style: theme.textTheme.titleSmall),
            ]),
            const SizedBox(height: 8),
            Text(
              backupAt == null ? l10n.medicalBackupNone : l10n.medicalBackupLast(DateFormat.yMMMd().add_Hm().format(backupAt)),
              style: theme.textTheme.bodySmall?.copyWith(color: backupAt == null ? theme.colorScheme.error : null),
            ),
            if (changed) Text(l10n.medicalBackupChanged, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
            if (_busy)
              Row(children: [
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.medicalBackupWorking, style: theme.textTheme.bodySmall)),
              ])
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: widget.file.isEmpty ? null : _backup,
                    icon: const Icon(Icons.backup_outlined, size: 18),
                    label: Text(l10n.medicalBackupNow),
                  ),
                  OutlinedButton.icon(onPressed: _restore, icon: const Icon(Icons.restore, size: 18), label: Text(l10n.medicalBackupRestore)),
                  if (backupAt != null)
                    TextButton.icon(onPressed: _delete, icon: const Icon(Icons.delete_outline, size: 18), label: Text(l10n.medicalBackupDelete)),
                ],
              ),
          ],
        ),
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
  final _pass = TextEditingController();
  final _again = TextEditingController();
  String? _error;
  bool _show = false;

  @override
  void dispose() {
    _pass.dispose();
    _again.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.medicalBackupPassphrase),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.confirm) ...[
              Text(l10n.medicalBackupWarning, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _pass,
              obscureText: !_show,
              autofocus: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.medicalBackupPassphrase,
                suffixIcon: IconButton(icon: Icon(_show ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _show = !_show)),
              ),
            ),
            if (widget.confirm) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _again,
                obscureText: !_show,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.medicalBackupPassphraseAgain),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            if (widget.confirm && _pass.text.length < MedicalBackupCrypto.minPassphraseLength) {
              setState(() => _error = l10n.medicalBackupTooShort);
            } else if (widget.confirm && _pass.text != _again.text) {
              setState(() => _error = l10n.medicalBackupMismatch);
            } else if (_pass.text.isNotEmpty) {
              Navigator.pop(context, _pass.text);
            }
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
