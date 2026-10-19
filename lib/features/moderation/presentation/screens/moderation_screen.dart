import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/moderation_providers.dart';
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
          bottom: TabBar(
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

  Future<void> _confirmRemove() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(switch (widget.item.type) {
          'post' => l10n.modRemovePostConfirm,
          'comment' => l10n.modRemoveCommentConfirm,
          _ => l10n.modRemoveListingConfirm,
        }),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final item = widget.item;
    final stateLabel = switch (item.state) {
      'hidden' => l10n.modStateHidden,
      'gone' => l10n.modStateGone,
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
            for (final d in item.details)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('«$d»', style: theme.textTheme.bodySmall),
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
