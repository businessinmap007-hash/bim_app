import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/add_on_models.dart';
import '../../data/models/room_models.dart';

/// «العدد والرقم لكل غرفة يكون لدى الفندق فقط» — the numbered rooms behind this room type. The customer books the
/// type; a room is given to the stay when it starts, and only then does the customer see its number.
class BookableRoomsSection extends ConsumerStatefulWidget {
  final int itemId;
  /// 'room' (a hotel) | 'car' (a rental company) | 'unit' — what the list is called.
  final String noun;
  const BookableRoomsSection({super.key, required this.itemId, this.noun = 'room'});

  @override
  ConsumerState<BookableRoomsSection> createState() => _BookableRoomsSectionState();
}

class _BookableRoomsSectionState extends ConsumerState<BookableRoomsSection> {
  final _numbers = TextEditingController();
  RoomsPayload? _payload;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _numbers.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final payload = await ref.read(bookingSettingsApiProvider).rooms(widget.itemId);
      if (mounted) setState(() => _payload = payload);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _apply(Future<RoomsPayload> Function() call) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final payload = await call();
      // the type's count follows its open rooms — bring the unit list up to date
      await ref.read(bookingSettingsControllerProvider.notifier).refreshItem(widget.itemId);
      if (mounted) setState(() => _payload = payload);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is Exception ? l10n.commonSomethingWentWrong : '$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final numbers = parseRoomNumbers(_numbers.text);
    if (numbers.isEmpty) return;
    final api = ref.read(bookingSettingsApiProvider);
    await _apply(() => api.addRooms(widget.itemId, numbers));
    _numbers.clear();
  }

  Future<void> _manage(RoomRow room) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(bookingSettingsApiProvider);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(room.number, style: Theme.of(context).textTheme.titleMedium)),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(l10n.roomFeaturesAction),
              subtitle: Text(room.features.isEmpty ? l10n.roomFeaturesNone : room.features.join('، ')),
              onTap: () => Navigator.of(sheet).pop('features'),
            ),
            ListTile(
              leading: Icon(room.isMaintenance ? Icons.lock_open_outlined : Icons.build_outlined),
              title: Text(room.isMaintenance ? l10n.roomsReopen : l10n.roomMaintenance),
              onTap: () => Navigator.of(sheet).pop('maintenance'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.commonDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => Navigator.of(sheet).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'features') {
      await _editFeatures(room);
    } else if (choice == 'maintenance') {
      await _apply(() => api.setRoomMaintenance(widget.itemId, room.id, !room.isMaintenance));
    } else if (choice == 'delete') {
      await _apply(() => api.deleteRoom(widget.itemId, room.id));
    }
  }

  /// «مواصفات لكل رقم غرفة»: tick what this very room carries; the guest who asked for it gets this number when the stay starts.
  Future<void> _editFeatures(RoomRow room) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(bookingSettingsApiProvider);
    List<UnitFeature> all;
    try {
      all = await api.roomFeatures(widget.itemId, room.id);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      return;
    }
    if (!mounted) return;

    final chosen = {for (final f in all) if (f.selected) f.id};
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.roomFeaturesTitle(room.number), style: Theme.of(sheet).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.roomFeaturesHint, style: Theme.of(sheet).textTheme.bodySmall?.copyWith(color: Theme.of(sheet).hintColor)),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final f in all)
                          FilterChip(
                            label: Text(f.name),
                            selected: chosen.contains(f.id),
                            onSelected: (on) => setSheet(() => on ? chosen.add(f.id) : chosen.remove(f.id)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.of(sheet).pop(true), child: Text(l10n.commonSave))),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      await _apply(() async {
        await api.saveRoomFeatures(widget.itemId, room.id, chosen.toList());
        return api.rooms(widget.itemId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final payload = _payload;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(switch (widget.noun) { 'car' => l10n.roomsTitleCar, 'unit' => l10n.roomsTitleUnit, _ => l10n.roomsTitle }, style: theme.textTheme.titleSmall)),
            if (payload != null) Text(l10n.roomsOpenCount('${payload.openCount}'), style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(switch (widget.noun) { 'car' => l10n.roomsHintCar, 'unit' => l10n.roomsHintUnit, _ => l10n.roomsHint }, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _numbers,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: switch (widget.noun) { 'car' => l10n.roomsNumbersFieldCar, 'unit' => l10n.roomsNumbersFieldUnit, _ => l10n.roomsNumbersField },
                  hintText: widget.noun == 'room' ? '101، 102، 110-115' : '1، 2، 10-15',
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: FilledButton(onPressed: _busy ? null : _add, child: Text(l10n.roomsAdd)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_failed)
          Text(l10n.commonSomethingWentWrong)
        else if (payload == null)
          const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final room in payload.rooms)
                ActionChip(
                  avatar: room.occupied
                      ? const Icon(Icons.person, size: 14)
                      : (room.isMaintenance ? const Icon(Icons.build_outlined, size: 14) : null),
                  label: Text(room.features.isEmpty ? room.number : '${room.number} · ${room.features.length}★'),
                  backgroundColor: room.isMaintenance ? theme.disabledColor.withValues(alpha: 0.15) : null,
                  onPressed: () => _manage(room),
                ),
            ],
          ),
      ],
    );
  }
}
