import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/agenda_providers.dart';
import '../../data/models/agenda_item.dart';
import 'agenda_settings_screen.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _date = _dateOnly(DateTime.now());

  void _shiftDay(int delta) {
    setState(() => _date = _date.add(Duration(days: delta)));
  }

  Future<void> _addTask() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay? endTime;
    String? error;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.agendaAddTask, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: l10n.agendaTaskTitle),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.agendaStartTime),
                  trailing: Text(startTime.format(sheetContext)),
                  onTap: () async {
                    final picked = await showTimePicker(context: sheetContext, initialTime: startTime);
                    if (picked != null) setSheetState(() => startTime = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.agendaEndTime),
                  trailing: Text(endTime?.format(sheetContext) ?? '—'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: sheetContext,
                      initialTime: endTime ?? startTime,
                    );
                    if (picked != null) setSheetState(() => endTime = picked);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l10n.agendaTaskNotes),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      setSheetState(() => error = l10n.agendaTitleRequired);
                      return;
                    }
                    Navigator.of(sheetContext).pop(true);
                  },
                  child: Text(l10n.commonSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    final startsAt = DateTime(_date.year, _date.month, _date.day, startTime.hour, startTime.minute);
    final endsAt = endTime != null
        ? DateTime(_date.year, _date.month, _date.day, endTime!.hour, endTime!.minute)
        : null;

    try {
      await ref.read(agendaDayControllerProvider(_date).notifier).addTask(
        title: titleController.text.trim(),
        startsAt: startsAt,
        endsAt: endsAt,
        notes: notesController.text.trim(),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(agendaDayControllerProvider(_date));
    final isToday = _date == _dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.agendaTitle),
        actions: [
          if (!isToday)
            TextButton(
              onPressed: () => setState(() => _date = _dateOnly(DateTime.now())),
              child: Text(l10n.agendaToday, style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor)),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.agendaSettingsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AgendaSettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _shiftDay(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(_formatDate(_date), style: Theme.of(context).textTheme.titleSmall),
                IconButton(
                  onPressed: () => _shiftDay(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(agendaDayControllerProvider(_date).notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.agendaEmpty))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _AgendaTile(item: state.items[index], date: _date),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _AgendaTile extends ConsumerWidget {
  final AgendaItem item;
  final DateTime date;
  const _AgendaTile({required this.item, required this.date});

  IconData get _icon => switch (item.kind) {
    'appointment' => Icons.medical_services_outlined,
    'booking' => Icons.event_available_outlined,
    'medication' => Icons.medication_outlined,
    _ => Icons.task_alt_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(_icon, color: AppColors.accentGold),
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.startsAt != null) Text(_formatTimeRange(item.startsAt!, item.endsAt)),
            if (item.notes != null && item.notes!.isNotEmpty) Text(item.notes!),
          ],
        ),
        isThreeLine: item.notes != null && item.notes!.isNotEmpty,
        trailing: item.isPersonal
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(l10n.agendaDeleteConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.commonCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.commonDelete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    ref.read(agendaDayControllerProvider(date).notifier).delete(item.id);
                  }
                },
              )
            : null,
      ),
    );
  }
}

String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatTimeRange(DateTime start, DateTime? end) {
  final s = start.toLocal();
  final startStr = '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}';
  if (end == null) return startStr;
  final e = end.toLocal();
  final endStr = '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}';
  return '$startStr – $endStr';
}
