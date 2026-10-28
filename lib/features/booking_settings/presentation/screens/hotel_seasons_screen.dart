import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../booking/data/models/hotel_season.dart';
import '../../application/booking_settings_controller.dart';

/// «المواسم»: the hotel's seasons — the rooms' price in each (a % or an amount on every room type, or a night price for a type), the
/// meal plans' price in it, and the shortest stay that may arrive in it. A room type's own price rule still wins over its season.
class HotelSeasonsScreen extends ConsumerStatefulWidget {
  const HotelSeasonsScreen({super.key});

  @override
  ConsumerState<HotelSeasonsScreen> createState() => _HotelSeasonsScreenState();
}

class _HotelSeasonsScreenState extends ConsumerState<HotelSeasonsScreen> {
  HotelSeasonsData? _data;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ref.read(bookingSettingsApiProvider).seasons();
      if (mounted) setState(() => _data = d);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _edit([HotelSeason? season]) async {
    final data = _data;
    if (data == null) return;
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => _SeasonEditor(season: season, data: data)));
    if (saved == true) await _load();
  }

  Future<void> _delete(HotelSeason s) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(bookingSettingsApiProvider).deleteSeason(s.id);
      await _load();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  String _summary(AppLocalizations l10n, HotelSeason s) {
    final v = s.roomChangeValue;
    final parts = <String>[
      if (v != null) s.roomChangeType == 'amount' ? '${v > 0 ? '+' : ''}${v.toStringAsFixed(0)}' : '${v > 0 ? '+' : ''}${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}%',
      if (s.roomPrices.isNotEmpty) l10n.seasonRoomPricesN(s.roomPrices.length),
      if (s.mealPrices.isNotEmpty) l10n.seasonMealPricesN(s.mealPrices.length),
      if (s.minNights != null) l10n.seasonMinNightsN(s.minNights!),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = _data;
    final fmt = LocalFormat.date(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.seasonsTitle)),
      floatingActionButton: data == null ? null : FloatingActionButton.extended(onPressed: () => _edit(), icon: const Icon(Icons.add), label: Text(l10n.seasonAdd)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Text(l10n.seasonsIntro, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 12),
                if (data.seasons.isEmpty) Padding(padding: const EdgeInsets.only(top: 24), child: Center(child: Text(l10n.seasonsEmpty))),
                for (final s in data.seasons)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.date_range_outlined),
                      title: Text('${s.name} · ${fmt.format(s.start)} → ${fmt.format(s.end)}'),
                      subtitle: Text(_summary(l10n, s)),
                      onTap: () => _edit(s),
                      trailing: IconButton(tooltip: l10n.commonDelete, icon: const Icon(Icons.delete_outline), onPressed: () => _delete(s)),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SeasonEditor extends ConsumerStatefulWidget {
  final HotelSeason? season;
  final HotelSeasonsData data;
  const _SeasonEditor({this.season, required this.data});

  @override
  ConsumerState<_SeasonEditor> createState() => _SeasonEditorState();
}

class _SeasonEditorState extends ConsumerState<_SeasonEditor> {
  late final _name = TextEditingController(text: widget.season?.name ?? '');
  late final _change = TextEditingController(text: _num(widget.season?.roomChangeValue));
  late final Map<int, TextEditingController> _rooms = {
    for (final r in widget.data.roomTypes) r.id: TextEditingController(text: _num(widget.season?.roomPrices[r.id])),
  };
  late final Map<int, TextEditingController> _meals = {
    for (final m in widget.data.mealPlans) m.optionId: TextEditingController(text: _num(widget.season?.mealPrices[m.optionId])),
  };
  late String _changeType = widget.season?.roomChangeType ?? 'percent';
  late DateTimeRange? _range = widget.season == null ? null : DateTimeRange(start: widget.season!.start, end: widget.season!.end);
  late int? _minNights = widget.season?.minNights;
  bool _saving = false;
  String? _error;

  static String _num(double? v) => v == null ? '' : v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  static double? _parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _name.dispose();
    _change.dispose();
    for (final c in [..._rooms.values, ..._meals.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty || _range == null) {
      setState(() => _error = l10n.seasonMissing);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final season = HotelSeason(
      id: widget.season?.id ?? 0,
      name: _name.text.trim(),
      start: _range!.start,
      end: _range!.end,
      roomChangeType: _changeType,
      roomChangeValue: _parse(_change.text),
      roomPrices: {for (final e in _rooms.entries) if (_parse(e.value.text) != null) e.key: _parse(e.value.text)!},
      mealPrices: {for (final e in _meals.entries) if (_parse(e.value.text) != null) e.key: _parse(e.value.text)!},
      minNights: _minNights,
    );
    try {
      await ref.read(bookingSettingsApiProvider).saveSeason(season);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = LocalFormat.date(context);
    const number = TextInputType.numberWithOptions(decimal: true, signed: true);

    return Scaffold(
      appBar: AppBar(title: Text(widget.season == null ? l10n.seasonAdd : l10n.seasonEdit)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: InputDecoration(labelText: l10n.seasonName, hintText: l10n.seasonNameHint)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range_outlined),
            label: Text(_range == null ? l10n.seasonDates : '${fmt.format(_range!.start)} → ${fmt.format(_range!.end)}'),
            onPressed: _pickRange,
          ),
          const Divider(height: 32),
          // the rooms: one change for every type, or a night price for a type
          Text(l10n.seasonRoomsTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'percent', label: Text(l10n.seasonChangePercent)),
              ButtonSegment(value: 'amount', label: Text(l10n.seasonChangeAmount)),
            ],
            selected: {_changeType},
            onSelectionChanged: (s) => setState(() => _changeType = s.first),
          ),
          TextField(
            controller: _change,
            keyboardType: number,
            decoration: InputDecoration(
              labelText: l10n.seasonChangeValue,
              helperText: l10n.seasonChangeHint,
              suffixText: _changeType == 'percent' ? '%' : null,
            ),
          ),
          if (widget.data.roomTypes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.seasonRoomPriceHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            for (final r in widget.data.roomTypes)
              TextField(
                controller: _rooms[r.id],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: r.title),
              ),
          ],
          if (widget.data.mealPlans.isNotEmpty) ...[
            const Divider(height: 32),
            Text(l10n.seasonMealsTitle, style: theme.textTheme.titleMedium),
            for (final m in widget.data.mealPlans)
              TextField(
                controller: _meals[m.optionId],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: m.name, helperText: l10n.seasonMealOwnPrice(m.price.toStringAsFixed(0))),
              ),
          ],
          const Divider(height: 32),
          Row(children: [
            Expanded(child: Text(l10n.seasonMinNights)),
            DropdownButton<int?>(
              value: _minNights,
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.seasonNoMinimum)),
                for (var n = 2; n <= 14; n++) DropdownMenuItem(value: n, child: Text('$n')),
              ],
              onChanged: (v) => setState(() => _minNights = v),
            ),
          ]),
          Text(l10n.seasonMinNightsHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
          const SizedBox(height: 16),
          FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
        ],
      ),
    );
  }
}
