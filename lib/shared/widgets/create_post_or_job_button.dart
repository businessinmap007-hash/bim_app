import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/posts/application/posts_controller.dart';
import '../../features/posts/presentation/screens/create_job_screen.dart';
import '../../features/posts/presentation/screens/create_post_screen.dart';
import '../../l10n/app_localizations.dart';

/// Sits next to [NotificationBellButton] on a home screen's AppBar — creating
/// a post (or, for a business, a job) is a primary action reachable from
/// wherever the feed lives, not a button buried inside the feed screen
/// itself.
class CreatePostOrJobButton extends ConsumerWidget {
  const CreatePostOrJobButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      onPressed: () => openCreatePostOrJobChoice(context, ref),
    );
  }
}

/// The post-vs-job picker sheet, then the chosen create screen, then a
/// refresh of whichever list just gained a row. Shared by both home screens
/// so a business and a customer get the identical entry point.
Future<void> openCreatePostOrJobChoice(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final authState = ref.read(authControllerProvider);
  final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;

  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(l10n.postsCreateChoicePost),
            onTap: () => Navigator.of(context).pop('post'),
          ),
          if (isBusiness)
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: Text(l10n.postsCreateChoiceJob),
              onTap: () => Navigator.of(context).pop('job'),
            ),
        ],
      ),
    ),
  );

  if (!context.mounted || choice == null) return;

  if (choice == 'post') {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
    if (created == true) {
      ref.read(myPostsControllerProvider.notifier).load();
    }
  } else {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateJobScreen()));
    if (created == true) {
      ref.read(myJobsControllerProvider.notifier).load();
    }
  }
}
