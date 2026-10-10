import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../medical_file/data/medical_file.dart';
import '../../../medical_file/presentation/screens/medical_share_screen.dart';
import '../../application/patient_records_providers.dart';
import '../../data/patient_record.dart';

String recordKindLabel(AppLocalizations l10n, RecordKind kind) => switch (kind) {
  RecordKind.visit => l10n.recordKindVisit,
  RecordKind.test => l10n.recordKindTest,
  RecordKind.radiology => l10n.recordKindRadiology,
  RecordKind.medicine => l10n.recordKindMedicine,
  RecordKind.note => l10n.recordKindNote,
};

IconData recordKindIcon(RecordKind kind) => switch (kind) {
  RecordKind.visit => Icons.event_note_outlined,
  RecordKind.test => Icons.biotech_outlined,
  RecordKind.radiology => Icons.medical_information_outlined,
  RecordKind.medicine => Icons.medication_outlined,
  RecordKind.note => Icons.sticky_note_2_outlined,
};

/// A patient's file as the clinic keeps it, on this device: who, what they live with, and every visit, test, scan and
/// medicine — newest first. The doctor adds to it, and hands the patient a copy for their own phone.
class PatientFileScreen extends ConsumerWidget {
  final String recordId;
  const PatientFileScreen({super.key, required this.recordId});

  Future<void> _addEntry(BuildContext context, WidgetRef ref, PatientRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    var kind = RecordKind.visit;
    var date = DateTime.now();
    final title = TextEditingController();
    final detail = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.patientFileAddEntry, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final k in RecordKind.values)
                        ChoiceChip(label: Text(recordKindLabel(l10n, k)), selected: kind == k, onSelected: (_) => setSheet(() => kind = k)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event_outlined),
                    label: Text(DateFormat.yMMMEd(Localizations.localeOf(context).toString()).format(date)),
                    onPressed: () async {
                      final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(1990), lastDate: DateTime.now().add(const Duration(days: 1)));
                      if (d != null) setSheet(() => date = d);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: title, decoration: InputDecoration(labelText: l10n.patientFileEntryTitle)),
                  const SizedBox(height: 8),
                  TextField(controller: detail, minLines: 2, maxLines: 5, decoration: InputDecoration(labelText: l10n.patientFileEntryDetail, alignLabelWithHint: true)),
                  const SizedBox(height: 14),
                  FilledButton(onPressed: () => Navigator.of(sheetContext).pop(true), child: Text(l10n.patientFileAddEntry)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final t = title.text.trim();
    final d = detail.text.trim();
    title.dispose();
    detail.dispose();
    if (ok != true || t.isEmpty) return;

    final entry = RecordEntry(id: newRecordId(), date: DateTime(date.year, date.month, date.day), kind: kind, title: t, detail: d);
    await ref.read(patientRecordsProvider.notifier).save(record.copyWith(entries: [...record.entries, entry]));
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, PatientRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    final c = {
      'name': TextEditingController(text: record.name),
      'phone': TextEditingController(text: record.phone),
      'chronic': TextEditingController(text: record.chronic),
      'allergies': TextEditingController(text: record.allergies),
      'notes': TextEditingController(text: record.notes),
    };

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.patientFileEdit),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: c['name'], decoration: InputDecoration(labelText: l10n.patientFileName)),
              const SizedBox(height: 8),
              TextField(controller: c['phone'], keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.patientFilePhone)),
              const SizedBox(height: 8),
              TextField(controller: c['chronic'], decoration: InputDecoration(labelText: l10n.patientFileChronic)),
              const SizedBox(height: 8),
              TextField(controller: c['allergies'], decoration: InputDecoration(labelText: l10n.patientFileAllergies)),
              const SizedBox(height: 8),
              TextField(controller: c['notes'], minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: l10n.patientFileNotes)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.commonSave)),
        ],
      ),
    );

    final v = {for (final e in c.entries) e.key: e.value.text.trim()};
    for (final x in c.values) {
      x.dispose();
    }
    if (ok != true || (v['name'] ?? '').isEmpty) return;

    await ref.read(patientRecordsProvider.notifier).save(
      record.copyWith(name: v['name'], phone: v['phone'], chronic: v['chronic'], allergies: v['allergies'], notes: v['notes']),
    );
  }

  /// The patient's copy: their conditions, allergies and the whole history, as a medical file the patient can scan
  /// into their own phone (ticking what to include, exactly like the patient's own share).
  MedicalFile _asMedicalFile(AppLocalizations l10n, PatientRecord r) {
    List<MedicalEntry> split(String text) =>
        [for (final p in text.split(RegExp(r'[،,;\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty)) MedicalEntry(title: p)];

    return MedicalFile(
      sections: {
        MedicalSection.conditions: split(r.chronic),
        MedicalSection.allergies: split(r.allergies),
        MedicalSection.records: [
          for (final e in r.entriesNewestFirst)
            MedicalEntry(
              title: [if (e.date != null) e.date!.toIso8601String().substring(0, 10), '${recordKindLabel(l10n, e.kind)}: ${e.title}'].join(' · '),
              detail: e.detail,
            ),
        ],
      },
      notes: r.notes,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final record = ref.watch(patientRecordsProvider).valueOrNull?.where((r) => r.id == recordId).firstOrNull;

    if (record == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.patientFilesEmpty)));

    return Scaffold(
      appBar: AppBar(
        title: Text(record.name),
        actions: [
          IconButton(tooltip: l10n.patientFileEdit, icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, ref, record)),
          IconButton(
            tooltip: l10n.patientFileDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final ok = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: Text(l10n.patientFileDeleteConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
                    FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.commonDelete)),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(patientRecordsProvider.notifier).remove(record.id);
                navigator.pop();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEntry(context, ref, record),
        icon: const Icon(Icons.add),
        label: Text(l10n.patientFileAddEntry),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (record.phone.isNotEmpty) Text(record.phone, style: theme.textTheme.titleSmall),
                  if (record.nationalId.isNotEmpty) Text('${l10n.patientFileNationalId}: ${record.nationalId}'),
                  if (record.birthDate != null) Text('${l10n.patientFileBirth}: ${DateFormat.yMMMd(locale).format(record.birthDate!)}'),
                  if (record.gender.isNotEmpty) Text('${l10n.patientFileGender}: ${record.gender}'),
                  if (record.chronic.isNotEmpty) ...[const SizedBox(height: 6), Text('${l10n.patientFileChronic}: ${record.chronic}')],
                  if (record.allergies.isNotEmpty) Text('${l10n.patientFileAllergies}: ${record.allergies}'),
                  if (record.notes.isNotEmpty) ...[const SizedBox(height: 6), Text(record.notes, style: theme.textTheme.bodySmall)],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_2_outlined),
            label: Text(l10n.patientFileSendCopy),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MedicalShareScreen(file: _asMedicalFile(l10n, record), asCopy: true)),
            ),
          ),
          const SizedBox(height: 16),
          if (record.entries.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.patientFileNoEntries)))
          else
            for (final e in record.entriesNewestFirst)
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(recordKindIcon(e.kind)),
                  title: Text(e.title),
                  subtitle: Text([recordKindLabel(l10n, e.kind), if (e.date != null) DateFormat.yMMMd(locale).format(e.date!), if (e.detail.isNotEmpty) e.detail].join(' · ')),
                  trailing: IconButton(
                    tooltip: l10n.commonDelete,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => ref.read(patientRecordsProvider.notifier).save(record.copyWith(entries: [...record.entries.where((x) => x.id != e.id)])),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
