import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/hospital_providers.dart';
import 'procedure_widgets.dart';

/// «قرار إجراء جراحي»: the treating physician picks one of his hospital's procedures for the patient of the visit and
/// sends it as a decision. The patient confirms it (the hospital then schedules) or declines.
Future<bool?> showProcedureDecisionSheet(
  BuildContext context, {
  required int hospitalId,
  required int patientId,
  required String patientName,
  int? appointmentId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DecisionSheet(hospitalId: hospitalId, patientId: patientId, patientName: patientName, appointmentId: appointmentId),
  );
}

class _DecisionSheet extends ConsumerStatefulWidget {
  final int hospitalId;
  final int patientId;
  final String patientName;
  final int? appointmentId;

  const _DecisionSheet({required this.hospitalId, required this.patientId, required this.patientName, this.appointmentId});

  @override
  ConsumerState<_DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends ConsumerState<_DecisionSheet> {
  int? _offeringId;
  bool _sending = false;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    try {
      await ref.read(hospitalApiProvider).decideProcedure(
        patientId: widget.patientId,
        offeringId: _offeringId!,
        notes: _notes.text.trim(),
        appointmentId: widget.appointmentId,
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.procDecisionSent)));
      navigator.pop(true);
    } catch (e) {
      if (mounted) setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final offered = ref.watch(hospitalProceduresProvider(widget.hospitalId));

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.procDecisionTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(widget.patientName, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 8),
            Expanded(
              child: offered.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
                data: (sections) => sections.isEmpty
                    ? Center(child: Text(l10n.procDecisionNone))
                    : ListView(
                        children: [
                          for (final section in sections) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: Text(procedureKindLabel(l10n, section.kind), style: theme.textTheme.titleSmall),
                            ),
                            for (final p in section.procedures)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(_offeringId == p.id ? Icons.radio_button_checked : Icons.radio_button_off),
                                title: Text(p.name),
                                subtitle: Text(procedurePriceText(l10n, p.price)),
                                onTap: () => setState(() => _offeringId = p.id),
                              ),
                          ],
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.procDecisionNotes),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _offeringId == null || _sending ? null : _send,
                child: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.procDecisionSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
