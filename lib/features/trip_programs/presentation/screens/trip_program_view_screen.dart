import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../booking/presentation/widgets/partner_rooms_section.dart';
import '../../application/trip_programs_providers.dart';
import '../../data/models/trip_program.dart';
import '../widgets/trip_widgets.dart';

/// A published trip programme as the customer reads it: days, and in them the words, the photos and the cards of the rooms. A room card
/// opens the booking of that room through the company that published the programme.
class TripProgramViewScreen extends ConsumerWidget {
  final int businessId;
  final int programId;

  const TripProgramViewScreen({super.key, required this.businessId, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final key = (businessId: businessId, id: programId);
    final async = ref.watch(publishedTripProgramProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text(async.valueOrNull?.title ?? l10n.tripProgramsTab)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(publishedTripProgramProvider(key)), child: Text(l10n.commonRetry))),
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if ((p.summary ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(p.summary!, style: theme.textTheme.bodyMedium)),
            for (var i = 0; i < p.days.length; i++) ...[
              _DayHeader(index: i + 1, title: p.days[i].title),
              const SizedBox(height: 8),
              for (final item in p.days[i].items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _item(context, item),
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, TripItem item) {
    final l10n = AppLocalizations.of(context)!;

    if (item.kind != TripItemKind.room) return TripItemView(item: item);

    final room = item.room;
    // the hotel stopped the allocation: the programme keeps its words, the card goes
    if (room == null) {
      return Text(
        (item.body ?? '').isEmpty ? l10n.tripRoomGone : '${item.body}\n${l10n.tripRoomGone}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if ((item.body ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(item.body!)),
      TripRoomTile(
        room: room,
        onBook: () => openPartnerRoomBooking(
          context,
          businessId: businessId,
          unitId: room.unitId,
          serviceId: room.serviceId,
          itemType: room.itemType,
          label: room.label,
          capacity: room.capacity,
          images: room.images,
          features: room.features,
          price: room.price,
          currency: room.currency,
          guestScope: room.guestScope,
        ),
      ),
    ]);
  }
}

class _DayHeader extends StatelessWidget {
  final int index;
  final String? title;

  const _DayHeader({required this.index, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(children: [
      Text(l10n.tripDayLabel(index), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
      if ((title ?? '').isNotEmpty) ...[const SizedBox(width: 8), Expanded(child: Text(title!, style: theme.textTheme.titleSmall))],
      const SizedBox(width: 8),
      const Expanded(child: Divider(height: 1)),
    ]);
  }
}

/// The «البرامج» tab of a business page: what it published.
class BusinessTripProgramsTab extends ConsumerWidget {
  final int businessId;

  const BusinessTripProgramsTab({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(businessTripProgramsProvider(businessId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(businessTripProgramsProvider(businessId)), child: Text(l10n.commonRetry))),
      data: (list) => Builder(
        builder: (context) => CustomScrollView(
          key: const PageStorageKey('business_trip_programs'),
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = list[i];

                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.route_outlined)),
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        [if ((p.summary ?? '').isNotEmpty) p.summary!, l10n.tripDaysCount(p.daysCount)].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripProgramViewScreen(businessId: businessId, programId: p.id))),
                    ),
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
