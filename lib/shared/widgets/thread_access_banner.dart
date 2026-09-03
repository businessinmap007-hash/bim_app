import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chat/application/thread_access_providers.dart';
import '../../features/chat/data/thread_access_api.dart';
import '../../l10n/app_localizations.dart';

/// Lets a chat participant say whether admins may ever read this
/// conversation — see Api\V2\ThreadAccessController. A dismissible strip
/// while undecided, a small "change my answer" affordance afterward. Reused
/// by operation chat and general chat/DMs; both are the same `Thread`
/// concept server-side.
class ThreadAccessBanner extends ConsumerStatefulWidget {
  final int threadId;
  const ThreadAccessBanner({super.key, required this.threadId});

  @override
  ConsumerState<ThreadAccessBanner> createState() => _ThreadAccessBannerState();
}

class _ThreadAccessBannerState extends ConsumerState<ThreadAccessBanner> {
  bool _dismissed = false;
  bool _busy = false;

  Future<void> _respond(bool approve) async {
    setState(() => _busy = true);
    try {
      await ref.read(threadAccessApiProvider).respond(widget.threadId, approve: approve);
      ref.invalidate(threadAccessStatusProvider(widget.threadId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusAsync = ref.watch(threadAccessStatusProvider(widget.threadId));

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        if (status.needsResponse && !_dismissed) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Icon(Icons.privacy_tip_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.threadAccessConsentPrompt, style: Theme.of(context).textTheme.bodySmall),
                ),
                if (_busy)
                  const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                else ...[
                  TextButton(onPressed: () => _respond(true), child: Text(l10n.threadAccessApprove)),
                  TextButton(onPressed: () => _respond(false), child: Text(l10n.threadAccessDecline)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _dismissed = true),
                  ),
                ],
              ],
            ),
          );
        }

        return InkWell(
          onTap: _busy
              ? null
              : () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => _ChangeDecisionSheet(threadId: widget.threadId, current: status),
                ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(
                  status.isApproved ? Icons.lock_open_outlined : Icons.lock_outline,
                  size: 14,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 6),
                Text(
                  status.isApproved ? l10n.threadAccessStatusApproved : l10n.threadAccessStatusDeclined,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChangeDecisionSheet extends ConsumerWidget {
  final int threadId;
  final ThreadAccessStatus current;
  const _ChangeDecisionSheet({required this.threadId, required this.current});

  Future<void> _respond(BuildContext context, WidgetRef ref, bool approve) async {
    await ref.read(threadAccessApiProvider).respond(threadId, approve: approve);
    ref.invalidate(threadAccessStatusProvider(threadId));
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.threadAccessSheetTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.threadAccessConsentPrompt, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: current.isApproved ? null : () => _respond(context, ref, true),
                    child: Text(l10n.threadAccessApprove),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: current.isDeclined ? null : () => _respond(context, ref, false),
                    child: Text(l10n.threadAccessDecline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
