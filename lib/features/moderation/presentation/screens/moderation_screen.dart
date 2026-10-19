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

class _Queue extends ConsumerWidget {
  final bool handled;
  const _Queue({required this.handled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final queue = ref.watch(reportQueueProvider(handled));

    return queue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e is ApiException ? e.message : '$e',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(reportQueueProvider(handled)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) return Center(child: Text(l10n.modEmpty));

        return RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(reportQueueProvider(handled).future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _ReportedCard(item: items[i], handled: handled),
          ),
        );
      },
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
      ref.invalidate(reportQueueProvider(false));
      ref.invalidate(reportQueueProvider(true));
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
        content: Text(
          widget.item.isPost
              ? l10n.modRemovePostConfirm
              : l10n.modRemoveListingConfirm,
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
                      Text(
                        item.isPost ? l10n.modTypePost : l10n.modTypeListing,
                        style: theme.textTheme.labelSmall,
                      ),
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
            const SizedBox(height: 8),
            if (_busy)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  if (!widget.handled) ...[
                    OutlinedButton(
                      onPressed: () => _run((api) => api.dismiss(item)),
                      child: Text(l10n.modDismiss),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      ),
                      onPressed: _confirmRemove,
                      child: Text(l10n.modRemove),
                    ),
                  ] else if (item.isPost && item.state == 'hidden')
                    OutlinedButton(
                      onPressed: () => _run((api) => api.restore(item)),
                      child: Text(l10n.modRestore),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
