import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/time/clock_format.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/booking_settings_models.dart';

/// «ساعات العمل» — المالك، 2026-10-13: the week's opening hours belong to the BUSINESS (every account has them: a
/// shop, a clinic, a restaurant), not to bookings alone, so they are edited from the business settings and not from
/// «إدارة الحجز». The same GET/PUT /business/working-hours as before.
///
/// «مفتوح 24 ساعة» is one tap for every open day; a day that is open all day reads that way and one tap on it takes it
/// back to a day whose hours are picked again.
class WorkingHoursScreen extends ConsumerStatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  ConsumerState<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends ConsumerState<WorkingHoursScreen> {
  List<WorkingDay>? _days;
  bool _saving = false;
  String? _bulkOpen;
  String? _bulkClose;

  static const _dayOrder = [0, 1, 2, 3, 4, 5, 6];

  String _dayName(AppLocalizations l10n, int day) {
    switch (day) {
      case 0:
        return l10n.weekdaySunday;
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      default:
        return l10n.weekdaySaturday;
    }
  }

  Future<void> _pickTime(int index, {required bool isOpen}) async {
    final current = _days![index];
    final initial = ClockFormat.parse(isOpen ? current.open : current.close) ?? EgyptTime.timeOfDay();
    final picked = await ClockFormat.pick(context, initial: initial);
    if (picked == null) return;
    final formatted = ClockFormat.wire(picked);
    setState(() {
      _days![index] = isOpen ? current.copyWith(open: formatted) : current.copyWith(close: formatted);
    });
  }

  Future<void> _pickBulkTime({required bool isOpen}) async {
    final picked = await ClockFormat.pick(
      context,
      initial: ClockFormat.parse(isOpen ? _bulkOpen : _bulkClose) ?? EgyptTime.timeOfDay(),
    );
    if (picked == null) return;
    final formatted = ClockFormat.wire(picked);
    setState(() {
      if (isOpen) {
        _bulkOpen = formatted;
      } else {
        _bulkClose = formatted;
      }
    });
  }

  /// Fills every day's open/close with the same pair — it doesn't save by itself and it doesn't touch a day's closed
  /// switch, so a day already marked off stays off even after this runs. Mirrors the web business panel's
  /// «طبّق على الأسبوع» shortcut.
  void _applyToWeek() {
    if (_bulkOpen == null && _bulkClose == null) return;
    setState(() {
      _days = [
        for (final day in _days!)
          day.isClosed == true
              ? day
              : day.copyWith(open: _bulkOpen ?? day.open, close: _bulkClose ?? day.close, is24h: false),
      ];
    });
  }

  /// «مفتوح 24 ساعة» for every day that is not marked closed. Fills the list only; saving is the button below.
  void _openAllDay() {
    setState(() {
      _days = [for (final day in _days!) day.isClosed == true ? day : day.allDay()];
    });
  }

  Future<void> _save() async {
    final days = _days;
    if (days == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(bookingSettingsControllerProvider.notifier).saveHours(days);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.bookingSettingsHoursSaved)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(bookingSettingsControllerProvider);

    Widget body;
    if (state.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.hours == null) {
      body = Center(child: Text(l10n.commonSomethingWentWrong));
    } else {
      _days ??= [
        for (final day in _dayOrder) state.hours!.days.firstWhere((d) => d.day == day, orElse: () => WorkingDay(day: day)),
      ];
      final openNow = state.hours!.isOpenNow;
      final statusColor = openNow ? AppColors.success : AppColors.error;

      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    openNow ? l10n.bookingSettingsOpenNow : l10n.bookingSettingsClosedNow,
                    style: theme.textTheme.labelMedium?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.softShadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.bookingSettingsApplyAllLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickBulkTime(isOpen: true),
                        child: Text(
                          _bulkOpen == null ? l10n.bookingSettingsOpenTime : ClockFormat.hhmm(context, _bulkOpen),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickBulkTime(isOpen: false),
                        child: Text(
                          _bulkClose == null ? l10n.bookingSettingsCloseTime : ClockFormat.hhmm(context, _bulkClose),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: (_bulkOpen == null && _bulkClose == null) ? null : _applyToWeek,
                  child: Text(l10n.bookingSettingsApplyToWeek),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _openAllDay,
                  icon: const Icon(Icons.all_inclusive),
                  label: Text(l10n.workingHoursOpen24),
                ),
                const SizedBox(height: 6),
                Text(l10n.bookingSettingsApplyHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.softShadow(),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < _days!.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(_dayName(l10n, _days![i].day), style: theme.textTheme.titleSmall)),
                        if (_days![i].isClosed == true)
                          Text(l10n.bookingSettingsClosed, style: TextStyle(color: theme.hintColor))
                        else if (_days![i].is24h)
                          TextButton.icon(
                            // one tap takes the day back to hours that are picked again
                            onPressed: () => setState(() => _days![i] = _days![i].copyWith(is24h: false, clearTimes: true)),
                            icon: const Icon(Icons.all_inclusive, size: 18),
                            label: Text(l10n.workingHoursOpen24),
                          )
                        else ...[
                          TextButton(
                            onPressed: () => _pickTime(i, isOpen: true),
                            child: Text(
                              _days![i].open == null ? l10n.bookingSettingsOpenTime : ClockFormat.hhmm(context, _days![i].open),
                            ),
                          ),
                          Text(' — ', style: TextStyle(color: theme.hintColor)),
                          TextButton(
                            onPressed: () => _pickTime(i, isOpen: false),
                            child: Text(
                              _days![i].close == null ? l10n.bookingSettingsCloseTime : ClockFormat.hhmm(context, _days![i].close),
                            ),
                          ),
                        ],
                        Switch(
                          value: _days![i].isClosed != true,
                          onChanged: (value) => setState(() {
                            _days![i] = value
                                ? _days![i].copyWith(isClosed: false)
                                : _days![i].copyWith(isClosed: true, is24h: false, clearTimes: true);
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.bookingSettingsSaveHours),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workingHoursTitle)),
      body: body,
    );
  }
}
