import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/application/location_providers.dart';
import '../../../location/data/models/location_models.dart';
import '../../application/schedules_providers.dart';
import '../../data/models/trip_schedule.dart';
import '../../data/schedules_api.dart';
import 'incoming_reservations_screen.dart';
import 'runs_list_screen.dart';
import 'start_run_screen.dart';

String _modeLabel(String mode, AppLocalizations l10n) => switch (mode) {
  'freight' => l10n.tripModeFreight,
  'passenger' => l10n.tripModePassenger,
  'limousine' => l10n.tripModeLimousine,
  'distribution' => l10n.tripModeDistribution,
  _ => mode,
};

/// Api\V2\TripScheduleController — a carrier's own published trip legs.
/// Domestic (governorate-pair) routes only, matching the app's existing
/// customer-side search; international (country-pair) legs aren't wired up
/// here. Create + delete only — no edit form, since a leg's own reservations
/// reference it directly and a "correct a mistake" case is just as well
/// served by deleting and republishing.
class MyTripSchedulesScreen extends ConsumerWidget {
  const MyTripSchedulesScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, TripSchedule schedule) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.tripScheduleDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(myTripSchedulesControllerProvider.notifier).delete(schedule.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myTripSchedulesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myTripSchedulesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.route_outlined),
            tooltip: l10n.tripRunsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RunsListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.inbox_outlined),
            tooltip: l10n.incomingReservationsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const IncomingReservationsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const _TripScheduleFormScreen()),
          );
          if (created == true) {
            ref.read(myTripSchedulesControllerProvider.notifier).load();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.tripScheduleAdd),
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
                    onPressed: () => ref.read(myTripSchedulesControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.tripSchedulesEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myTripSchedulesControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final schedule = state.items[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(
                        '${schedule.originGovernorate ?? '—'} → ${schedule.destinationGovernorate ?? '—'}',
                      ),
                      subtitle: Text(
                        '${_modeLabel(schedule.mode, l10n)}'
                        '${schedule.vehicleLabel != null ? ' · ${schedule.vehicleLabel}' : ''}'
                        '${schedule.departureTime != null ? ' · ${schedule.departureTime}' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (schedule.price != null) Text(schedule.price!.toStringAsFixed(0)),
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline),
                            tooltip: l10n.tripRunStart,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => StartRunScreen(schedule: schedule)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(context, ref, schedule),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _TripScheduleFormScreen extends ConsumerStatefulWidget {
  const _TripScheduleFormScreen();

  @override
  ConsumerState<_TripScheduleFormScreen> createState() => _TripScheduleFormScreenState();
}

const _modes = ['freight', 'passenger', 'limousine', 'distribution'];
const _patternWeekly = 'weekly';
const _patternOneOff = 'one_off';
const _patternOnDemand = 'on_demand';

class _StopRow {
  final labelCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  int? businessId;
  String? businessName;

  void dispose() {
    labelCtrl.dispose();
    addressCtrl.dispose();
  }
}

class _TripScheduleFormScreenState extends ConsumerState<_TripScheduleFormScreen> {
  String _mode = 'passenger';
  String _pattern = _patternWeekly;
  LocationGovernorate? _origin;
  LocationGovernorate? _destination;
  int _dayOfWeek = 0;
  DateTime? _tripDate;
  final _departureTimeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final List<_StopRow> _stopRows = [_StopRow()];
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _departureTimeCtrl.dispose();
    _capacityCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    for (final row in _stopRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pickGovernorate(bool isOrigin) async {
    final countries = await ref.read(countriesProvider.future);
    if (countries.isEmpty || !mounted) return;
    final egypt = countries.firstWhere((c) => c.nameEn == 'Egypt', orElse: () => countries.first);
    final governorates = await ref.read(governoratesProvider(egypt.id).future);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    final selected = await showModalBottomSheet<LocationGovernorate>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.tripChooseGovernorate, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final gov in governorates)
              ListTile(
                title: Text(gov.localizedName(languageCode)),
                onTap: () => Navigator.of(context).pop(gov),
              ),
          ],
        ),
      ),
    );

    if (selected == null) return;
    setState(() {
      if (isOrigin) {
        _origin = selected;
      } else {
        _destination = selected;
      }
    });
  }

  Future<void> _pickStopBusiness(_StopRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showModalBottomSheet<StopBusinessOption>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BusinessPickerSheet(l10n: l10n),
    );
    if (picked == null || !mounted) return;
    setState(() {
      row.businessId = picked.id;
      row.businessName = picked.name;
      row.labelCtrl.text = picked.name;
    });
  }

  void _clearStopBusiness(_StopRow row) {
    setState(() {
      row.businessId = null;
      row.businessName = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_origin == null || _destination == null) {
      setState(() => _error = l10n.tripSearchFieldsRequired);
      return;
    }
    if (_pattern == _patternOneOff && _tripDate == null) {
      setState(() => _error = l10n.tripScheduleDatePickRequired);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final payload = <String, dynamic>{
      'mode': _mode,
      'scope': 'domestic',
      'origin_governorate_id': _origin!.id,
      'destination_governorate_id': _destination!.id,
      'schedule_pattern': _pattern,
      if (_pattern == _patternWeekly) 'day_of_week': _dayOfWeek,
      if (_pattern == _patternOneOff) 'trip_date': _isoDate(_tripDate!),
      if (_departureTimeCtrl.text.trim().isNotEmpty) 'departure_time': _departureTimeCtrl.text.trim(),
      if (_capacityCtrl.text.trim().isNotEmpty) 'capacity': int.tryParse(_capacityCtrl.text.trim()),
      if (_priceCtrl.text.trim().isNotEmpty) 'price': double.tryParse(_priceCtrl.text.trim()),
      if (_depositCtrl.text.trim().isNotEmpty) 'deposit_per_unit': double.tryParse(_depositCtrl.text.trim()),
      'stops': [
        for (final row in _stopRows)
          if (row.labelCtrl.text.trim().isNotEmpty || row.businessId != null)
            {
              'label': row.labelCtrl.text.trim(),
              'address': row.addressCtrl.text.trim(),
              'business_id': row.businessId,
            },
      ],
    };

    try {
      await ref.read(schedulesApiProvider).createTripSchedule(payload);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dayLabel(AppLocalizations l10n, int day) => switch (day) {
    0 => l10n.weekdaySunday,
    1 => l10n.weekdayMonday,
    2 => l10n.weekdayTuesday,
    3 => l10n.weekdayWednesday,
    4 => l10n.weekdayThursday,
    5 => l10n.weekdayFriday,
    _ => l10n.weekdaySaturday,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripScheduleAddTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tripScheduleModeLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in _modes)
                  ChoiceChip(
                    label: Text(_modeLabel(mode, l10n)),
                    selected: _mode == mode,
                    onSelected: (_) => setState(() => _mode = mode),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickGovernorate(true),
                    child: Text(_origin?.localizedName(languageCode) ?? l10n.tripOrigin),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickGovernorate(false),
                    child: Text(_destination?.localizedName(languageCode) ?? l10n.tripDestination),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.tripSchedulePatternLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.tripSchedulePatternWeekly),
                  selected: _pattern == _patternWeekly,
                  onSelected: (_) => setState(() => _pattern = _patternWeekly),
                ),
                ChoiceChip(
                  label: Text(l10n.tripSchedulePatternOneOff),
                  selected: _pattern == _patternOneOff,
                  onSelected: (_) => setState(() => _pattern = _patternOneOff),
                ),
                ChoiceChip(
                  label: Text(l10n.tripSchedulePatternOnDemand),
                  selected: _pattern == _patternOnDemand,
                  onSelected: (_) => setState(() => _pattern = _patternOnDemand),
                ),
              ],
            ),
            if (_pattern == _patternWeekly) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _dayOfWeek,
                decoration: InputDecoration(labelText: l10n.tripScheduleDayLabel),
                items: [for (var d = 0; d < 7; d++) DropdownMenuItem(value: d, child: Text(_dayLabel(l10n, d)))],
                onChanged: (v) => setState(() => _dayOfWeek = v ?? 0),
              ),
            ],
            if (_pattern == _patternOneOff) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.tripScheduleDateLabel),
                trailing: Text(_tripDate != null ? _isoDate(_tripDate!) : '—'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _tripDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _tripDate = picked);
                },
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _departureTimeCtrl,
              decoration: InputDecoration(labelText: l10n.tripScheduleDepartureTimeLabel, hintText: '08:00'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.tripScheduleCapacityLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.tripSchedulePriceLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _depositCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.tripScheduleDepositLabel),
            ),
            const SizedBox(height: 20),
            Text(l10n.tripScheduleStopsTitle, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              l10n.tripScheduleStopBusinessHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 8),
            for (final row in _stopRows) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: row.labelCtrl,
                      decoration: InputDecoration(labelText: l10n.tripScheduleStopLabel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: row.addressCtrl,
                      enabled: row.businessId == null,
                      decoration: InputDecoration(
                        labelText: l10n.tripScheduleStopAddress,
                        helperText: row.businessId != null ? l10n.tripScheduleStopUsesGps : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _stopRows.length == 1
                        ? null
                        : () => setState(() {
                            row.dispose();
                            _stopRows.remove(row);
                          }),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ActionChip(
                    avatar: Icon(row.businessId != null ? Icons.storefront : Icons.storefront_outlined, size: 18),
                    label: Text(row.businessId != null ? row.businessName ?? '' : l10n.tripScheduleStopPickBusiness),
                    onPressed: () => _pickStopBusiness(row),
                  ),
                  if (row.businessId != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      tooltip: l10n.tripScheduleStopClearBusiness,
                      onPressed: () => _clearStopBusiness(row),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: () => setState(() => _stopRows.add(_StopRow())),
              icon: const Icon(Icons.add),
              label: Text(l10n.tripScheduleAddStop),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search-as-you-type picker for "this stop is a registered business" — its
/// own GPS location then drives the run's Google Maps navigation precisely.
/// Mirrors the web panel's TomSelect remote lookup against the same
/// businessLookup endpoint.
class _BusinessPickerSheet extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  const _BusinessPickerSheet({required this.l10n});

  @override
  ConsumerState<_BusinessPickerSheet> createState() => _BusinessPickerSheetState();
}

class _BusinessPickerSheetState extends ConsumerState<_BusinessPickerSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<StopBusinessOption> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await ref.read(schedulesApiProvider).businessLookup(q);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.tripScheduleStopPickBusinessTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.tripScheduleStopSearchHint,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchCtrl.text.trim().isEmpty
                            ? l10n.tripScheduleStopSearchHint
                            : l10n.tripScheduleStopSearchEmpty,
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final option = _results[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: option.logoUrl != null ? NetworkImage(option.logoUrl!) : null,
                            child: option.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                          ),
                          title: Text(option.name),
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
