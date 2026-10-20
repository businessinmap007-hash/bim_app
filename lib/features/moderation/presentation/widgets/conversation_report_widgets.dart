import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// A chat message that can be ticked while the person is choosing which messages to show the moderators with his report of
/// the conversation. Outside selection mode it is just its child.
class SelectableMessage extends StatelessWidget {
  final bool selecting;
  final bool selected;
  final VoidCallback onToggle;
  final Widget child;

  const SelectableMessage({
    super.key,
    required this.selecting,
    required this.selected,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!selecting) return child;

    return InkWell(
      onTap: onToggle,
      child: Row(
        children: [
          Checkbox(value: selected, onChanged: (_) => onToggle()),
          Expanded(child: IgnorePointer(child: child)),
        ],
      ),
    );
  }
}

/// The bar above a chat while choosing messages: «اختر الرسائل التي تريد عرضها على المشرف (اختياري)», cancel, continue.
class ReportSelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onCancel;
  final VoidCallback onContinue;

  const ReportSelectionBar({
    super.key,
    required this.count,
    required this.onCancel,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportChatPick,
              style: theme.textTheme.titleSmall,
            ),
            Text(
              l10n.reportChatPickHint(count),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton(onPressed: onCancel, child: Text(l10n.commonCancel)),
                const Spacer(),
                FilledButton(
                  onPressed: onContinue,
                  child: Text(l10n.reportChatContinue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
