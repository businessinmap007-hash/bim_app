import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/time/local_format.dart';
import '../../../chat/presentation/screens/operation_chat_screen.dart';
import '../../application/moderation_providers.dart';
import 'conversation_review_screen.dart';
import 'deletion_proposals_screen.dart';
import '../../data/moderation_api.dart';

/// «الإشراف» — the moderator's tab: what people reported, one row per post or listing, most-reported first. A moderator
/// (any account holding the content ability) dismisses a report, removes the item, or brings a hidden post back.
class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.modTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.how_to_vote_outlined),
              tooltip: l10n.panelTitle,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeletionProposalsScreen()),
              ),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: const Color(0xFFD6A94A),
            tabs: [
              Tab(text: l10n.modOpen),
              Tab(text: l10n.modHandled),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_Queue(handled: false), _Queue(handled: true)],
        ),
      ),
    );
  }
}

class _Queue extends ConsumerStatefulWidget {
  final bool handled;
  const _Queue({required this.handled});

  @override
  ConsumerState<_Queue> createState() => _QueueState();
}

class _QueueState extends ConsumerState<_Queue> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        ref.read(reportQueueProvider(widget.handled).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(reportQueueProvider(widget.handled));
    final controller = ref.read(reportQueueProvider(widget.handled).notifier);

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.load,
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.items.isEmpty) return Center(child: Text(l10n.modEmpty));

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _ReportedCard(item: state.items[i], handled: widget.handled);
        },
      ),
    );
  }
}

class _ReportedCard extends ConsumerStatefulWidget {
  final ReportedItem item;
  final bool handled;
  const _ReportedCard({required this.item, required this.handled});

  @override
  ConsumerState<_ReportedCard> createState() => _ReportedCardState();
}

class _ReportedCardState extends ConsumerState<_ReportedCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(ModerationApi api) action) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await action(ref.read(moderationApiProvider));
      ref.read(reportQueueProvider(false).notifier).load();
      ref.read(reportQueueProvider(true).notifier).load();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The three ways to read a reported conversation, and acting on one of its people.
  Widget _conversationActions(AppLocalizations l10n, ThemeData theme, ReportedItem item) {
    final info = item.conversation!;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        OutlinedButton(
          onPressed: () => _run((api) => api.requestConsent(item)),
          child: Text(l10n.modAskConsent),
        ),
        OutlinedButton(
          onPressed: info.access.iVouched ? null : () => _run((api) => api.vouch(item)),
          child: Text(l10n.modVouch(info.access.approvals, info.access.quorum)),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.menu_book_outlined, size: 18),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ConversationReviewScreen(item: item)),
          ),
          label: Text(l10n.modReadConversation),
        ),
        for (final p in info.parties)
          OutlinedButton(
            onPressed: () => _partyActions(item, p.id, p.name),
            child: Text(p.name),
          ),
        OutlinedButton(
          onPressed: () => _run((api) => api.dismiss(item)),
          child: Text(l10n.modDismiss),
        ),
        TextButton(
          onPressed: () => _run((api) => api.release(item)),
          child: Text(l10n.modRelease),
        ),
      ],
    );
  }

  /// After reading: chat with one of the people, or freeze him.
  Future<void> _partyActions(ReportedItem item, int userId, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(name, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.forum_outlined),
              title: Text(l10n.modOpenChat),
              onTap: () => Navigator.of(ctx).pop('chat'),
            ),
            ListTile(
              leading: const Icon(Icons.ac_unit),
              title: Text(l10n.modFreeze),
              onTap: () => Navigator.of(ctx).pop('freeze'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    if (choice == 'freeze') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(l10n.modFreezeConfirmPlain),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.modFreeze)),
          ],
        ),
      );
      if (ok == true) await _run((api) => api.partyFreeze(item, userId));

      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final caseId = await ref.read(moderationApiProvider).partyChat(item, userId);
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => OperationChatScreen(operationType: 'moderation', operationId: caseId, title: name),
        ),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// Open the chat with the reported account (this also records the moderator as handling it) and go into it.
  Future<void> _openAccountChat() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final item = widget.item;
    setState(() => _busy = true);

    try {
      final caseId = await ref.read(moderationApiProvider).accountChat(item);
      if (!mounted) return;
      setState(() => _busy = false);
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => OperationChatScreen(
            operationType: 'moderation',
            operationId: caseId,
            title: item.title,
          ),
        ),
      );
      ref.read(reportQueueProvider(false).notifier).load();
    } on ApiException catch (e) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// An account is never removed: it is frozen for three days, and the chat with the moderators stays open to it.
  Future<void> _confirmFreeze() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          widget.item.freezeCount + 1 >= widget.item.freezesToDelete
              ? l10n.modFreezeConfirmLast(widget.item.freezesToDelete)
              : l10n.modFreezeConfirmCount(
                  widget.item.freezeCount + 1,
                  widget.item.freezesToDelete,
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.modFreeze),
          ),
        ],
      ),
    );

    if (ok == true) {
      final last = widget.item.freezeCount + 1 >= widget.item.freezesToDelete;
      await _run((api) => api.freezeAccount(widget.item));
      if (last && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.modAccountDeleted)));
      }
    }
  }

  Future<void> _confirmRemove() async {
    if (widget.item.type == 'owner_listing') return _removeListing();

    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          widget.item.type == 'post'
              ? l10n.modRemovePostConfirm
              : l10n.modRemoveCommentConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.modRemove),
          ),
        ],
      ),
    );

    if (ok == true) await _run((api) => api.remove(widget.item));
  }

  /// A listing is removed for a rule it broke, and the stake behind it (a held deposit or the frozen guarantee) is confiscated.
  Future<void> _removeListing() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final List<({String key, String name})> rules;

    try {
      rules = await ref.read(moderationApiProvider).violations();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!mounted) return;

    String? chosen;
    var confiscate = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.modViolationTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup<String>(
                    groupValue: chosen,
                    onChanged: (v) => setLocal(() => chosen = v),
                    child: Column(
                      children: [
                        for (final r in rules)
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: r.key,
                            title: Text(r.name),
                          ),
                      ],
                    ),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: confiscate,
                    onChanged: (v) => setLocal(() => confiscate = v ?? true),
                    title: Text(l10n.modConfiscate),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: chosen == null
                  ? null
                  : () => Navigator.of(ctx).pop(true),
              child: Text(l10n.modRemove),
            ),
          ],
        ),
      ),
    );

    if (ok == true && chosen != null) {
      await _run(
        (api) =>
            api.remove(widget.item, violation: chosen, confiscate: confiscate),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final item = widget.item;
    final stateLabel = switch (item.state) {
      'hidden' => l10n.modStateHidden,
      'gone' => l10n.modStateGone,
      'frozen' => l10n.modStateFrozen,
      _ => l10n.modStateLive,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.imageUrl != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            const SizedBox(width: 72, height: 72),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(switch (item.type) {
                        'post' => l10n.modTypePost,
                        'comment' => l10n.modTypeComment,
                        'account' => l10n.modTypeAccount,
                        'conversation' => l10n.modTypeConversation,
                        _ => l10n.modTypeListing,
                      }, style: theme.textTheme.labelSmall),
                      if (item.title.isNotEmpty)
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      if (item.excerpt.isNotEmpty)
                        Text(
                          item.excerpt,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      if (item.authorName != null)
                        Text(
                          l10n.modByAuthor(item.authorName!),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(l10n.modReportsCount(item.reports)),
                  visualDensity: VisualDensity.compact,
                ),
                for (final r in item.reasons)
                  Chip(
                    label: Text('${r.name} · ${r.count}'),
                    visualDensity: VisualDensity.compact,
                  ),
                Chip(
                  label: Text(stateLabel),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (item.isConversation && item.conversation != null)
              _ConversationBlock(info: item.conversation!),
            for (final d in item.details)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('«$d»', style: theme.textTheme.bodySmall),
              ),
            if (item.isAccount && item.frozenUntil != null)
              Text(
                l10n.frozenUntil(
                  LocalFormat.date(
                    context,
                  ).addClock().format(item.frozenUntil!),
                ),
                style: theme.textTheme.bodySmall,
              ),
            if (item.handledBy != null && widget.handled)
              Text(
                l10n.modHandledBy(item.handledBy!),
                style: theme.textTheme.bodySmall,
              ),
            if (!widget.handled && item.locked)
              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.modInHands(item.handlerName ?? ''),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (_busy)
              const Center(child: CircularProgressIndicator())
            else if (!widget.handled && !item.locked && !item.claimedByMe)
              FilledButton.icon(
                icon: const Icon(Icons.how_to_reg_outlined),
                onPressed: () => _run((api) => api.claim(item)),
                label: Text(l10n.modOpenReport),
              )
            else if (!widget.handled && item.claimedByMe && item.isConversation)
              _conversationActions(l10n, theme, item)
            else if (!widget.handled && item.claimedByMe && item.isAccount)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    onPressed: _openAccountChat,
                    label: Text(l10n.modOpenChat),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _confirmFreeze,
                    child: Text(l10n.modFreeze),
                  ),
                  if (item.state == 'frozen')
                    OutlinedButton(
                      onPressed: () => _run((api) => api.unfreezeAccount(item)),
                      child: Text(l10n.modUnfreeze),
                    ),
                  OutlinedButton(
                    onPressed: () => _run((api) => api.dismiss(item)),
                    child: Text(l10n.modDismiss),
                  ),
                  TextButton(
                    onPressed: () => _run((api) => api.release(item)),
                    child: Text(l10n.modRelease),
                  ),
                ],
              )
            else if (!widget.handled && item.claimedByMe)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  OutlinedButton(
                    onPressed: () => _run((api) => api.dismiss(item)),
                    child: Text(l10n.modDismiss),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _confirmRemove,
                    child: Text(l10n.modRemove),
                  ),
                  TextButton(
                    onPressed: () => _run((api) => api.release(item)),
                    child: Text(l10n.modRelease),
                  ),
                ],
              )
            else if (widget.handled && item.isPost && item.state == 'hidden')
              OutlinedButton(
                onPressed: () => _run((api) => api.restore(item)),
                child: Text(l10n.modRestore),
              ),
          ],
        ),
      ),
    );
  }
}

/// What a reported conversation shows on the moderator's card: who talks, the messages the reporter chose to show, and where
/// the other two ways of reading it (the parties' consent, a quorum of moderators) stand.
class _ConversationBlock extends StatelessWidget {
  final ConversationInfo info;
  const _ConversationBlock({required this.info});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.modConversationParties(info.parties.map((p) => p.name).join(' · ')),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(l10n.modSelectedMessages, style: theme.textTheme.labelLarge),
          if (info.selected.isEmpty)
            Text(l10n.modNoSelectedMessages, style: theme.textTheme.bodySmall)
          else
            for (final m in info.selected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${m.senderName ?? ''}: ${m.body}', style: theme.textTheme.bodyMedium),
              ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(
                  info.access.allConsented
                      ? l10n.modConsentAll
                      : info.access.anyDeclined
                      ? l10n.modConsentDeclined
                      : l10n.modConsentPending,
                ),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(l10n.modQuorumStatus(info.access.approvals, info.access.quorum)),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(info.access.accessible ? l10n.modConversationOpen : l10n.modConversationClosed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
