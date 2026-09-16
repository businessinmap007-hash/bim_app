import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/posts/application/posts_controller.dart';
import '../../features/posts/presentation/screens/create_post_screen.dart';
import '../../l10n/app_localizations.dart';

/// Sits next to [NotificationBellButton] on a home screen's AppBar —
/// creating a post is a primary action reachable from wherever the feed
/// lives, not a button buried inside the feed screen itself. Job creation
/// has its own place now: the "+" on [MyJobsTab] (see `create_job_fab.dart`),
/// not a shared chooser sheet here — posts and jobs are different enough
/// audiences that picking between them behind one icon just added a tap.
///
/// Business-only, same as job creation: a client's whole surface is
/// search/buy/book/order/apply-to-job/comment/follow, never publishing
/// (PostController::store() refuses a client account server-side too) —
/// self-contained here so both home screens that place this button never
/// need their own `isBusiness` check.
class CreatePostButton extends ConsumerWidget {
  const CreatePostButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthSignedIn || !authState.user.isBusiness) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      tooltip: l10n.postsCreateTitle,
      onPressed: () async {
        final created = await Navigator.of(
          context,
        ).push<bool>(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
        if (created == true) {
          ref.read(myPostsControllerProvider.notifier).load();
        }
      },
    );
  }
}
