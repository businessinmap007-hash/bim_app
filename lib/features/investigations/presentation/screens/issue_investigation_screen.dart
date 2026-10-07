import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/investigations_providers.dart';

/// «الطبيب يطلب تحاليل وأشعة» — a doctor orders lab tests and radiology exams for a patient, picked from the platform's
/// own lists (like picking a medicine from the dictionary), never typed. The patient then shares the order with a
/// registered centre.
class IssueInvestigationScreen extends ConsumerStatefulWidget {
  final int patientId;
  final String? patientName;

  const IssueInvestigationScreen({super.key, required this.patientId, this.patientName});

  @override
  ConsumerState<IssueInvestigationScreen> createState() => _IssueInvestigationScreenState();
}

class _IssueInvestigationScreenState extends ConsumerState<IssueInvestigationScreen> {
  String _kind = 'lab';
  String _query = '';
  final Set<int> _picked = {};
  final _notes = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    try {
      await ref.read(investigationsApiProvider).issue(
        patientId: widget.patientId,
        optionIds: _picked.toList(),
        notes: _notes.text.trim(),
      );
      ref.invalidate(issuedInvestigationOrdersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invIssued)));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(investigationCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invIssueTitle),
        bottom: widget.patientName == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(l10n.invIssueForPatient(widget.patientName!), style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ),
              ),
      ),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(investigationCatalogProvider),
        builder: (context, catalog) {
          final all = _kind == 'lab' ? catalog.lab : catalog.radiology;
          final q = _query.trim().toLowerCase();
          final shown = q.isEmpty ? all : all.where((t) => t.name.toLowerCase().contains(q)).toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'lab', label: Text(l10n.invTabLab)),
                          ButtonSegment(value: 'radiology', label: Text(l10n.invTabRadiology)),
                        ],
                        selected: {_kind},
                        onSelectionChanged: (s) => setState(() {
                          _kind = s.first;
                          _query = '';
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(hintText: l10n.invSearchHint, prefixIcon: const Icon(Icons.search), isDense: true),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 8),
                    for (final t in shown)
                      Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: CheckboxListTile(
                          value: _picked.contains(t.id),
                          onChanged: (on) => setState(() => on == true ? _picked.add(t.id) : _picked.remove(t.id)),
                          title: Text(t.name),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: l10n.invNotesLabel, alignLabelWithHint: true),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _picked.isEmpty ? l10n.invNothingSelected : l10n.invSelectedCount(_picked.length),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _picked.isEmpty || _sending ? null : _send,
                          child: _sending
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(l10n.invSendToPatient),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
