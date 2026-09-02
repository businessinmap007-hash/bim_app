import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/application/location_providers.dart';
import '../../../location/data/models/location_models.dart';
import '../../application/schedules_providers.dart';
import '../../data/models/trip_schedule.dart';
import 'my_reservations_screen.dart';

/// Domestic trip-leg search (BIM-x scheduling service): pick an origin and
/// destination governorate, see published legs ranked by carrier trust, and
/// reserve a seat/unit. See Api\V2\TripScheduleController::search.
class TripSearchScreen extends ConsumerStatefulWidget {
  const TripSearchScreen({super.key});

  @override
  ConsumerState<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends ConsumerState<TripSearchScreen> {
  LocationGovernorate? _origin;
  LocationGovernorate? _destination;
  DateTime? _date;
  String? _error;

  Future<void> _pickGovernorate(bool isOrigin) async {
    // Egypt-only today (per LocationApi's own doc comment) — skip the
    // country step and go straight to governorates. The list isn't
    // Egypt-first (it's ~249 countries, presumably alphabetical), so find it
    // by name rather than assuming index 0.
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

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    if (_origin == null || _destination == null) {
      setState(() => _error = l10n.tripSearchFieldsRequired);
      return;
    }
    setState(() => _error = null);
    await ref.read(tripSearchControllerProvider.notifier).search(
      originGovernorateId: _origin!.id,
      destinationGovernorateId: _destination!.id,
      date: _date,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final state = ref.watch(tripSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripSearchTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: l10n.myReservationsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tripDateOptional),
                  trailing: Text(_date != null ? _formatDate(_date!) : '—'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.isLoading ? null : _search,
                  child: state.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.tripSearchAction),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: !state.searched
                ? const SizedBox.shrink()
                : state.error != null
                ? Center(child: Text(l10n.commonSomethingWentWrong))
                : state.results.isEmpty
                ? Center(child: Text(l10n.tripSearchEmpty))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.results.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _TripResultTile(result: state.results[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class _TripResultTile extends ConsumerWidget {
  final TripScheduleResult result;
  const _TripResultTile({required this.result});

  Future<void> _openReserveSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    int units = 1;
    final notesController = TextEditingController();
    bool submitting = false;
    String? error;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tripReserve, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(l10n.tripUnits),
                    const Spacer(),
                    IconButton(
                      onPressed: units > 1 ? () => setSheetState(() => units--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$units'),
                    IconButton(
                      onPressed: () => setSheetState(() => units++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: l10n.tripReservationNotes),
                ),
                if (error != null) ...[
                  const SizedBox(height: 4),
                  Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setSheetState(() => submitting = true);
                          try {
                            await ref.read(schedulesApiProvider).reserve(
                              result.schedule.id,
                              units: units,
                              notes: notesController.text.trim(),
                            );
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop(true);
                          } catch (_) {
                            setSheetState(() {
                              submitting = false;
                              error = AppLocalizations.of(sheetContext)!.commonSomethingWentWrong;
                            });
                          }
                        },
                  child: submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.tripReserve),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tripReserved)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final schedule = result.schedule;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => _openReserveSheet(context, ref),
        leading: CircleAvatar(
          backgroundImage: schedule.businessLogoUrl != null ? NetworkImage(schedule.businessLogoUrl!) : null,
          child: schedule.businessLogoUrl == null ? const Icon(Icons.local_shipping_outlined) : null,
        ),
        title: Text(schedule.businessName ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_modeLabel(schedule.mode, l10n)}${schedule.vehicleLabel != null ? ' · ${schedule.vehicleLabel}' : ''}'),
            if (schedule.departureTime != null) Text(schedule.departureTime!),
            if (result.trust.reviewCount > 0)
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                  const SizedBox(width: 2),
                  Text(result.trust.starsAverage.toStringAsFixed(1)),
                ],
              ),
          ],
        ),
        trailing: schedule.price != null ? Text(schedule.price!.toStringAsFixed(0)) : null,
        isThreeLine: true,
      ),
    );
  }
}

String _modeLabel(String mode, AppLocalizations l10n) => switch (mode) {
  'freight' => l10n.tripModeFreight,
  'passenger' => l10n.tripModePassenger,
  'limousine' => l10n.tripModeLimousine,
  'distribution' => l10n.tripModeDistribution,
  _ => mode,
};
