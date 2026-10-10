import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../data_import/presentation/screens/import_wizard_screen.dart';
import '../../application/patient_records_providers.dart';
import '../../data/patient_import.dart';
import '../../data/patient_record.dart';
import 'patient_backup_screen.dart';
import 'patient_file_screen.dart';

/// «ملفات المرضى» — the clinic's own patient files, kept on THIS device. Import an old sheet, add a patient by hand,
/// and open a file at once when a patient with a record walks in.
class PatientFilesScreen extends ConsumerStatefulWidget {
  const PatientFilesScreen({super.key});

  @override
  ConsumerState<PatientFilesScreen> createState() => _PatientFilesScreenState();
}

class _PatientFilesScreenState extends ConsumerState<PatientFilesScreen> {
  String _query = '';

  void _import() {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImportWizardScreen(
          title: l10n.patientFilesImport,
          intro: l10n.patientFilesImportIntro,
          memoryKey: 'clinic_patients',
          templateName: 'patients-template.xlsx',
          fields: patientImportFields,
          apply: (grid, mapping) async {
            final result = recordsFromGrid(grid, mapping);
            final outcome = await ref.read(patientRecordsProvider.notifier).importRecords(result.records);

            return ImportSummary(created: outcome.created, merged: outcome.merged, skipped: result.skipped);
          },
        ),
      ),
    );
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.patientFilesAdd),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, autofocus: true, decoration: InputDecoration(labelText: l10n.patientFileName)),
            const SizedBox(height: 8),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.patientFilePhone)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.patientFilesAdd)),
        ],
      ),
    );
    final n = name.text.trim();
    final p = phone.text.trim();
    name.dispose();
    phone.dispose();
    if (ok != true || n.isEmpty || !mounted) return;

    final record = PatientRecord(id: newRecordId(), name: n, phone: p, updatedAt: DateTime.now());
    await ref.read(patientRecordsProvider.notifier).save(record);
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PatientFileScreen(recordId: record.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(patientRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientFilesTitle),
        actions: [
          IconButton(
            tooltip: l10n.patientBackupTitle,
            icon: const Icon(Icons.shield_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PatientBackupScreen())),
          ),
          IconButton(tooltip: l10n.patientFilesImport, icon: const Icon(Icons.upload_file_outlined), onPressed: _import),
          IconButton(tooltip: l10n.patientFilesAdd, icon: const Icon(Icons.person_add_alt_1_outlined), onPressed: _add),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (all) {
          final q = PatientRecord.nameKey(_query);
          final qDigits = PatientRecord.phoneKey(_query);
          final shown = q.isEmpty
              ? all
              : all.where((r) => r.nameNormalized.contains(q) || (qDigits.isNotEmpty && r.phoneNormalized.contains(qDigits))).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 18, color: theme.hintColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.patientFilesDeviceNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))),
                ],
              ),
              const SizedBox(height: 12),
              if (all.isEmpty) ...[
                const SizedBox(height: 40),
                Center(child: Text(l10n.patientFilesEmpty, textAlign: TextAlign.center)),
                const SizedBox(height: 16),
                Center(child: FilledButton.icon(onPressed: _import, icon: const Icon(Icons.upload_file_outlined), label: Text(l10n.patientFilesImport))),
              ] else ...[
                TextField(
                  decoration: InputDecoration(hintText: l10n.patientFilesSearch, prefixIcon: const Icon(Icons.search), isDense: true),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 8),
                Text(l10n.patientFilesCount(all.length), style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                for (final r in shown)
                  Card(
                    margin: const EdgeInsets.only(top: 6),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text(r.name),
                      subtitle: Text([if (r.phone.isNotEmpty) r.phone, l10n.patientFileEntryCount(r.entries.length)].join(' · ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PatientFileScreen(recordId: r.id))),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
