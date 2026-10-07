import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/room_models.dart';

/// «العدد والرقم لكل غرفة يكون لدى الفندق فقط» — the numbered rooms behind this room type. The customer books the
/// type; a room is given to the stay when it starts, and only then does the customer see its number.
class BookableRoomsSection extends ConsumerStatefulWidget {
  final int itemId;
  const BookableRoomsSection({super.key, required this.itemId});

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
    if (choice == 'maintenance') {
      await _apply(() => api.setRoomMaintenance(widget.itemId, room.id, !room.isMaintenance));
    } else if (choice == 'delete') {
      await _apply(() => api.deleteRoom(widget.itemId, room.id));
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
            Expanded(child: Text(l10n.roomsTitle, style: theme.textTheme.titleSmall)),
            if (payload != null) Text(l10n.roomsOpenCount('${payload.openCount}'), style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(l10n.roomsHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _numbers,
                enabled: !_busy,
                decoration: InputDecoration(labelText: l10n.roomsNumbersField, hintText: '101، 102، 110-115'),
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
                  label: Text(room.number),
                  backgroundColor: room.isMaintenance ? theme.disabledColor.withValues(alpha: 0.15) : null,
                  onPressed: () => _manage(room),
                ),
            ],
          ),
      ],
    );
  }
}
