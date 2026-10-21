import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/hotel_board_providers.dart';
import '../../data/models/occupancy_board.dart';

/// «شاشة الغرف»: the hotel's month. Every room type (grouped by its kind: a room, a suite, a chalet, an apartment) as a calendar where
/// each day shows how many are taken out of how many it has, free / partly taken / full. A tap on a day lists who holds it and through
/// whom it was sold.
class HotelBoardScreen extends ConsumerStatefulWidget {
  const HotelBoardScreen({super.key});

  @override
  ConsumerState<HotelBoardScreen> createState() => _HotelBoardScreenState();
}

class _HotelBoardScreenState extends ConsumerState<HotelBoardScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _go(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(hotelBoardProvider(_month));
    // the arrows point the way the page reads: the previous month sits at the start edge in either direction
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.boardTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(onPressed: () => _go(-1), icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left)),
                Expanded(
                  child: Text(
                    MaterialLocalizations.of(context).formatMonthYear(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(onPressed: () => _go(1), icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right)),
              ],
            ),
          ),
          const _Legend(),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(hotelBoardProvider(_month)), child: Text(l10n.commonRetry))),
              data: (board) => board.kinds.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.boardEmpty, textAlign: TextAlign.center)))
                  : RefreshIndicator(
                      onRefresh: () async => ref.refresh(hotelBoardProvider(_month).future),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        children: [
                          for (final kind in board.kinds) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 6),
                              child: Text(kind.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                            ),
                            for (final unit in kind.units) _UnitMonth(board: board, unit: unit),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget dot(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(t, style: Theme.of(context).textTheme.bodySmall),
    ]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(spacing: 12, runSpacing: 4, children: [
        dot(AppColors.success.withValues(alpha: 0.35), l10n.boardFree),
        dot(AppColors.warning.withValues(alpha: 0.5), l10n.boardPartly),
        dot(AppColors.error.withValues(alpha: 0.55), l10n.boardFull),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.handshake_outlined, size: 12, color: Theme.of(context).hintColor),
          const SizedBox(width: 4),
          Text(l10n.boardViaPartner, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ]),
    );
  }
}

class _UnitMonth extends StatelessWidget {
  final OccupancyBoardData board;
  final OccUnit unit;

  const _UnitMonth({required this.board, required this.unit});

  Color _color(int booked) {
    if (unit.stock <= 0 || booked >= unit.stock) return AppColors.error.withValues(alpha: 0.55);
    if (booked > 0) return AppColors.warning.withValues(alpha: 0.5);

    return AppColors.success.withValues(alpha: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Saturday-first week, the way the hotel reads it: the 1st sits under its weekday
    final lead = (board.firstWeekday + 1) % 7;
    final cells = lead + board.days;
    final rows = (cells / 7).ceil();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(unit.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              Text(l10n.boardStock(unit.stock), style: theme.textTheme.bodySmall),
            ]),
            if (unit.guestScope != 'all')
              Text(unit.guestScope == 'locals' ? l10n.guestScopeLocals : l10n.guestScopeForeigners, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
            if (unit.heldForPartners > 0) Text(l10n.boardHeld(unit.heldForPartners), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 6),
            Row(children: [
              // Saturday first: the week as the hotel reads it
              for (final w in const [6, 0, 1, 2, 3, 4, 5])
                Expanded(child: Center(child: Text(MaterialLocalizations.of(context).narrowWeekdays[w], style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)))),
            ]),
            const SizedBox(height: 2),
            for (var r = 0; r < rows; r++)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    for (var c = 0; c < 7; c++)
                      Expanded(
                        child: Builder(builder: (context) {
                          final i = r * 7 + c - lead;
                          if (i < 0 || i >= board.days) return const SizedBox(height: 40);

                          final booked = i < unit.booked.length ? unit.booked[i] : 0;
                          final partner = i < unit.viaPartner.length ? unit.viaPartner[i] : 0;

                          return Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: booked == 0 ? null : () => _showDay(context, DateTime(board.month.year, board.month.month, i + 1)),
                              child: Container(
                                height: 37,
                                decoration: BoxDecoration(color: _color(booked), borderRadius: BorderRadius.circular(6)),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(mainAxisSize: MainAxisSize.min, children: [
                                      Text('${i + 1}', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                                      Text('$booked/${unit.stock}', style: const TextStyle(fontSize: 9)),
                                    ]),
                                    if (partner > 0) const Positioned(top: 2, right: 2, child: Icon(Icons.handshake_outlined, size: 9)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDay(BuildContext context, DateTime day) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final held = unit.bookings.where((b) => b.holds(day)).toList();

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${unit.label} · ${MaterialLocalizations.of(ctx).formatMediumDate(day)}', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final b in held)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(b.viaPartner ? Icons.handshake_outlined : Icons.person_outline),
                  title: Text('${b.guest ?? ''}${b.quantity > 1 ? ' × ${b.quantity}' : ''}'),
                  subtitle: Text([
                    b.viaPartner ? l10n.boardSoldBy(b.partner ?? '') : l10n.boardDirect,
                    '${MaterialLocalizations.of(ctx).formatShortDate(b.startsAt)} → ${MaterialLocalizations.of(ctx).formatShortDate(b.endsAt)}',
                    if ((b.roomNumber ?? '').isNotEmpty) l10n.boardRoomNumber(b.roomNumber!),
                    if (b.guestOrigin == 'local') l10n.boardCheckLocal,
                    if (b.guestOrigin == 'foreign') l10n.boardCheckForeign,
                  ].join(' · ')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
