import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/business_post.dart';
import '../../../business/presentation/widgets/post_card.dart';
import '../../../comments/presentation/screens/comments_screen.dart';
import '../../application/posts_controller.dart';
import '../../data/models/job_post.dart';
import 'edit_post_screen.dart';

/// The followed-accounts feed tab — public because [BusinessHomeScreen] and
/// [CustomerHomeScreen] both embed it directly on Home; there is no separate
/// "My Posts" screen any more.
///
/// Built as a [CustomScrollView] rather than a plain [ListView]: both host
/// screens wrap this in a [NestedScrollView] so their header (an AppBar,
/// or a business's cover photo) scrolls away instead of permanently eating
/// screen space, and a NestedScrollView's body slivers need
/// [SliverOverlapInjector] to cooperate with its pinned tab bar. Pagination
/// listens via [NotificationListener] instead of an explicit
/// [ScrollController] on purpose — a sliver here must resolve its scroll
/// position from the ambient ScrollController the NestedScrollView provides,
/// which an explicit controller would silently disconnect from.
class FollowedFeedTab extends ConsumerWidget {
  const FollowedFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(followedFeedControllerProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _ErrorRetry(
        onRetry: () => ref.read(followedFeedControllerProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.postsFeedEmpty, textAlign: TextAlign.center),
        ),
      );
    }

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          ref.read(followedFeedControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(followedFeedControllerProvider.notifier).load(),
        child: ResponsiveCenter(
          maxWidth: 800,
          child: Builder(
            builder: (context) => CustomScrollView(
              key: const PageStorageKey('followed_feed'),
              slivers: [
                SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final post = state.items[index];
                      return PostCard(
                        post: post,
                        showAuthor: true,
                        onReact: (reaction) => ref
                            .read(followedFeedControllerProvider.notifier)
                            .react(post.id, reaction),
                        onOpenComments: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CommentsScreen(postId: post.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyPostsTab extends ConsumerWidget {
  const MyPostsTab({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, BusinessPost post) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.postsDeleteConfirmTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.postsDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(myPostsControllerProvider.notifier).remove(post.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myPostsControllerProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _ErrorRetry(
        onRetry: () => ref.read(myPostsControllerProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) return Center(child: Text(l10n.postsMineEmpty));

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          ref.read(myPostsControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(myPostsControllerProvider.notifier).load(),
        child: ResponsiveCenter(
          maxWidth: 800,
          child: Builder(
            builder: (context) => CustomScrollView(
              key: const PageStorageKey('my_posts'),
              slivers: [
                SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final post = state.items[index];
                      return PostCard(
                        post: post,
                        onReact: (reaction) => ref
                            .read(myPostsControllerProvider.notifier)
                            .react(post.id, reaction),
                        onEdit: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EditPostScreen(post: post)),
                        ),
                        onDelete: () => _confirmDelete(context, ref, post),
                        onOpenComments: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CommentsScreen(postId: post.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyJobsTab extends ConsumerWidget {
  const MyJobsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myJobsControllerProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _ErrorRetry(
        onRetry: () => ref.read(myJobsControllerProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) return Center(child: Text(l10n.postsJobsEmpty));

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          ref.read(myJobsControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(myJobsControllerProvider.notifier).load(),
        child: ResponsiveCenter(
          maxWidth: 800,
          child: Builder(
            builder: (context) => CustomScrollView(
              key: const PageStorageKey('my_jobs'),
              slivers: [
                SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _JobTile(job: state.items[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobTile extends StatelessWidget {
  final JobPost job;
  const _JobTile({required this.job});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(job.title, style: theme.textTheme.titleSmall),
                ),
                if (!job.isActive)
                  Chip(
                    label: Text(
                      l10n.postsJobsClosed,
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            if (job.body != null && job.body!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                job.body!,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: theme.hintColor),
                const SizedBox(width: 4),
                Text(
                  l10n.postsJobsApplicantsCount(job.applicantsCount),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.commonSomethingWentWrong),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}
