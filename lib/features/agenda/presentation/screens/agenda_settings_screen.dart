import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/agenda_providers.dart';
import '../../data/models/agenda_settings.dart';

/// Api\V2\MealTimeController + Api\V2\ReminderPreferenceController — two
/// small preference forms that configure how Agenda schedules and reminds,
/// reached from AgendaScreen's app bar rather than the drawer (they aren't a
/// destination on their own, just Agenda's settings).
class AgendaSettingsScreen extends StatelessWidget {
  const AgendaSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.agendaSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [_MealTimesSection(), SizedBox(height: 24), _ReminderPreferencesSection()],
      ),
    );
  }
}

String _formatMinutes(AppLocalizations l10n, int minutes) {
  if (minutes % 1440 == 0 && minutes >= 1440) return l10n.durationDays(minutes ~/ 1440);
  if (minutes % 60 == 0 && minutes >= 60) return l10n.durationHours(minutes ~/ 60);
  return l10n.durationMinutes(minutes);
}

/// Wraps the picked value so a tap-outside dismiss (which also resolves the
/// sheet's Future with `null`) can never be confused with the user
/// deliberately picking the "off"/`null` duration option.
class _DurationPick {
  final int? value;
  const _DurationPick(this.value);
}

Future<int?> _pickDuration(
  BuildContext context, {
  required String title,
  required List<int?> options,
  required String Function(int?) label,
  required int? selected,
}) async {
  final result = await showModalBottomSheet<_DurationPick>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    RadioListTile<int?>(
                      value: option,
                      groupValue: selected,
                      title: Text(label(option)),
                      onChanged: (v) => Navigator.of(sheetContext).pop(_DurationPick(v)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result == null ? selected : result.value;
}

class _MealTimesSection extends ConsumerWidget {
  const _MealTimesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(mealTimesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.agendaSettingsMealTimesSection, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.agendaSettingsMealTimesHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Column(
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(mealTimesProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
              data: (mealTimes) => _MealTimesForm(initial: mealTimes),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTimesForm extends ConsumerStatefulWidget {
  final MealTimes initial;
  const _MealTimesForm({required this.initial});

  @override
  ConsumerState<_MealTimesForm> createState() => _MealTimesFormState();
}

class _MealTimesFormState extends ConsumerState<_MealTimesForm> {
  late TimeOfDay _breakfast = _parse(widget.initial.breakfastAt);
  late TimeOfDay _lunch = _parse(widget.initial.lunchAt);
  late TimeOfDay _dinner = _parse(widget.initial.dinnerAt);
  bool _saving = false;

  TimeOfDay _parse(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _serialize(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref
          .read(agendaApiProvider)
          .updateMealTimes(
            breakfastAt: _serialize(_breakfast),
            lunchAt: _serialize(_lunch),
            dinnerAt: _serialize(_dinner),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.agendaSettingsMealTimesSaved)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.agendaSettingsBreakfast),
          trailing: Text(_breakfast.format(context)),
          onTap: () => _pickTime(_breakfast, (v) => setState(() => _breakfast = v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.agendaSettingsLunch),
          trailing: Text(_lunch.format(context)),
          onTap: () => _pickTime(_lunch, (v) => setState(() => _lunch = v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.agendaSettingsDinner),
          trailing: Text(_dinner.format(context)),
          onTap: () => _pickTime(_dinner, (v) => setState(() => _dinner = v)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.commonSave),
          ),
        ),
      ],
    );
  }
}

const _firstLeadOptions = [30, 60, 120, 360, 720, 1440, 2880, 4320, 10080];
const _secondLeadOptions = <int?>[null, 15, 30, 60, 120, 360, 720, 1440];
const _agendaLeadOptions = <int?>[0, 5, 15, 30, 60, 120, 360, 720, 1440];

class _ReminderPreferencesSection extends ConsumerWidget {
  const _ReminderPreferencesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(reminderPreferencesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.agendaSettingsRemindersSection, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.agendaSettingsRemindersHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Column(
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(reminderPreferencesProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
              data: (prefs) => _ReminderPreferencesForm(initial: prefs),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderPreferencesForm extends ConsumerStatefulWidget {
  final ReminderPreferences initial;
  const _ReminderPreferencesForm({required this.initial});

  @override
  ConsumerState<_ReminderPreferencesForm> createState() => _ReminderPreferencesFormState();
}

class _ReminderPreferencesFormState extends ConsumerState<_ReminderPreferencesForm> {
  late int _firstLead = widget.initial.appointmentFirstLeadMinutes;
  late int? _secondLead = widget.initial.appointmentSecondLeadMinutes;
  late int _agendaLead = widget.initial.agendaLeadMinutes;
  bool _saving = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_secondLead != null && _secondLead! >= _firstLead) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.agendaSettingsSecondLeadError)));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(agendaApiProvider)
          .updateReminderPreferences(
            appointmentFirstLeadMinutes: _firstLead,
            appointmentSecondLeadMinutes: _secondLead,
            agendaLeadMinutes: _agendaLead,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.agendaSettingsRemindersSaved)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.agendaSettingsFirstLead),
          trailing: Text(_formatMinutes(l10n, _firstLead)),
          onTap: () async {
            final picked = await _pickDuration(
              context,
              title: l10n.agendaSettingsFirstLead,
              options: _firstLeadOptions,
              label: (v) => _formatMinutes(l10n, v!),
              selected: _firstLead,
            );
            setState(() => _firstLead = picked!);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.agendaSettingsSecondLead),
          trailing: Text(_secondLead == null ? l10n.agendaSettingsSecondLeadNone : _formatMinutes(l10n, _secondLead!)),
          onTap: () async {
            final picked = await _pickDuration(
              context,
              title: l10n.agendaSettingsSecondLead,
              options: _secondLeadOptions,
              label: (v) => v == null ? l10n.agendaSettingsSecondLeadNone : _formatMinutes(l10n, v),
              selected: _secondLead,
            );
            setState(() => _secondLead = picked);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.agendaSettingsAgendaLead),
          trailing: Text(_agendaLead == 0 ? l10n.agendaSettingsAgendaLeadNone : _formatMinutes(l10n, _agendaLead)),
          onTap: () async {
            final picked = await _pickDuration(
              context,
              title: l10n.agendaSettingsAgendaLead,
              options: _agendaLeadOptions,
              label: (v) => v == 0 ? l10n.agendaSettingsAgendaLeadNone : _formatMinutes(l10n, v!),
              selected: _agendaLead,
            );
            setState(() => _agendaLead = picked!);
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.commonSave),
          ),
        ),
      ],
    );
  }
}
