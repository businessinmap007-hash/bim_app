import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../chat/presentation/screens/operation_chat_screen.dart';
import '../../application/moderation_providers.dart';
import '../../data/moderation_api.dart';

/// A reported account that a moderator froze (three days, never removed): this is the ONE screen it keeps — what happened,
/// until when, the chat with the moderators (they ask what the report is about, it answers), a refresh and the way out.
class AccountFrozenScreen extends ConsumerWidget {
  final DateTime until;

  /// How many times it has been frozen (this one included) and the count that deletes it.
  final int freezeCount;
  final int freezesToDelete;

  const AccountFrozenScreen({
    super.key,
    required this.until,
    this.freezeCount = 1,
    this.freezesToDelete = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final myCase = ref.watch(myAccountCaseProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.frozenTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(Icons.ac_unit, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.frozenHeadline,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.frozenBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.frozenUntil(
                LocalFormat.date(context).addClock().format(until),
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.error),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.frozenWarnTitle(freezeCount, freezesToDelete),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.frozenWarnBody(freezesToDelete),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            if (myCase?.deletion != null)
              _DeletionCard(deletion: myCase!.deletion!),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.forum_outlined),
              onPressed: myCase == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OperationChatScreen(
                          operationType: 'moderation',
                          operationId: myCase.id,
                          title: l10n.frozenChatTitle,
                        ),
                      ),
                    ),
              label: Text(l10n.frozenChat),
            ),
            if (myCase == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.frozenNoChatYet,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                ref.invalidate(myAccountCaseProvider);
                await ref.read(authControllerProvider.notifier).refreshUser();
              },
              label: Text(l10n.frozenRefresh),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
              child: Text(l10n.frozenLogout),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the account's deletion stands: the panel is deciding, or it is scheduled and the account may still object in writing.
class _DeletionCard extends ConsumerWidget {
  final AccountDeletionState deletion;
  const _DeletionCard({required this.deletion});

  Future<void> _object(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.objectTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          decoration: InputDecoration(hintText: l10n.objectHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.commonSubmit),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(moderationApiProvider).objectToDeletion(text);
      ref.invalidate(myAccountCaseProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final when = deletion.executeAfter == null
        ? ''
        : LocalFormat.date(context).addClock().format(deletion.executeAfter!);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deletion.isScheduled
                  ? l10n.deletionScheduled(when)
                  : l10n.deletionReview,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (deletion.objected)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l10n.deletionObjected),
              ),
            if (deletion.canObject)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  onPressed: () => _object(context, ref),
                  child: Text(l10n.objectAction),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
