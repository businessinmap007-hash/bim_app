import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/schedules_providers.dart';
import '../../data/models/trip_schedule.dart';
import 'run_detail_screen.dart';

/// Start a live run of a leg — a passenger/limousine leg asks for the actual
/// headcount, a freight/distribution leg asks for the cargo manifest
/// (label + quantity per line, typed in manually — not tied to Order
/// records, see TripRunService). Pushes straight into RunDetailScreen once
/// started.
class StartRunScreen extends ConsumerStatefulWidget {
  final TripSchedule schedule;
  const StartRunScreen({super.key, required this.schedule});

  @override
  ConsumerState<StartRunScreen> createState() => _StartRunScreenState();
}

class _ManifestRow {
  final labelCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();

  void dispose() {
    labelCtrl.dispose();
    unitCtrl.dispose();
    qtyCtrl.dispose();
  }
}

class _StartRunScreenState extends ConsumerState<StartRunScreen> {
  final _passengerCountCtrl = TextEditingController();
  final List<_ManifestRow> _manifestRows = [_ManifestRow()];
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _passengerCountCtrl.dispose();
    for (final row in _manifestRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context)!;
    final schedule = widget.schedule;

    if (schedule.stops.isEmpty) {
      setState(() => _error = l10n.tripRunStartRequiresStops);
      return;
    }

    int? passengerCount;
    final manifest = <Map<String, dynamic>>[];

    if (schedule.isPassengerMode) {
      passengerCount = int.tryParse(_passengerCountCtrl.text.trim());
      if (passengerCount == null || passengerCount < 1) {
        setState(() => _error = l10n.tripRunPassengerCountRequired);
        return;
      }
    } else if (schedule.isFreightMode) {
      for (final row in _manifestRows) {
        final label = row.labelCtrl.text.trim();
        if (label.isEmpty) continue;
        final qty = int.tryParse(row.qtyCtrl.text.trim());
        if (qty == null || qty < 1) {
          setState(() => _error = l10n.tripRunManifestQtyRequired);
          return;
        }
        manifest.add({
          'label': label,
          'unit': row.unitCtrl.text.trim().isEmpty ? null : row.unitCtrl.text.trim(),
          'assigned_qty': qty,
        });
      }
      if (manifest.isEmpty) {
        setState(() => _error = l10n.tripRunManifestRequired);
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final run = await ref
          .read(schedulesApiProvider)
          .startRun(schedule.id, passengerCount: passengerCount, manifest: manifest);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RunDetailScreen(runId: run.id)));
      }
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final schedule = widget.schedule;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripRunStartTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${schedule.originGovernorate ?? '—'} → ${schedule.destinationGovernorate ?? '—'}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              schedule.stops.map((s) => s.label).join(' ← '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 20),
            if (schedule.isPassengerMode)
              TextField(
                controller: _passengerCountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.tripRunPassengerCountLabel),
              ),
            if (schedule.isFreightMode) ...[
              Text(l10n.tripRunManifestTitle, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              for (final row in _manifestRows) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: row.labelCtrl,
                        decoration: InputDecoration(labelText: l10n.tripRunManifestItemLabel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: row.unitCtrl,
                        decoration: InputDecoration(labelText: l10n.tripRunManifestItemUnit),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: row.qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.tripRunManifestItemQty),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _manifestRows.length == 1
                          ? null
                          : () => setState(() {
                              row.dispose();
                              _manifestRows.remove(row);
                            }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () => setState(() => _manifestRows.add(_ManifestRow())),
                icon: const Icon(Icons.add),
                label: Text(l10n.tripRunAddManifestItem),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _start,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.tripRunStartAction),
            ),
          ],
        ),
      ),
    );
  }
}
