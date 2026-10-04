import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/store_terms.dart';

/// What the store promises, read-only — on its menu page and at checkout. Nothing when it answered nothing.
class StoreTermsView extends StatelessWidget {
  final List<StoreTermGroup> terms;
  const StoreTermsView({super.key, required this.terms});

  @override
  Widget build(BuildContext context) {
    final answered = terms.where((g) => g.answer.isNotEmpty).toList();
    if (answered.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.storeTermsCustomerTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final group in answered)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${group.name}: ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Expanded(child: Text(group.answer, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
