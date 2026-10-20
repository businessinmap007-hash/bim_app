import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../assignee.dart';

/// «اختر مقدّم الخدمة» — the people of a business a customer may book (a barber, a trainer, a technician): «أي مقدّم متاح»
/// first, then each one with his title. Draws nothing when the business has no providers.
class ProviderPicker extends StatelessWidget {
  final List<Assignee> providers;
  final int? selected;
  final ValueChanged<int?> onPick;

  const ProviderPicker({
    super.key,
    required this.providers,
    required this.selected,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(l10n.providerAnyone),
          selected: selected == null,
          onSelected: (_) => onPick(null),
        ),
        for (final p in providers)
          ChoiceChip(
            avatar: CircleAvatar(
              backgroundImage: p.logoUrl == null || p.logoUrl!.isEmpty
                  ? null
                  : NetworkImage(p.logoUrl!),
              child: p.logoUrl == null || p.logoUrl!.isEmpty
                  ? Text(p.name.isEmpty ? '?' : p.name.characters.first)
                  : null,
            ),
            label: Text(p.line),
            selected: selected == p.id,
            onSelected: (_) => onPick(p.id),
          ),
      ],
    );
  }
}
