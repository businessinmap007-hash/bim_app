import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/agenda_providers.dart';
import '../../data/models/agenda_item.dart';
import 'agenda_settings_screen.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// 0 = Sunday .. 6 = Saturday, the server's weekday numbering.
String _weekdayLabel(AppLocalizations l10n, int d) => switch (d) {
  0 => l10n.clinicWeekday0,
  1 => l10n.clinicWeekday1,
  2 => l10n.clinicWeekday2,
  3 => l10n.clinicWeekday3,
  4 => l10n.clinicWeekday4,
  5 => l10n.clinicWeekday5,
  _ => l10n.clinicWeekday6,
};

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
    var repeat = 'none'; // none | daily | weekly
    final weekdays = <int>{};
    var weeks = 4;
    var remind = false;

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.agendaAddTask,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.agendaTaskTitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.agendaStartTime),
                    trailing: Text(startTime.format(sheetContext)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: sheetContext,
                        initialTime: startTime,
                      );
                      if (picked != null) {
                        setSheetState(() => startTime = picked);
                      }
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
                  const SizedBox(height: 8),
                  Text(
                    l10n.agendaRepeat,
                    style: Theme.of(sheetContext).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 'none',
                        label: Text(l10n.agendaRepeatNone),
                      ),
                      ButtonSegment(
                        value: 'daily',
                        label: Text(l10n.agendaRepeatDaily),
                      ),
                      ButtonSegment(
                        value: 'weekly',
                        label: Text(l10n.agendaRepeatWeekly),
                      ),
                    ],
                    selected: {repeat},
                    onSelectionChanged: (v) =>
                        setSheetState(() => repeat = v.first),
                  ),
                  if (repeat == 'weekly') ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (var d = 0; d < 7; d++)
                          FilterChip(
                            label: Text(_weekdayLabel(l10n, d)),
                            selected: weekdays.contains(d),
                            onSelected: (on) => setSheetState(
                              () => on ? weekdays.add(d) : weekdays.remove(d),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (repeat != 'none') ...[
                    Row(
                      children: [
                        Expanded(child: Text(l10n.agendaRepeatWeeks)),
                        DropdownButton<int>(
                          value: weeks,
                          items: [
                            for (var w = 1; w <= 12; w++)
                              DropdownMenuItem(value: w, child: Text('$w')),
                          ],
                          onChanged: (v) =>
                              setSheetState(() => weeks = v ?? weeks),
                        ),
                      ],
                    ),
                    Text(
                      l10n.agendaRepeatFromToday,
                      style: Theme.of(sheetContext).textTheme.bodySmall
                          ?.copyWith(color: Theme.of(sheetContext).hintColor),
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.agendaRemindMe),
                    value: remind,
                    onChanged: (v) => setSheetState(() => remind = v),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.agendaTaskNotes,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.agendaTitleRequired);
                        return;
                      }
                      if (repeat == 'weekly' && weekdays.isEmpty) {
                        setSheetState(
                          () => error = l10n.agendaWeekdaysRequired,
                        );
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
      ),
    );

    if (confirmed != true) return;

    final startsAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      startTime.hour,
      startTime.minute,
    );
    final endsAt = endTime != null
        ? DateTime(
            _date.year,
            _date.month,
            _date.day,
            endTime!.hour,
            endTime!.minute,
          )
        : null;

    if (repeat != 'none') {
      await _saveRecurring(
        title: titleController.text.trim(),
        start: startTime,
        end: endTime,
        frequency: repeat,
        weekdays: weekdays.toList()..sort(),
        weeks: weeks,
        notes: notesController.text.trim(),
        remind: remind,
      );
      return;
    }

    try {
      await ref
          .read(agendaDayControllerProvider(_date).notifier)
          .addTask(
            title: titleController.text.trim(),
            startsAt: startsAt,
            endsAt: endsAt,
            notes: notesController.text.trim(),
            remind: remind,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.commonSomethingWentWrong,
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveRecurring({
    required String title,
    required TimeOfDay start,
    required TimeOfDay? end,
    required String frequency,
    required List<int> weekdays,
    required int weeks,
    required String notes,
    required bool remind,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end != null
        ? end.hour * 60 + end.minute
        : startMinutes + 30;
    // The server takes a duration, not an end time; an end at or before the
    // start falls back to its own 30-minute default rather than a negative slot.
    final duration = endMinutes > startMinutes ? endMinutes - startMinutes : 30;
    try {
      final result = await ref
          .read(agendaApiProvider)
          .addRecurring(
            title: title,
            startTime:
                '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
            durationMinutes: duration.clamp(5, 480),
            frequency: frequency,
            weekdays: weekdays,
            weeks: weeks,
            notes: notes,
            remind: remind,
          );
      ref.invalidate(agendaDayControllerProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.agendaRecurringResult(result.created, result.skipped),
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.message : l10n.commonSomethingWentWrong,
          ),
        ),
      );
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
              onPressed: () =>
                  setState(() => _date = _dateOnly(DateTime.now())),
              child: Text(
                l10n.agendaToday,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ),
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
                Text(
                  _formatDate(_date),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
                          onPressed: () => ref
                              .read(agendaDayControllerProvider(_date).notifier)
                              .load(),
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
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _AgendaTile(item: state.items[index], date: _date),
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
            if (item.startsAt != null)
              Text(_formatTimeRange(item.startsAt!, item.endsAt)),
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
                    ref
                        .read(agendaDayControllerProvider(date).notifier)
                        .delete(item.id);
                  }
                },
              )
            : null,
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatTimeRange(DateTime start, DateTime? end) {
  final startStr =
      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  if (end == null) return startStr;
  final endStr =
      '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  return '$startStr – $endStr';
}
