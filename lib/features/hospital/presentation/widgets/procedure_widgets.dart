import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/hospital_procedure.dart';

String procedureKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'surgery' => l10n.procKindSurgery,
  'endoscopy' => l10n.procKindEndoscopy,
  _ => l10n.procKindProcedure,
};

String procedureStatusLabel(AppLocalizations l10n, String status) => switch (status) {
  ProcedureRequestItem.requested => l10n.procStatusRequested,
  ProcedureRequestItem.accepted => l10n.procStatusAccepted,
  ProcedureRequestItem.completed => l10n.procStatusCompleted,
  ProcedureRequestItem.declined => l10n.procStatusDeclined,
  _ => l10n.procStatusCancelled,
};

String formatProcedureMoney(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// A price, or «السعر بعد التقييم» when the hospital quotes after seeing the patient.
String procedurePriceText(AppLocalizations l10n, double? price) =>
    price == null ? l10n.procPriceAfterAssessment : '${formatProcedureMoney(price)} ${l10n.invCurrency}';

/// One request, read by the patient or by the hospital ([forHospital] puts the patient's name first).
class ProcedureRequestCard extends StatelessWidget {
  final ProcedureRequestItem request;
  final bool forHospital;
  final List<Widget> actions;

  const ProcedureRequestCard({super.key, required this.request, this.forHospital = false, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final r = request;
    final who = forHospital ? (r.patientName ?? '') : (r.hospitalName ?? '');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(r.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                Text(procedureStatusLabel(l10n, r.status), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 2),
            Text('${procedureKindLabel(l10n, r.kind)}${who.isEmpty ? '' : ' · $who'}', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            if (forHospital && (r.patientPhone ?? '').isNotEmpty) Text(r.patientPhone!, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(procedurePriceText(l10n, r.price), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (r.scheduledAt != null)
              Text(l10n.procScheduledAt(DateFormat.yMMMEd(locale).add_jm().format(r.scheduledAt!.toLocal())), style: theme.textTheme.bodyMedium)
            else if (r.preferredDate != null)
              Text(l10n.procPreferredDate(DateFormat.yMMMEd(locale).format(r.preferredDate!)), style: theme.textTheme.bodySmall),
            if ((r.notes ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(r.notes!, style: theme.textTheme.bodySmall)),
            if ((r.hospitalNote ?? '').isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 4), child: Text(l10n.procHospitalNote(r.hospitalNote!), style: theme.textTheme.bodySmall)),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}
