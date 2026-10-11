import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/application/business_page_providers.dart';
import '../../../business/data/models/offering_item.dart';
import '../../application/booking_providers.dart';
import '../../data/models/unit_discovery.dart';
import '../screens/booking_screen.dart';
import 'booking_grid_widgets.dart';
import 'booking_shape_tab.dart';

/// «موعد»: an appointment with the business itself (a salon, a craftsman) — the service and how long it takes, a
/// day, a start time (the held ones greyed), then «تأكيد الموعد». No units, no photos, no add-ons.
///
/// A business that has written no bookable service gets [fallback], the page it always had.
class AppointmentBoardTab extends ConsumerStatefulWidget {
  final int businessId;
  final UnitShape shape;
  final Widget fallback;

  const AppointmentBoardTab({super.key, required this.businessId, required this.shape, required this.fallback});

  @override
  ConsumerState<AppointmentBoardTab> createState() => _AppointmentBoardTabState();
}

class _AppointmentBoardTabState extends ConsumerState<AppointmentBoardTab> {
  late DateTime _day;
  int? _offeringId;
  DateTime? _slot;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final offeringsAsync = ref.watch(businessOfferingsProvider(widget.businessId));

    return offeringsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => widget.fallback,
      data: (all) {
        final services = all.where((o) => o.isBookable).toList();
        if (services.isEmpty) return widget.fallback;

        final chosen = services.firstWhere((o) => o.id == _offeringId, orElse: () => services.first);
        final grid = ref.watch(appointmentGridProvider((businessId: widget.businessId, date: _dateKey(_day), offeringId: chosen.id)));
        final slotData = grid.valueOrNull?.slots.where((s) => s.startsAt == _slot).firstOrNull;

        return BoardScaffold(
          bottom: BookingSummaryBar(
            summary: slotData == null
                ? ''
                : '${chosen.label} — ${DateFormat.MMMEd(locale).add_jm().format(slotData.startsAt)}',
            price: slotData == null ? null : chosen.price,
            label: l10n.bookingConfirmAppointment,
            onPressed: slotData == null
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(
                        businessId: widget.businessId,
                        shape: widget.shape,
                        offering: chosen,
                        initialStartsAt: slotData.startsAt,
                        initialEndsAt: slotData.endsAt,
                      ),
                    ),
                  ),
          ),
          children: [
            BookingSectionCard(
              title: l10n.bookingServiceTitle,
              child: Column(
                children: [
                  for (final s in services)
                    _ServiceRow(
                      offering: s,
                      selected: s.id == chosen.id,
                      onTap: () => setState(() {
                        _offeringId = s.id;
                        _slot = null;
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            BookingSectionCard(
              title: l10n.bookingPickDayTitle,
              child: BookingDayStrip(
                selected: _day,
                onPick: (d) => setState(() {
                  _day = d;
                  _slot = null;
                }),
              ),
            ),
            const SizedBox(height: 14),
            BookingSectionCard(
              title: l10n.bookingPickTimeTitle,
              child: grid.when(
                loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                error: (_, _) => Text(l10n.commonSomethingWentWrong),
                data: (g) {
                  if (g.closed) return Text(l10n.bookingClosedDay, style: theme.textTheme.bodyMedium);
                  if (g.slots.isEmpty) return Text(l10n.bookingNoFreeTime, style: theme.textTheme.bodyMedium);

                  return BookingTimeGrid(
                    times: [for (final s in g.slots) (at: s.startsAt, enabled: s.isFree)],
                    selected: _slot,
                    onPick: (t) => setState(() => _slot = t),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final OfferingItem offering;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceRow({required this.offering, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // how long the business said this service takes
    final minutes = offering.durationMinutes ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? cs.secondary : cs.outlineVariant, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20, color: selected ? cs.secondary : theme.hintColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offering.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  if (minutes > 0) Text(l10n.bookingMinutes(minutes), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
            Text(
              '${offering.price.toStringAsFixed(offering.price % 1 == 0 ? 0 : 2)} ${l10n.invCurrency}',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
