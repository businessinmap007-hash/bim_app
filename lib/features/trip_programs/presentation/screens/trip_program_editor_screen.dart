import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/trip_programs_providers.dart';
import '../../data/models/trip_program.dart';
import '../widgets/trip_widgets.dart';

/// The author's side of a trip programme: days, and in each the words, the photos and the cards of the rooms a hotel gave the company.
/// Everything saves as it is done; the programme reaches customers only once it is published.
class TripProgramEditorScreen extends ConsumerStatefulWidget {
  final int programId;

  const TripProgramEditorScreen({super.key, required this.programId});

  @override
  ConsumerState<TripProgramEditorScreen> createState() => _TripProgramEditorScreenState();
}

class _TripProgramEditorScreenState extends ConsumerState<TripProgramEditorScreen> {
  TripProgram? _program;
  bool _loading = true;
  bool _failed = false;

  int get _id => widget.programId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final p = await ref.read(tripProgramsApiProvider).show(_id);
      if (mounted) setState(() => _program = p);
    } catch (_) {
      if (mounted) _failed = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  /// Runs one change and takes the refreshed programme it answers with.
  Future<void> _do(Future<TripProgram> Function() change) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final p = await change();
      if (mounted) setState(() => _program = p);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  Future<String?> _ask(String title, {String? initial, int lines = 1}) async {
    final l10n = AppLocalizations.of(context)!;
    final c = TextEditingController(text: initial);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true, maxLines: lines, minLines: lines),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    final text = c.text.trim();
    c.dispose();

    return ok == true ? text : null;
  }

  Future<void> _addText(TripDay day) async {
    final l10n = AppLocalizations.of(context)!;
    final text = await _ask(l10n.tripAddText, lines: 3);
    if (text == null || text.isEmpty) return;
    await _do(() async => (await ref.read(tripProgramsApiProvider).addItem(_id, day.id, kind: TripItemKind.text, body: text)).program);
  }

  Future<void> _addPhoto(TripDay day) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(tripProgramsApiProvider);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (picked == null || !mounted) return;
    final caption = await _ask(l10n.tripPhotoCaption);

    await _do(() async {
      final added = await api.addItem(_id, day.id, kind: TripItemKind.image, body: caption);

      return api.setImage(_id, added.itemId, File(picked.path));
    });
  }

  Future<void> _addRoom(TripDay day) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(tripProgramsApiProvider);
    final rooms = await showModalBottomSheet<TripRoom>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _RoomPicker(title: l10n.tripPickRoom),
    );
    if (rooms == null || rooms.allocationId == null) return;

    await _do(() async => (await api.addItem(_id, day.id, kind: TripItemKind.room, allocationId: rooms.allocationId)).program);
  }

  Future<bool> _confirm(String text, String action) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(action)),
        ],
      ),
    );

    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final api = ref.read(tripProgramsApiProvider);
    final p = _program;

    return Scaffold(
      appBar: AppBar(
        title: Text(p?.title ?? l10n.tripScreenTitle),
        actions: [
          if (p != null)
            PopupMenuButton<String>(
              onSelected: (v) async {
                final navigator = Navigator.of(context);
                if (v == 'edit') {
                  final title = await _ask(l10n.tripTitleHint, initial: p.title);
                  if (title != null && title.isNotEmpty) await _do(() => api.update(_id, title: title, summary: p.summary));
                }
                if (v == 'summary') {
                  final text = await _ask(l10n.tripSummaryHint, initial: p.summary, lines: 3);
                  if (text != null) await _do(() => api.update(_id, title: p.title, summary: text));
                }
                if (v == 'delete' && await _confirm(l10n.tripDeleteConfirm, l10n.commonDelete)) {
                  await api.delete(_id);
                  navigator.pop();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.tripTitleHint)),
                PopupMenuItem(value: 'summary', child: Text(l10n.tripSummaryHint)),
                PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null || _failed
          ? Center(child: OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Row(children: [
                  Expanded(child: Text((p.summary ?? '').isEmpty ? l10n.tripSummaryHint : p.summary!, style: theme.textTheme.bodyMedium?.copyWith(color: (p.summary ?? '').isEmpty ? theme.hintColor : null))),
                  Text(p.isPublished ? l10n.tripPublished : l10n.tripDraft, style: TextStyle(color: p.isPublished ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                for (var i = 0; i < p.days.length; i++) _dayCard(context, p, p.days[i], i),
                OutlinedButton.icon(onPressed: () => _do(() => api.addDay(_id, null)), icon: const Icon(Icons.add), label: Text(l10n.tripAddDay)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _do(() => api.publish(_id, !p.isPublished)),
                  child: Text(p.isPublished ? l10n.tripUnpublish : l10n.tripPublish),
                ),
              ],
            ),
    );
  }

  Widget _dayCard(BuildContext context, TripProgram p, TripDay day, int index) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final api = ref.read(tripProgramsApiProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(l10n.tripDayLabel(index + 1), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
              const SizedBox(width: 8),
              Expanded(child: Text(day.title ?? '', style: theme.textTheme.titleSmall)),
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.arrow_upward, size: 18), onPressed: index == 0 ? null : () => _do(() => api.moveDay(_id, day.id, up: true))),
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.arrow_downward, size: 18), onPressed: index == p.days.length - 1 ? null : () => _do(() => api.moveDay(_id, day.id, up: false))),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () async {
                  final t = await _ask(l10n.tripDayTitleHint, initial: day.title);
                  if (t != null) await _do(() => api.renameDay(_id, day.id, t));
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () async {
                  if (day.items.isEmpty || await _confirm(l10n.tripDeleteDayConfirm, l10n.commonDelete)) await _do(() => api.removeDay(_id, day.id));
                },
              ),
            ]),
            const SizedBox(height: 8),
            for (var j = 0; j < day.items.length; j++) _itemRow(context, day, day.items[j], j),
            Wrap(spacing: 8, children: [
              ActionChip(avatar: const Icon(Icons.notes, size: 16), label: Text(l10n.tripAddText), onPressed: () => _addText(day)),
              ActionChip(avatar: const Icon(Icons.bed_outlined, size: 16), label: Text(l10n.tripAddRoom), onPressed: () => _addRoom(day)),
              ActionChip(avatar: const Icon(Icons.photo_outlined, size: 16), label: Text(l10n.tripAddPhoto), onPressed: () => _addPhoto(day)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(BuildContext context, TripDay day, TripItem item, int index) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final api = ref.read(tripProgramsApiProvider);

    final Widget content;
    if (item.kind == TripItemKind.room) {
      content = item.room == null
          ? Text(l10n.tripRoomGone, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error))
          : TripRoomTile(room: item.room!);
    } else {
      content = TripItemView(item: item);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: content),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'up') await _do(() => api.moveItem(_id, item.id, up: true));
              if (v == 'down') await _do(() => api.moveItem(_id, item.id, up: false));
              if (v == 'delete') await _do(() => api.removeItem(_id, item.id));
              if (v == 'edit') {
                final text = await _ask(l10n.tripAddText, initial: item.body, lines: 3);
                if (text != null && (item.kind != TripItemKind.text || text.isNotEmpty)) await _do(() => api.updateItem(_id, item.id, text));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.pshEdit)),
              if (index > 0) PopupMenuItem(value: 'up', child: Text(l10n.tripMoveUp)),
              if (index < day.items.length - 1) PopupMenuItem(value: 'down', child: Text(l10n.tripMoveDown)),
              PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The rooms a hotel gave the company, as cards to pick from — each at the price the company set.
class _RoomPicker extends ConsumerWidget {
  final String title;

  const _RoomPicker({required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(tripRoomCardsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, scroll) => Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(tripRoomCardsProvider), child: Text(l10n.commonRetry))),
            data: (rooms) => rooms.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.tripNoRooms, textAlign: TextAlign.center)))
                : ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: rooms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => InkWell(onTap: () => Navigator.of(context).pop(rooms[i]), child: IgnorePointer(child: TripRoomTile(room: rooms[i]))),
                  ),
          ),
        ),
      ]),
    );
  }
}
