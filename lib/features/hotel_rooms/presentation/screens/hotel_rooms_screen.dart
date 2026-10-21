import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../booking/data/models/unit_discovery.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../business/data/models/offering_item.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/hotel_rooms_providers.dart';
import '../../data/hotel_rooms_api.dart';

/// «احجز غرفة»: the rooms of every hotel that matches the class (the stars), the governorate, the city, the price and the
/// stay the customer picked in the filter sheet, cheapest first. A tap on a room opens the booking form on that very room
/// (the dates already filled in). A partner company that holds an allocation of the same room and offers it at its own
/// price is shown on the card beside the hotel's price.
class HotelRoomsScreen extends ConsumerStatefulWidget {
  /// What to start from (the hotel list passes its stay and the hotel), and the title to show instead of «احجز غرفة».
  final HotelRoomQuery initial;
  final String? title;

  const HotelRoomsScreen({super.key, this.initial = const HotelRoomQuery(), this.title});

  @override
  ConsumerState<HotelRoomsScreen> createState() => _HotelRoomsScreenState();
}

class _HotelRoomsScreenState extends ConsumerState<HotelRoomsScreen> {
  late HotelRoomQuery _query = widget.initial;

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

    String? nameOf(List<FilterOption>? options, int? id) => id == null ? null : options?.where((o) => o.id == id).firstOrNull?.name;

    final dates = LocalFormat.monthDay(context);
    final chips = <(String, VoidCallback)>[
      if (nameOf(filters?.classes, _query.classId) case final n?) (n, () => setState(() => _query = _query.copyWith(clearClass: true))),
      if (nameOf(filters?.governorates, _query.governorateId) case final n?)
        (n, () => setState(() => _query = _query.copyWith(clearGovernorate: true))),
      if (_query.cityId != null) (l10n.hotelRoomsCityChip, () => setState(() => _query = _query.copyWith(clearCity: true))),
      if (_query.hasDates)
        ('${dates.format(_query.checkIn!)} → ${dates.format(_query.checkOut!)}', () => setState(() => _query = _query.copyWith(clearDates: true))),
      if (_query.priceMin != null || _query.priceMax != null)
        (
          '${_query.priceMin?.toStringAsFixed(0) ?? '0'}–${_query.priceMax?.toStringAsFixed(0) ?? '∞'}',
          () => setState(() => _query = _query.copyWith(clearPrice: true)),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l10n.hotelRoomsTitle),
        actions: [
          TextButton.icon(
            onPressed: _openFilter,
            icon: const Icon(Icons.tune),
            label: Text(_query.activeCount == 0 ? l10n.hotelRoomsFilter : l10n.hotelRoomsFilterCount(_query.activeCount)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong),
                    TextButton(onPressed: () => ref.invalidate(hotelRoomsProvider(_query)), child: Text(l10n.commonRetry)),
                  ],
                ),
              ),
              data: (page) => RefreshIndicator(
                onRefresh: () async => ref.refresh(hotelRoomsProvider(_query).future),
                child: page.rooms.isEmpty
                    ? ListView(children: [const SizedBox(height: 120), Center(child: Text(l10n.hotelRoomsEmpty))])
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: page.rooms.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => i == 0
                            ? Text(l10n.hotelRoomsCount(page.total), style: Theme.of(context).textTheme.titleSmall)
                            : _RoomCard(room: page.rooms[i - 1], query: _query),
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
  final HotelRoomQuery query;

  const _RoomCard({required this.room, required this.query});

  /// A tap books this very room: the form opens on it, the dates (if any) already filled.
  void _book(BuildContext context) {
    final offeringId = room.offeringId;
    if (offeringId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          businessId: room.hotelId,
          initialUnit: DiscoveredUnit(
            id: room.unitId,
            label: room.roomName,
            capacity: room.capacity,
            images: [?room.imageUrl],
            price: room.price,
          ),
          initialStartsAt: query.checkIn,
          initialEndsAt: query.checkOut,
          offering: OfferingItem(
            id: offeringId,
            source: 'price',
            label: room.roomName,
            price: room.price,
            currency: room.currency,
            serviceId: room.serviceId,
            itemType: room.itemType,
            imageUrl: room.imageUrl,
            action: 'book',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final place = [room.className, room.city ?? room.governorate].whereType<String>().join(' · ');
    final cheaper = room.cheaperPartner;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _book(context),
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
                          ? ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: const Icon(Icons.hotel_outlined))
                          : Image.network(
                              room.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: const Icon(Icons.hotel_outlined)),
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
                        if (place.isNotEmpty) Text(place, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          l10n.hotelRoomsPricePerNight(room.price.toStringAsFixed(0), room.currency),
                          style: theme.textTheme.titleMedium,
                        ),
                        if (room.total != null && room.nights != null)
                          Text(
                            l10n.hotelRoomsTotalFor(room.total!.toStringAsFixed(0), room.currency, l10n.hotelRoomsNights(room.nights!)),
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (room.partnerOffers.isNotEmpty) ...[
                const Divider(height: 20),
                Text(l10n.hotelRoomsOtherPrices, style: theme.textTheme.labelMedium),
                for (final o in room.partnerOffers)
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: o.sellerId))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(o.sellerName ?? '', style: theme.textTheme.bodyMedium)),
                          Text(
                            '${o.price.toStringAsFixed(0)} ${room.currency}',
                            style: theme.textTheme.titleSmall?.copyWith(color: o.price < room.price ? theme.colorScheme.primary : null),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                if (cheaper != null) Text(l10n.hotelRoomsCheaperThanHotel, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The filter sheet: the class first (the stars), then the stay, governorate and — once one is chosen — city, then the price.
class _FilterSheet extends ConsumerStatefulWidget {
  final HotelRoomQuery initial;

  const _FilterSheet({required this.initial});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late HotelRoomQuery _q = widget.initial;
  late final _min = TextEditingController(text: widget.initial.priceMin?.toStringAsFixed(0) ?? '');
  late final _max = TextEditingController(text: widget.initial.priceMax?.toStringAsFixed(0) ?? '');

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final today = EgyptTime.today();
    final range = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: _q.hasDates ? DateTimeRange(start: _q.checkIn!, end: _q.checkOut!) : null,
    );
    if (range != null) setState(() => _q = _q.copyWith(checkIn: range.start, checkOut: range.end));
  }

  HotelRoomQuery _withPrice() => HotelRoomQuery(
    classId: _q.classId,
    governorateId: _q.governorateId,
    cityId: _q.cityId,
    priceMin: double.tryParse(_min.text.trim()),
    priceMax: double.tryParse(_max.text.trim()),
    checkIn: _q.checkIn,
    checkOut: _q.checkOut,
    businessId: _q.businessId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // The classes and governorates never depend on the governorate picked; only the cities do. Reading both from the keyed
    // provider emptied the governorate list for a moment after a pick, and a dropdown whose value is not among its items
    // is a red screen.
    final base = ref.watch(hotelRoomFiltersProvider(null)).valueOrNull;
    final cities = _q.governorateId == null ? null : ref.watch(hotelRoomFiltersProvider(_q.governorateId)).valueOrNull?.cities;
    final governorates = base?.governorates ?? const <FilterOption>[];
    final cityOptions = cities ?? const <FilterOption>[];
    final dates = LocalFormat.date(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.hotelRoomsFilter, style: theme.textTheme.titleMedium)),
                TextButton(onPressed: () => Navigator.pop(context, const HotelRoomQuery()), child: Text(l10n.hotelRoomsClear)),
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
                  onSelected: (_) => setState(() => _q = _q.copyWith(clearClass: true)),
                ),
                for (final c in base?.classes ?? const <FilterOption>[])
                  ChoiceChip(
                    label: Text(c.name),
                    selected: _q.classId == c.id,
                    onSelected: (_) => setState(() => _q = _q.copyWith(classId: c.id)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickDates,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.hotelRoomsDatesLabel,
                  suffixIcon: _q.hasDates
                      ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _q = _q.copyWith(clearDates: true)))
                      : const Icon(Icons.event),
                ),
                child: Text(_q.hasDates ? '${dates.format(_q.checkIn!)} → ${dates.format(_q.checkOut!)}' : l10n.hotelRoomsDatesPick),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: governorates.any((g) => g.id == _q.governorateId) ? _q.governorateId : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.locationGovernorateLabel),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l10n.carAnyChoice)),
                for (final g in governorates)
                  DropdownMenuItem<int?>(value: g.id, child: Text('${g.name} (${g.count})')),
              ],
              onChanged: (v) => setState(() => _q = v == null ? _q.copyWith(clearGovernorate: true) : _q.copyWith(governorateId: v, clearCity: true)),
            ),
            if (_q.governorateId != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                // a new key per governorate and per loaded list, so the field is rebuilt when the cities arrive
                key: ValueKey('city-${_q.governorateId}-${cityOptions.length}'),
                initialValue: cityOptions.any((c) => c.id == _q.cityId) ? _q.cityId : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.locationCityLabel),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(l10n.carAnyChoice)),
                  for (final c in cityOptions)
                    DropdownMenuItem<int?>(value: c.id, child: Text('${c.name} (${c.count})')),
                ],
                onChanged: (v) => setState(() => _q = v == null ? _q.copyWith(clearCity: true) : _q.copyWith(cityId: v)),
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
                    decoration: InputDecoration(labelText: l10n.hotelRoomsPriceFrom),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _max,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.hotelRoomsPriceTo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.pop(context, _withPrice()), child: Text(l10n.hotelRoomsApply)),
            ),
          ],
        ),
      ),
    );
  }
}
