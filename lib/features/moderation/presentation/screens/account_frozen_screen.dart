import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../chat/presentation/screens/operation_chat_screen.dart';
import '../../application/moderation_providers.dart';

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
