import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/partnerships_providers.dart';
import '../../data/models/partnership.dart';
import '../widgets/partnership_widgets.dart';

/// The owner gives its partner a quantity of one of its rooms at a contract price (or edits such a grant). The partner prices it
/// itself afterwards, never below this price.
class GrantAllocationScreen extends ConsumerStatefulWidget {
  final int partnershipId;
  final Allocation? editing;

  const GrantAllocationScreen({super.key, required this.partnershipId, this.editing});

  @override
  ConsumerState<GrantAllocationScreen> createState() => _GrantAllocationScreenState();
}

class _GrantAllocationScreenState extends ConsumerState<GrantAllocationScreen> {
  GrantableRoom? _room;
  late final _quantity = TextEditingController(text: widget.editing?.quantityTotal.toString() ?? '1');
  late final _price = TextEditingController(text: widget.editing == null ? '' : widget.editing!.contractPrice.toString());
  late final _minNights = TextEditingController(text: widget.editing?.minNights?.toString() ?? '');
  late final _maxNights = TextEditingController(text: widget.editing?.maxNights?.toString() ?? '');
  late final _release = TextEditingController(text: (widget.editing?.releaseDaysBefore ?? 0) == 0 ? '' : widget.editing!.releaseDaysBefore.toString());
  bool _saving = false;
  DateTimeRange? _stay;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e?.startsAt != null && e?.endsAt != null) _stay = DateTimeRange(start: e!.startsAt!, end: e.endsAt!);
  }

  Future<void> _pickStay() async {
    final today = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 2, today.month, today.day),
      initialDateRange: _stay,
    );
    if (picked != null) setState(() => _stay = picked);
  }

  @override
  void dispose() {
    for (final c in [_quantity, _price, _minNights, _maxNights, _release]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final api = ref.read(partnershipsApiProvider);
    final quantity = int.tryParse(_quantity.text) ?? 0;
    final price = double.tryParse(_price.text.replaceAll(',', '.')) ?? 0;
    final editing = widget.editing;

    if ((editing == null && _room == null) || quantity < 1 || price <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pshGrantIncomplete)));
      return;
    }

    setState(() => _saving = true);
    try {
      final min = int.tryParse(_minNights.text);
      final max = int.tryParse(_maxNights.text);
      final release = int.tryParse(_release.text) ?? 0;

      if (editing == null) {
        await api.grant(widget.partnershipId, unitId: _room!.card.unitId, quantity: quantity, contractPrice: price, minNights: min, maxNights: max, releaseDays: release, from: _stay?.start, to: _stay?.end);
      } else {
        await api.updateAllocation(widget.partnershipId, editing.id, quantity: quantity, contractPrice: price, minNights: min, maxNights: max, releaseDays: release, from: _stay?.start, to: _stay?.end);
      }

      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final editing = widget.editing;
    final rooms = editing == null ? ref.watch(grantableRoomsProvider(widget.partnershipId)) : null;

    return Scaffold(
      appBar: AppBar(title: Text(editing == null ? l10n.pshGrant : l10n.pshEdit)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (editing?.room != null) Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.all(12), child: RoomCardView(room: editing!.room!))),
          if (rooms != null) ...[
            Text(l10n.pshPickRoom, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            rooms.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => OutlinedButton(onPressed: () => ref.invalidate(grantableRoomsProvider(widget.partnershipId)), child: Text(l10n.commonRetry)),
              data: (list) => Column(
                children: [
                  for (final r in list)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      // the chosen room is marked by its border; filling it with the dark container hid its own text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: _room?.card.unitId == r.card.unitId ? BorderSide(color: theme.colorScheme.primary, width: 2.5) : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: r.ungranted <= 0 ? null : () => setState(() => _room = r),
                        child: Opacity(
                          opacity: r.ungranted <= 0 ? 0.5 : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: RoomCardView(room: r.card, footer: Text(l10n.pshUngranted(r.ungranted), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700))),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          // the dates of an allotment are the dates of the STAY: the nights it covers
          InkWell(
            onTap: _pickStay,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.pshStayDates,
                suffixIcon: _stay == null ? const Icon(Icons.date_range) : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _stay = null)),
              ),
              child: Text(_stay == null ? l10n.pshStayAny : '${MaterialLocalizations.of(context).formatShortDate(_stay!.start)} → ${MaterialLocalizations.of(context).formatShortDate(_stay!.end)}'),
            ),
          ),
          const SizedBox(height: 10),
          TextField(controller: _quantity, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.pshQuantity)),
          const SizedBox(height: 10),
          TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.pshContractPrice)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: _minNights, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.pshMinNights))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _maxNights, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.pshMaxNights))),
          ]),
          const SizedBox(height: 10),
          TextField(controller: _release, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.pshReleaseDays, helperText: l10n.pshReleaseHelp)),
          const SizedBox(height: 20),
          FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
        ],
      ),
    );
  }
}
