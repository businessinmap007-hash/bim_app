import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_clinic_providers.dart';
import '../../data/models/business_clinic_slot.dart';

class ClinicSlotsScreen extends ConsumerStatefulWidget {
  const ClinicSlotsScreen({super.key});

  @override
  ConsumerState<ClinicSlotsScreen> createState() => _ClinicSlotsScreenState();
}

class _ClinicSlotsScreenState extends ConsumerState<ClinicSlotsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(clinicSlotsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _delete(BusinessClinicSlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.clinicSlotDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(clinicSlotsControllerProvider.notifier).deleteSlot(slot.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(clinicSlotsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clinicSlotsTab)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _AddSlotsSheet(),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.clinicAddSlots),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(clinicSlotsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.clinicSlotsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(clinicSlotsControllerProvider.notifier).load(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final slot = state.items[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: Text(slot.startsAt != null ? _formatDateTime(slot.startsAt!) : ''),
                      subtitle: Text('${slot.durationMinutes}m${slot.visitKind != null ? ' · ${slot.visitKind}' : ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(slot),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _AddSlotsSheet extends StatefulWidget {
  const _AddSlotsSheet();

  @override
  State<_AddSlotsSheet> createState() => _AddSlotsSheetState();
}

class _AddSlotsSheetState extends State<_AddSlotsSheet> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [Tab(text: l10n.clinicSlotsSpecificTab), Tab(text: l10n.clinicSlotsRecurringTab)],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [_SpecificDatesTab(), _RecurringGridTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecificDatesTab extends ConsumerStatefulWidget {
  const _SpecificDatesTab();

  @override
  ConsumerState<_SpecificDatesTab> createState() => _SpecificDatesTabState();
}

class _SpecificDatesTabState extends ConsumerState<_SpecificDatesTab> {
  final List<DateTime> _queued = [];
  bool _submitting = false;
  String? _error;

  Future<void> _addDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 365)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;
    setState(() => _queued.add(DateTime(date.year, date.month, date.day, time.hour, time.minute)));
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;
    if (_queued.isEmpty) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await ref.read(clinicSlotsControllerProvider.notifier).publishSlots(slots: _queued);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clinicSlotsPublished(result.created, result.skipped))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: _addDate,
            icon: const Icon(Icons.add),
            label: Text(l10n.clinicSlotAddDate),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _queued.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_formatDateTime(_queued[index])),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _queued.removeAt(index)),
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
          ],
          if (_queued.isNotEmpty) Text(l10n.clinicSlotPendingCount(_queued.length)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _queued.isEmpty || _submitting ? null : _publish,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.clinicPublishButton),
          ),
        ],
      ),
    );
  }
}

class _RecurringGridTab extends ConsumerStatefulWidget {
  const _RecurringGridTab();

  @override
  ConsumerState<_RecurringGridTab> createState() => _RecurringGridTabState();
}

class _RecurringGridTabState extends ConsumerState<_RecurringGridTab> {
  final Set<int> _weekdays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  final _intervalController = TextEditingController(text: '30');
  int _weeks = 4;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_weekdays.isEmpty) {
      setState(() => _error = l10n.clinicSelectWeekdaysError);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await ref.read(clinicSlotsControllerProvider.notifier).generateSlots(
            weekdays: _weekdays.toList()..sort(),
            startTime: _fmt(_startTime),
            endTime: _fmt(_endTime),
            intervalMinutes: int.tryParse(_intervalController.text.trim()),
            weeks: _weeks,
          );
      if (mounted) {
        Navigator.of(context).pop();
        final created = (result['created'] as num?)?.toInt() ?? 0;
        final skipped = (result['skipped'] as num?)?.toInt() ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clinicSlotsPublished(created, skipped))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekdayLabels = [
      l10n.clinicWeekday0,
      l10n.clinicWeekday1,
      l10n.clinicWeekday2,
      l10n.clinicWeekday3,
      l10n.clinicWeekday4,
      l10n.clinicWeekday5,
      l10n.clinicWeekday6,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.clinicWeekdaysLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < 7; i++)
                FilterChip(
                  label: Text(weekdayLabels[i]),
                  selected: _weekdays.contains(i),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _weekdays.add(i);
                    } else {
                      _weekdays.remove(i);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.clinicStartTimeHint),
                  subtitle: Text(_startTime.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _startTime);
                    if (picked != null) setState(() => _startTime = picked);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.clinicEndTimeHint),
                  subtitle: Text(_endTime.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _endTime);
                    if (picked != null) setState(() => _endTime = picked);
                  },
                ),
              ),
            ],
          ),
          TextField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.clinicIntervalHint),
          ),
          const SizedBox(height: 12),
          Text(l10n.clinicWeeksHint, style: Theme.of(context).textTheme.bodyMedium),
          Slider(
            value: _weeks.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
            label: '$_weeks',
            onChanged: (v) => setState(() => _weeks = v.round()),
          ),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
          ],
          FilledButton(
            onPressed: _submitting ? null : _generate,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.clinicGenerateButton),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
