import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../training/application/training_providers.dart';
import '../../application/training_templates_providers.dart';
import '../../data/models/training_template.dart';

/// Apply a template to a client: find them by their EXACT phone or e-mail (the
/// same rule as the business web panel — never a people-finder), choose how many
/// weeks it runs and when it starts, and the plan is created and sent to the
/// client to accept. Returns the new plan's id, or null when dismissed.
Future<int?> showApplyTemplateSheet(BuildContext context, TrainingTemplate template) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ApplyTemplateSheet(template: template),
  );
}

class _ApplyTemplateSheet extends ConsumerStatefulWidget {
  final TrainingTemplate template;
  const _ApplyTemplateSheet({required this.template});

  @override
  ConsumerState<_ApplyTemplateSheet> createState() => _ApplyTemplateSheetState();
}

class _ApplyTemplateSheetState extends ConsumerState<_ApplyTemplateSheet> {
  final _term = TextEditingController();
  late final _weeks = TextEditingController(text: widget.template.durationWeeks?.toString() ?? '');
  DateTime _start = DateTime.now();
  ({int id, String name, String phone})? _client;
  bool _searched = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _term.dispose();
    _weeks.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    final q = _term.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final found = await ref.read(trainingApiProvider).lookupClient(q);
      if (mounted) {
        setState(() {
          _client = found;
          _searched = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e is ApiException ? e.message : AppLocalizations.of(context)!.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _apply() async {
    final client = _client;
    if (client == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final planId = await ref
          .read(trainingTemplatesApiProvider)
          .apply(widget.template.id, clientId: client.id, startsOn: _start, weeks: int.tryParse(_weeks.text.trim()));
      if (mounted) Navigator.of(context).pop(planId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e is ApiException ? e.message : AppLocalizations.of(context)!.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.trainingTemplateApply, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(widget.template.title, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _term,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(labelText: l10n.trainingApplyClientLabel),
                      // A different term is a different (unconfirmed) client.
                      onChanged: (_) => setState(() {
                        _client = null;
                        _searched = false;
                      }),
                      onSubmitted: (_) => _find(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: OutlinedButton(onPressed: _busy ? null : _find, child: Text(l10n.trainingApplyFind)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (_client != null)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${_client!.name} — ${_client!.phone}')),
                  ],
                )
              else if (_searched)
                Text(l10n.trainingApplyClientNotFound, style: TextStyle(color: theme.colorScheme.error))
              else
                Text(l10n.trainingApplyClientHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 12),
              TextField(
                controller: _weeks,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.trainingProgramWeeks),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.trainingApplyStart),
                trailing: Text(material.formatMediumDate(_start)),
                onTap: _pickDate,
              ),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: (_client == null || _busy) ? null : _apply,
                child: _busy
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.trainingApplyCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
