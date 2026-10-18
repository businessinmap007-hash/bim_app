import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../../offers/presentation/screens/offer_detail_screen.dart';
import '../../application/hotel_rooms_providers.dart';
import '../../data/hotel_rooms_api.dart';

/// «احجز غرفة»: the rooms of every hotel that matches the class (the stars), the governorate and the city the customer
/// picked in the filter sheet, cheapest first. A partner company that holds an allocation of the same room and offers it
/// at its own price is shown on the card beside the hotel's price.
class HotelRoomsScreen extends ConsumerStatefulWidget {
  const HotelRoomsScreen({super.key});

  @override
  ConsumerState<HotelRoomsScreen> createState() => _HotelRoomsScreenState();
}

class _HotelRoomsScreenState extends ConsumerState<HotelRoomsScreen> {
  HotelRoomQuery _query = const HotelRoomQuery();

  Future<void> _openFilter() async {
    final picked = await showModalBottomSheet<HotelRoomQuery>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(initial: _query),
    );
    if (picked != null) setState(() => _query = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(hotelRoomsProvider(_query));
    final filters = ref.watch(hotelRoomFiltersProvider(null)).valueOrNull;

    String? nameOf(List<FilterOption>? options, int? id) =>
        id == null ? null : options?.where((o) => o.id == id).firstOrNull?.name;

    final chips = <(String, VoidCallback)>[
      if (nameOf(filters?.classes, _query.classId) case final n?)
        (n, () => setState(() => _query = _query.copyWith(clearClass: true))),
      if (nameOf(filters?.governorates, _query.governorateId) case final n?)
        (
          n,
          () =>
              setState(() => _query = _query.copyWith(clearGovernorate: true)),
        ),
      if (_query.cityId != null)
        (
          l10n.hotelRoomsCityChip,
          () => setState(() => _query = _query.copyWith(clearCity: true)),
        ),
      if (_query.priceMin != null || _query.priceMax != null)
        (
          '${_query.priceMin?.toStringAsFixed(0) ?? '0'}–${_query.priceMax?.toStringAsFixed(0) ?? '∞'}',
          () => setState(() => _query = _query.copyWith(clearPrice: true)),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hotelRoomsTitle),
        actions: [
          TextButton.icon(
            onPressed: _openFilter,
            icon: const Icon(Icons.tune),
            label: Text(
              _query.activeCount == 0
                  ? l10n.hotelRoomsFilter
                  : l10n.hotelRoomsFilterCount(_query.activeCount),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (chips.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  for (final c in chips)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: InputChip(label: Text(c.$1), onDeleted: c.$2),
                    ),
                ],
              ),
            ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e is ApiException
                          ? e.message
                          : l10n.commonSomethingWentWrong,
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(hotelRoomsProvider(_query)),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (page) => RefreshIndicator(
                onRefresh: () async =>
                    ref.refresh(hotelRoomsProvider(_query).future),
                child: page.rooms.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text(l10n.hotelRoomsEmpty)),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: page.rooms.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => i == 0
                            ? Text(
                                l10n.hotelRoomsCount(page.total),
                                style: Theme.of(context).textTheme.titleSmall,
                              )
                            : _RoomCard(room: page.rooms[i - 1]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final HotelRoom room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final place = [
      room.className,
      room.city ?? room.governorate,
    ].whereType<String>().join(' · ');
    final cheaper = room.cheaperPartner;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BusinessDetailScreen(businessId: room.hotelId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: room.imageUrl == null
                          ? ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.hotel_outlined),
                            )
                          : Image.network(
                              room.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => ColoredBox(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.hotel_outlined),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.roomName, style: theme.textTheme.titleSmall),
                        Text(room.hotelName, style: theme.textTheme.bodyMedium),
                        if (place.isNotEmpty)
                          Text(place, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          l10n.hotelRoomsPricePerNight(
                            room.price.toStringAsFixed(0),
                            room.currency,
                          ),
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (room.partnerOffers.isNotEmpty) ...[
                const Divider(height: 20),
                Text(
                  l10n.hotelRoomsOtherPrices,
                  style: theme.textTheme.labelMedium,
                ),
                for (final o in room.partnerOffers)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OfferDetailScreen(offerId: o.offerId),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              o.sellerName ?? '',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${o.price.toStringAsFixed(0)} ${room.currency}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: o.price < room.price
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                if (cheaper != null)
                  Text(
                    l10n.hotelRoomsCheaperThanHotel,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The filter sheet: the class first (the stars), then governorate and — once one is chosen — city, then the price.
class _FilterSheet extends ConsumerStatefulWidget {
  final HotelRoomQuery initial;

  const _FilterSheet({required this.initial});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late HotelRoomQuery _q = widget.initial;
  late final _min = TextEditingController(
    text: widget.initial.priceMin?.toStringAsFixed(0) ?? '',
  );
  late final _max = TextEditingController(
    text: widget.initial.priceMax?.toStringAsFixed(0) ?? '',
  );

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  HotelRoomQuery _withPrice() => HotelRoomQuery(
    classId: _q.classId,
    governorateId: _q.governorateId,
    cityId: _q.cityId,
    priceMin: double.tryParse(_min.text.trim()),
    priceMax: double.tryParse(_max.text.trim()),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final filters = ref
        .watch(hotelRoomFiltersProvider(_q.governorateId))
        .valueOrNull;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.hotelRoomsFilter,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const HotelRoomQuery()),
                  child: Text(l10n.hotelRoomsClear),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.hotelRoomsClassLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.carAnyChoice),
                  selected: _q.classId == null,
                  onSelected: (_) =>
                      setState(() => _q = _q.copyWith(clearClass: true)),
                ),
                for (final c in filters?.classes ?? const <FilterOption>[])
                  ChoiceChip(
                    label: Text(c.name),
                    selected: _q.classId == c.id,
                    onSelected: (_) =>
                        setState(() => _q = _q.copyWith(classId: c.id)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _q.governorateId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.locationGovernorateLabel,
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.carAnyChoice),
                ),
                for (final g in filters?.governorates ?? const <FilterOption>[])
                  DropdownMenuItem<int?>(
                    value: g.id,
                    child: Text('${g.name} (${g.count})'),
                  ),
              ],
              onChanged: (v) => setState(
                () => _q = v == null
                    ? _q.copyWith(clearGovernorate: true)
                    : _q.copyWith(governorateId: v),
              ),
            ),
            if (_q.governorateId != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                key: ValueKey('city-${_q.governorateId}'),
                initialValue: _q.cityId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.locationCityLabel),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.carAnyChoice),
                  ),
                  for (final c in filters?.cities ?? const <FilterOption>[])
                    DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text('${c.name} (${c.count})'),
                    ),
                ],
                onChanged: (v) => setState(
                  () => _q = v == null
                      ? _q.copyWith(clearCity: true)
                      : _q.copyWith(cityId: v),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(l10n.hotelRoomsPriceLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _min,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.hotelRoomsPriceFrom,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _max,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.hotelRoomsPriceTo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _withPrice()),
                child: Text(l10n.hotelRoomsApply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
