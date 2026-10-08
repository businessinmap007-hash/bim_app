import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/investigation.dart';

String investigationStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case InvestigationOrder.issued:
      return l10n.invStatusIssued;
    case InvestigationOrder.sent:
      return l10n.invStatusSent;
    case InvestigationOrder.accepted:
      return l10n.invStatusAccepted;
    case InvestigationOrder.ready:
      return l10n.invStatusReady;
    case InvestigationOrder.declined:
      return l10n.invStatusDeclined;
    default:
      return l10n.invStatusCancelled;
  }
}

String investigationKindLabel(AppLocalizations l10n, String kind) => kind == 'radiology' ? l10n.invKindRadiology : l10n.invKindLab;

String formatInvestigationMoney(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String formatInvestigationDate(BuildContext context, DateTime d) => DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_jm().format(d);

/// The status as a small pill — filled with the interactive colour when the results are in.
class InvestigationStatusPill extends StatelessWidget {
  final String status;
  const InvestigationStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final done = status == InvestigationOrder.ready;
    final ended = status == InvestigationOrder.declined || status == InvestigationOrder.cancelled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: done ? scheme.primary : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        investigationStatusLabel(l10n, status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: done ? scheme.onPrimary : (ended ? scheme.error : scheme.onSurface),
        ),
      ),
    );
  }
}

/// The 4-step line of an order: issued → sent → received → results.
class InvestigationSteps extends StatelessWidget {
  final int step;
  const InvestigationSteps({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final labels = [l10n.invStepIssued, l10n.invStepSent, l10n.invStepAccepted, l10n.invStepReady];

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: i + 1 <= step ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: i + 1 <= step ? theme.colorScheme.onPrimary : theme.hintColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: i + 1 == step ? FontWeight.w700 : null),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The tests and exams of an order, one row each, with the centre's price once it has one. [centerChosen] marks a row
/// the centre doesn't price (it isn't in the total and the centre may not do it).
class InvestigationItemRows extends StatelessWidget {
  final List<InvestigationItem> items;
  final bool centerChosen;
  const InvestigationItemRows({super.key, required this.items, this.centerChosen = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  item.isLab ? Icons.biotech_outlined : Icons.medical_information_outlined,
                  size: 18,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                Text(investigationKindLabel(l10n, item.kind), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                if (item.price != null) ...[
                  const SizedBox(width: 10),
                  Text('${formatInvestigationMoney(item.price!)} ${l10n.invCurrency}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ] else if (centerChosen) ...[
                  const SizedBox(width: 10),
                  Text(l10n.invNotPriced, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
