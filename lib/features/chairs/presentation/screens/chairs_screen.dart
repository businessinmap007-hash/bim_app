import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/chairs_providers.dart';
import '../../data/models/service_chair.dart';
import '../widgets/chair_picker.dart';

/// «الكراسي والحلاقون» — the salon's chairs, each with the person at it and a photo. Each chair is a line of its own;
/// the customer picks the person or any free chair.
class ChairsScreen extends ConsumerWidget {
  const ChairsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, {ServiceChair? chair}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChairForm(chair: chair),
    );
    if (saved == true) ref.invalidate(myChairsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(myChairsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chairsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.chairAdd),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(onPressed: () => ref.invalidate(myChairsProvider), child: Text(l10n.commonSomethingWentWrong)),
        ),
        data: (chairs) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(myChairsProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(l10n.chairsIntro, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              if (chairs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(l10n.chairsEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                ),
              for (final c in chairs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      onTap: () => _edit(context, ref, chair: c),
                      leading: ChairAvatar(chair: c, size: 52),
                      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text([?c.subtitle, if (!c.isActive) l10n.chairClosed].join(' · ')),
                      trailing: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChairForm extends ConsumerStatefulWidget {
  final ServiceChair? chair;
  const _ChairForm({this.chair});

  @override
  ConsumerState<_ChairForm> createState() => _ChairFormState();
}

class _ChairFormState extends ConsumerState<_ChairForm> {
  late final TextEditingController _name;
  late final TextEditingController _person;
  String? _photoPath;
  int? _staffUserId;
  bool _removePhoto = false;
  bool _active = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.chair?.name ?? '');
    _person = TextEditingController(text: widget.chair?.personName ?? '');
    _active = widget.chair?.isActive ?? true;
    _staffUserId = widget.chair?.staffUserId;
  }

  @override
  void dispose() {
    _name.dispose();
    _person.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() {
        _photoPath = picked.path;
        _removePhoto = false;
      });
    }
  }

  String _message(Object e, AppLocalizations l10n) => e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty && _person.text.trim().isEmpty && _staffUserId == null) {
      setState(() => _error = l10n.chairNeedsName);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(chairsApiProvider);
    try {
      if (widget.chair == null) {
        await api.create(name: _name.text.trim(), personName: _person.text.trim(), photoPath: _photoPath, staffUserId: _staffUserId);
      } else {
        await api.update(
          widget.chair!.id,
          name: _name.text.trim(),
          personName: _person.text.trim(),
          photoPath: _photoPath,
          isActive: _active,
          removePhoto: _removePhoto,
          staffUserId: _staffUserId,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _message(e, l10n);
        });
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(chairsApiProvider).delete(widget.chair!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _message(e, l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final editing = widget.chair != null;
    final hasPhoto = _photoPath != null || (!_removePhoto && widget.chair?.photoUrl != null);
    final staff = ref.watch(chairStaffProvider).valueOrNull ?? const <ChairStaffMember>[];
    final picked = staff.where((m) => m.userId == _staffUserId).firstOrNull;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(editing ? l10n.chairEdit : l10n.chairAdd, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _photoPath != null
                    ? CircleAvatar(radius: 34, backgroundImage: FileImage(File(_photoPath!)))
                    : ChairAvatar(chair: _removePhoto || widget.chair == null ? null : widget.chair, size: 68),
                const SizedBox(width: 14),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(onPressed: _busy ? null : _pickPhoto, icon: const Icon(Icons.photo_camera_outlined), label: Text(l10n.chairChoosePhoto)),
                      if (hasPhoto)
                        TextButton(
                          onPressed: _busy ? null : () => setState(() {
                            _photoPath = null;
                            _removePhoto = true;
                          }),
                          child: Text(l10n.chairRemovePhoto),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (staff.isNotEmpty) ...[
              const SizedBox(height: 14),
              // a customer account the business took on as staff: its own photo and name sit at the chair
              DropdownButtonFormField<int?>(
                initialValue: staff.any((m) => m.userId == _staffUserId) ? _staffUserId : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.chairFromStaff),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(l10n.chairNotStaff)),
                  for (final m in staff)
                    DropdownMenuItem<int?>(
                      value: m.userId,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: m.photoUrl == null ? null : NetworkImage(m.photoUrl!),
                            child: m.photoUrl == null ? Text(m.name.characters.first) : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text([m.name, if ((m.title ?? '').isNotEmpty) m.title!].join(' · '), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _staffUserId = v),
              ),
              if (picked != null)
                Padding(padding: const EdgeInsets.only(top: 6), child: Text(l10n.chairStaffHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))),
            ],
            const SizedBox(height: 14),
            TextField(controller: _person, decoration: InputDecoration(labelText: l10n.chairPerson)),
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.chairName)),
            if (editing)
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.chairOpen), value: _active, onChanged: (v) => setState(() => _active = v)),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.commonSave),
            ),
            if (editing) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _delete,
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                child: Text(l10n.chairDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
