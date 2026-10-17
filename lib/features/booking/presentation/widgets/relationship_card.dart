import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/relationship_summary.dart';

/// «تعاملاتك مع هذا النشاط» / «تعاملات هذا العميل معك»: how often the two dealt, how many succeeded, and whether there was
/// a dispute or any problem. Shown to both parties; nothing is drawn when they have no history yet.
class RelationshipCard extends StatelessWidget {
  final RelationshipSummary summary;

  /// True on the business's own screen (it speaks of «this customer»), false on the customer's (it speaks of «you»).
  final bool forBusiness;

  const RelationshipCard({super.key, required this.summary, this.forBusiness = false});

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final clean = summary.disputes == 0 && summary.notCompleted == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (clean ? AppColors.success : AppColors.warning).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(clean ? Icons.verified_outlined : Icons.info_outline, size: 18, color: clean ? AppColors.success : AppColors.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  forBusiness ? l10n.relationshipTitleBusiness : l10n.relationshipTitleCustomer,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.relationshipSummaryLine(summary.total, summary.completed, summary.notCompleted), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            summary.disputes == 0 ? l10n.relationshipNoDisputes : l10n.relationshipDisputes(summary.disputes, summary.openDisputes),
            style: theme.textTheme.bodySmall?.copyWith(color: summary.disputes == 0 ? AppColors.success : AppColors.warning),
          ),
        ],
      ),
    );
  }
}
