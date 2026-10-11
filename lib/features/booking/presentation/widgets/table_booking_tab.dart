import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/booking_providers.dart';
import '../../data/models/unit_discovery.dart';
import 'booking_grid_widgets.dart';
import 'booking_shape_tab.dart';

/// «طاولة»: a day and a party size, then the time (the taken ones greyed), then the tables that are free at that time
/// and seat the party — one bar, «احجز طاولة».
class TableBookingTab extends ConsumerStatefulWidget {
  final int businessId;
  final UnitCatalog catalog;
  final UnitShape shape;

  const TableBookingTab({super.key, required this.businessId, required this.catalog, required this.shape});

  @override
  ConsumerState<TableBookingTab> createState() => _TableBookingTabState();
}

class _TableBookingTabState extends ConsumerState<TableBookingTab> {
  /// How long a table is held for the grid's «free» judgement — a sitting.
  static const _sittingMinutes = 90;

  late DateTime _day;
  int _party = 2;
  DateTime? _slot;
  int? _unitId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 120)),
    );
    if (picked != null && mounted) {
      setState(() {
        _day = picked;
        _slot = null;
        _unitId = null;
      });
    }
  }

  Future<void> _pickParty() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (var n = 1; n <= 20; n++)
              ListTile(
                title: Text(l10n.bookingPartyPeople(n)),
                selected: n == _party,
                onTap: () => Navigator.of(sheet).pop(n),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _party = picked;
        _slot = null;
        _unitId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final allUnits = [for (final k in widget.catalog.kinds) for (final u in k.units) (group: k, unit: u)];

    final params = (
      businessId: widget.businessId,
      date: _dateKey(_day),
      durationMinutes: _sittingMinutes,
      stepMinutes: 30,
      partySize: _party,
      serviceId: widget.catalog.serviceId,
      itemType: allUnits.isEmpty ? null : allUnits.first.group.itemType,
    );
    final grid = ref.watch(dayGridProvider(params));
    final slotData = grid.valueOrNull?.slots.where((s) => s.startsAt == _slot).firstOrNull;
    final free = slotData == null ? <({UnitKindGroup group, DiscoveredUnit unit})>[] : allUnits.where((e) => slotData.unitIds.contains(e.unit.id)).toList();
    final chosen = free.where((e) => e.unit.id == _unitId).firstOrNull;

    final dayLabel = DateFormat.yMMMEd(locale).format(_day);

    return BoardScaffold(
      bottom: BookingSummaryBar(
        summary: chosen == null || _slot == null
            ? l10n.bookingTableHint
            : '${chosen.unit.displayTitle} — ${DateFormat.MMMEd(locale).add_jm().format(_slot!)} — ${l10n.bookingPartyPeople(_party)}',
        label: l10n.bookingBookTable,
        onPressed: chosen == null || _slot == null
            ? null
            : () => openUnitBooking(
                context,
                businessId: widget.businessId,
                catalog: widget.catalog,
                shape: widget.shape,
                group: chosen.group,
                unit: chosen.unit,
                startsAt: _slot,
                partySize: _party,
              ),
      ),
      children: [
        BookingSectionCard(
          title: l10n.bookingDayTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: BookingValueField(label: l10n.bookingDayTitle, value: dayLabel, onTap: _pickDay)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: BookingValueField(label: l10n.bookingPartySizeLabel, value: l10n.bookingPartyPeople(_party), onTap: _pickParty),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(l10n.bookingTimeTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              grid.when(
                loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                error: (_, _) => Text(l10n.commonSomethingWentWrong),
                data: (g) {
                  if (g.closed) return Text(l10n.bookingClosedDay);
                  if (g.slots.isEmpty) return Text(l10n.bookingNoFreeTime);

                  return BookingTimeGrid(
                    times: [for (final s in g.slots) (at: s.startsAt, enabled: s.isFree)],
                    selected: _slot,
                    onPick: (t) => setState(() {
                      _slot = t;
                      _unitId = null;
                    }),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_slot == null)
          Text(l10n.bookingTableHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))
        else ...[
          Text(
            l10n.bookingTablesAt(DateFormat.jm(locale).format(_slot!)),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < free.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TableRow(
                number: (free[i].unit.code ?? '').isNotEmpty ? free[i].unit.code! : '${i + 1}',
                name: free[i].unit.displayTitle,
                seats: free[i].unit.capacity,
                selected: free[i].unit.id == _unitId,
                onTap: () => setState(() => _unitId = free[i].unit.id),
              ),
            ),
        ],
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final String number;
  final String name;
  final int? seats;
  final bool selected;
  final VoidCallback onTap;

  const _TableRow({required this.number, required this.name, required this.seats, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? cs.secondary : Colors.transparent, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(12)),
                child: Text(number, style: TextStyle(color: cs.onPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    if (seats != null) Text(l10n.bookingSeatsUpTo(seats!), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
