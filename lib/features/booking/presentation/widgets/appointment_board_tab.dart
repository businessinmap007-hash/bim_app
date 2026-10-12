import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/application/business_page_providers.dart';
import '../../../business/data/models/offering_item.dart';
import '../../../chairs/application/chairs_providers.dart';
import '../../../chairs/data/models/service_chair.dart';
import '../../../chairs/presentation/widgets/chair_picker.dart';
import '../../application/booking_providers.dart';
import '../../data/models/unit_discovery.dart';
import '../screens/booking_screen.dart';
import 'booking_grid_widgets.dart';
import 'booking_shape_tab.dart';
import '../../../../core/time/egypt_time.dart';

/// «موعد»: an appointment with the business itself (a salon, a craftsman) — the service and how long it takes, a
/// day, a start time (the held ones greyed), then «تأكيد الموعد». No units, no photos, no add-ons.
///
/// A business that has written no bookable service gets [fallback], the page it always had.
class AppointmentBoardTab extends ConsumerStatefulWidget {
  final int businessId;
  final UnitShape shape;
  final Widget fallback;

  /// «بالدور»: the business gives the turn and the time — no grid of times.
  final bool queue;

  const AppointmentBoardTab({super.key, required this.businessId, required this.shape, required this.fallback, this.queue = false});

  @override
  ConsumerState<AppointmentBoardTab> createState() => _AppointmentBoardTabState();
}

class _AppointmentBoardTabState extends ConsumerState<AppointmentBoardTab> {
  late DateTime _day;
  int? _offeringId;
  DateTime? _slot;
  int? _chairId;

  @override
  void initState() {
    super.initState();
    final now = EgyptTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  void _set(VoidCallback change) => setState(change);

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
        if (widget.queue) return _queueBoard(context, l10n, services, chosen);
        final chairs = ref.watch(chairsDiscoveryProvider(widget.businessId)).valueOrNull ?? const <ServiceChair>[];
        final chair = chairs.where((c) => c.id == _chairId).firstOrNull;
        final grid = ref.watch(appointmentGridProvider((businessId: widget.businessId, date: _dateKey(_day), offeringId: chosen.id, chairId: _chairId)));
        final slotData = grid.valueOrNull?.slots.where((s) => s.startsAt == _slot).firstOrNull;

        return BoardScaffold(
          bottom: BookingSummaryBar(
            summary: slotData == null ? '' : chosen.label,
            when: slotData == null ? null : DateFormat.MMMEd(locale).add_jm().format(slotData.startsAt),
            price: slotData == null ? null : chosen.price,
            label: l10n.bookingConfirmAppointment,
            onPressed: slotData == null
                ? null
                : () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          businessId: widget.businessId,
                          shape: widget.shape,
                          offering: chosen,
                          initialStartsAt: slotData.startsAt,
                          initialEndsAt: slotData.endsAt,
                          chair: chair,
                        ),
                      ),
                    );
                    // the time just booked is taken now
                    ref.invalidate(appointmentGridProvider);
                  },
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
            if (chairs.isNotEmpty) ...[
              const SizedBox(height: 14),
              BookingSectionCard(
                title: l10n.chairPickTitle,
                child: ChairPicker(
                  chairs: chairs,
                  selected: _chairId,
                  onPick: (id) => setState(() {
                    _chairId = id;
                    _slot = null;
                  }),
                ),
              ),
            ],
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

extension on _AppointmentBoardTabState {
  /// «بالدور»: the service, the day, then the turn this customer would get and when it should come.
  Widget _queueBoard(BuildContext context, AppLocalizations l10n, List<OfferingItem> services, OfferingItem chosen) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final chairs = ref.watch(chairsDiscoveryProvider(widget.businessId)).valueOrNull ?? const <ServiceChair>[];
    final chair = chairs.where((c) => c.id == _chairId).firstOrNull;
    final preview = ref.watch(appointmentQueueProvider((businessId: widget.businessId, date: _dateKey(_day), offeringId: chosen.id, chairId: _chairId)));
    final p = preview.valueOrNull;
    final canTake = p != null && !p.full && !p.closed;

    return BoardScaffold(
      bottom: BookingSummaryBar(
        summary: canTake && p.expectedAt != null ? '${chosen.label} — ${l10n.queueTurnNumber(p.turn)}' : '',
        price: canTake ? chosen.price : null,
        label: l10n.queueTake,
        onPressed: !canTake
            ? null
            : () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(businessId: widget.businessId, shape: widget.shape, offering: chosen, queueDate: _day, chair: chair),
                  ),
                );
                // the turn just taken moves the next one on
                ref.invalidate(appointmentQueueProvider);
              },
      ),
      children: [
        BookingSectionCard(
          title: l10n.bookingServiceTitle,
          child: Column(
            children: [
              for (final s in services)
                _ServiceRow(offering: s, selected: s.id == chosen.id, onTap: () => _set(() => _offeringId = s.id)),
            ],
          ),
        ),
        if (chairs.isNotEmpty) ...[
          const SizedBox(height: 14),
          BookingSectionCard(
            title: l10n.chairPickTitle,
            child: ChairPicker(chairs: chairs, selected: _chairId, onPick: (id) => _set(() => _chairId = id)),
          ),
        ],
        const SizedBox(height: 14),
        BookingSectionCard(
          title: l10n.bookingPickDayTitle,
          child: BookingDayStrip(selected: _day, onPick: (d) => _set(() => _day = d)),
        ),
        const SizedBox(height: 14),
        BookingSectionCard(
          title: l10n.queueYourTurn,
          child: preview.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            error: (_, _) => Text(l10n.commonSomethingWentWrong),
            data: (q) {
              if (q.closed) return Text(l10n.queueClosed, style: theme.textTheme.bodyMedium);
              if (q.full) return Text(l10n.queueFull, style: theme.textTheme.bodyMedium);

              return Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      '${q.turn}',
                      style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.queueTurnNumber(q.turn), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        if (q.expectedAt != null)
                          Text(
                            l10n.queueExpectedAt(DateFormat.jm(locale).format(q.expectedAt!)),
                            style: theme.textTheme.bodyLarge,
                          ),
                        Text(
                          q.ahead == 0 ? l10n.queueNoneAhead : l10n.queueAhead(q.ahead),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(l10n.queueEstimateNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ],
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
