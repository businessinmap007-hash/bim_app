import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/investigations_providers.dart';
import '../../data/models/investigation.dart';

/// «النتيجة بتظهر في المعمل وبتكون كنص» — the centre writes (or pastes) each result as TEXT beside its test: it is read
/// in the app, costs a few bytes instead of a photo, and the patient can keep it in their own file. A photo is only for
/// what is not text (a film, a signed paper).
class CenterResultsScreen extends ConsumerStatefulWidget {
  final InvestigationOrder order;
  const CenterResultsScreen({super.key, required this.order});

  @override
  ConsumerState<CenterResultsScreen> createState() => _CenterResultsScreenState();
}

class _CenterResultsScreenState extends ConsumerState<CenterResultsScreen> {
  late final Map<int, TextEditingController> _texts = {
    for (final i in widget.order.items) i.id: TextEditingController(text: i.result ?? ''),
  };
  final _note = TextEditingController();
  final List<String> _photos = [];
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _texts.values) {
      c.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  bool get _ready => _texts.values.any((c) => c.text.trim().isNotEmpty) || _photos.isNotEmpty;

  Future<void> _addPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85, limit: 10);
    if (picked.isNotEmpty && mounted) setState(() => _photos.addAll(picked.map((p) => p.path).take(10 - _photos.length)));
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(investigationsApiProvider).attachResults(
        widget.order.id,
        texts: {for (final e in _texts.entries) if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim()},
        photoPaths: _photos,
        note: _note.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invWriteResults)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.invResultsTextHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 12),
          for (final i in widget.order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _texts[i.id],
                minLines: 2,
                maxLines: 8,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: i.name, alignLabelWithHint: true, hintText: l10n.invResultHint),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _photos.length >= 10 ? null : _addPhotos,
            icon: Icon(_photos.isEmpty ? Icons.add_photo_alternate_outlined : Icons.check_circle_outline),
            label: Text(_photos.isEmpty ? l10n.invAddResultPhotos : l10n.invResultPhotosCount(_photos.length)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.invNotesLabel, alignLabelWithHint: true),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _ready && !_busy ? _send : null,
            child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.invSendResults),
          ),
        ],
      ),
    );
  }
}
