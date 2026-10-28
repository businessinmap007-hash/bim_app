import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/clock_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';

/// «مواعيد الوجبات»: breakfast, lunch and dinner, each from … to …. A guest reads, on his booking, the times of the meals his plan
/// gives (breakfast → breakfast; half board → breakfast and dinner; full board and all inclusive → all three).
class MealTimesScreen extends ConsumerStatefulWidget {
  const MealTimesScreen({super.key});

  @override
  ConsumerState<MealTimesScreen> createState() => _MealTimesScreenState();
}

class _MealTimesScreenState extends ConsumerState<MealTimesScreen> {
  static const _meals = ['breakfast', 'lunch', 'dinner'];
  final Map<String, ({String? from, String? to})> _times = {for (final m in _meals) m: (from: null, to: null)};
  bool _loaded = false;
  bool _failed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = await ref.read(bookingSettingsApiProvider).mealTimes();
      if (!mounted) return;
      setState(() {
        if (t != null) _times.addAll(t);
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  String _mealName(AppLocalizations l10n, String meal) => switch (meal) {
    'breakfast' => l10n.mealBreakfast,
    'lunch' => l10n.mealLunch,
    _ => l10n.mealDinner,
  };

  Future<void> _pick(String meal, bool from) async {
    final current = from ? _times[meal]!.from : _times[meal]!.to;
    final parts = (current ?? (from ? '07:00' : '10:00')).split(':');
    final picked = await ClockFormat.pick(context, initial: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _times[meal] = from ? (from: text, to: _times[meal]!.to) : (from: _times[meal]!.from, to: text));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(bookingSettingsApiProvider).saveMealTimes(_times);
      messenger.showSnackBar(SnackBar(content: Text(l10n.mealTimesSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mealTimesTitle)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.mealTimesIntro, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 12),
                for (final meal in _meals)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(children: [
                        Expanded(child: Text(_mealName(l10n, meal), style: theme.textTheme.titleSmall)),
                        TextButton(onPressed: () => _pick(meal, true), child: Text(_times[meal]!.from == null ? l10n.mealFrom : ClockFormat.hhmm(context, _times[meal]!.from))),
                        const Text('—'),
                        TextButton(onPressed: () => _pick(meal, false), child: Text(_times[meal]!.to == null ? l10n.mealTo : ClockFormat.hhmm(context, _times[meal]!.to))),
                        IconButton(
                          tooltip: l10n.commonDelete,
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _times[meal] = (from: null, to: null)),
                        ),
                      ]),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
              ],
            ),
    );
  }
}
