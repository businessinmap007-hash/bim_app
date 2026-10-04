import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/medical_file_providers.dart';
import '../../data/medical_file.dart';
import '../medical_labels.dart';
import '../widgets/medical_backup_section.dart';
import 'medical_scan_screen.dart';
import 'prescription_archive_screen.dart';
import 'medical_share_screen.dart';

/// «ملفي الطبي» — المالك، 2026-10-05: «التاريخ المرضى يحفظ على الفون وعند مشاركته يقرأ ويعرض للطبيب او
/// الصيدلى». Everything here is saved on this phone only, at once, as it is typed; «مشاركة» shows it to a
/// doctor or a pharmacist for a few minutes, encrypted; «قراءة ملف مريض» is the other side of that.
class MedicalFileScreen extends ConsumerWidget {
  const MedicalFileScreen({super.key});

  Future<void> _addEntry(BuildContext context, WidgetRef ref, MedicalFile file, MedicalSection section) async {
    final entry = await showDialog<MedicalEntry>(context: context, builder: (_) => _EntryDialog(title: medicalSectionLabel(AppLocalizations.of(context)!, section)));
    if (entry == null) return;
    await ref.read(medicalFileControllerProvider.notifier).save(file.withEntries(section, [...file.entries(section), entry]));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(medicalFileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicalFileTitle),
        actions: [
          IconButton(
            tooltip: l10n.medicalScan,
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MedicalScanScreen())),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (file) {
          final controller = ref.read(medicalFileControllerProvider.notifier);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.medicalFileLocalNote, style: theme.textTheme.bodySmall)),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(l10n.rxArchiveOpen),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrescriptionArchiveScreen())),
                ),
              ),
              const SizedBox(height: 12),
              MedicalBackupSection(file: file),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: file.bloodType,
                decoration: InputDecoration(labelText: l10n.medicalBloodType),
                items: [
                  DropdownMenuItem(value: '', child: Text(l10n.medicalBloodUnknown)),
                  for (final t in MedicalFile.bloodTypes) DropdownMenuItem(value: t, child: Directionality(textDirection: TextDirection.ltr, child: Text(t))),
                ],
                onChanged: (v) => controller.save(file.copyWith(bloodType: v ?? '')),
              ),
              for (final section in MedicalSection.values) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(medicalSectionLabel(l10n, section), style: theme.textTheme.titleSmall),
                    TextButton.icon(
                      onPressed: () => _addEntry(context, ref, file, section),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.medicalAdd),
                    ),
                  ],
                ),
                if (file.entries(section).isEmpty)
                  Text(l10n.medicalEmptySection, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))
                else
                  for (final (i, entry) in file.entries(section).indexed)
                    Card(
                      margin: const EdgeInsets.only(top: 6),
                      child: ListTile(
                        title: Text(entry.title),
                        subtitle: entry.detail.isEmpty ? null : Text(entry.detail),
                        trailing: IconButton(
                          tooltip: l10n.commonDelete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.save(file.withEntries(section, [...file.entries(section)]..removeAt(i))),
                        ),
                      ),
                    ),
              ],
              const SizedBox(height: 20),
              _NotesField(initial: file.notes, label: l10n.medicalNotes, onChanged: (text) => controller.save(file.copyWith(notes: text))),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (file) => SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: FilledButton.icon(
            onPressed: () => file.isEmpty
                ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicalShareNothing)))
                : Navigator.of(context).push(MaterialPageRoute(builder: (_) => MedicalShareScreen(file: file))),
            icon: const Icon(Icons.qr_code_2),
            label: Text(l10n.medicalShare),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

/// Notes are saved as they are typed — kept in a field of its own so a rebuild does not move the cursor.
class _NotesField extends StatefulWidget {
  final String initial;
  final String label;
  final ValueChanged<String> onChanged;
  const _NotesField({required this.initial, required this.label, required this.onChanged});

  @override
  State<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<_NotesField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    maxLines: 4,
    decoration: InputDecoration(labelText: widget.label),
    onChanged: widget.onChanged,
  );
}

class _EntryDialog extends StatefulWidget {
  final String title;
  const _EntryDialog({required this.title});

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  final _name = TextEditingController();
  final _detail = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name, autofocus: true, decoration: InputDecoration(labelText: l10n.medicalEntryTitle)),
          const SizedBox(height: 12),
          TextField(controller: _detail, decoration: InputDecoration(labelText: l10n.medicalEntryDetail)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            Navigator.pop(context, MedicalEntry(title: _name.text.trim(), detail: _detail.text.trim()));
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
