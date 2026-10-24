import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../promotions/presentation/widgets/offer_widgets.dart';
import '../../data/models/trip_program.dart';

String _money(double v, String currency) => '${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} $currency';

/// The card of a hotel's room inside a trip programme: photo, what it carries, who it comes from, the company's price. [onBook] makes it a
/// button for the customer; the author's view leaves it null.
class TripRoomTile extends StatelessWidget {
  final TripRoom room;
  final VoidCallback? onBook;

  const TripRoomTile({super.key, required this.room, this.onBook});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (room.images.isNotEmpty)
            SizedBox(
              height: 150,
              child: PageView(
                children: [
                  for (final url in room.images)
                    Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Icon(Icons.bed_outlined, color: theme.hintColor))),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                if ((room.fromName ?? '').isNotEmpty) Text(l10n.pshFromHotel(room.fromName!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                if (room.myHold?.isLive == true) Text(l10n.bookingMyHold(room.myHold!.leftLabel), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                if (room.guestScope != 'all') Text(room.guestScope == 'locals' ? l10n.guestScopeLocals : l10n.guestScopeForeigners, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                if (room.features.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(spacing: 6, runSpacing: 4, children: [
                      for (final f in room.features)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(99)),
                          child: Text(f, style: theme.textTheme.bodySmall),
                        ),
                    ]),
                  ),
                const SizedBox(height: 8),
                Row(children: [
                  PriceWithOffer(label: _money(room.price, room.currency), offer: room.offer, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 4),
                  Text(l10n.pshPerNight, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  const Spacer(),
                  if (onBook != null) FilledButton(onPressed: room.available ? onBook : null, child: Text(room.available ? l10n.tripBookRoom : l10n.tripSoldOut)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A line of the programme that is not a room: its words, or its photo with the words under it.
class TripItemView extends StatelessWidget {
  final TripItem item;

  const TripItemView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item.kind == TripItemKind.image) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (item.images.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(item.images.first, fit: BoxFit.cover, width: double.infinity, height: 170, errorBuilder: (_, _, _) => const SizedBox(height: 60)),
          ),
        if ((item.body ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(item.body!, style: theme.textTheme.bodySmall)),
      ]);
    }

    return Text(item.body ?? '', style: theme.textTheme.bodyMedium);
  }
}
