import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/posts_controller.dart';
import 'create_job_screen.dart';
import 'my_posts_screen.dart';

/// The business's own posted-jobs management, reached from the drawer.
/// Used to be a third Home dashboard tab alongside the feed and My Posts —
/// moved out on its own since it's checked far less often than either of
/// those. [MyJobsTab] itself is unchanged; it just needed a
/// [NestedScrollView] ancestor to satisfy its [SliverOverlapInjector], so
/// this wraps it in one with an empty header instead of a collapsing one.
class MyJobsScreen extends ConsumerWidget {
  const MyJobsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateJobScreen()));
    if (created == true) {
      ref.read(myJobsControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.postsTabJobs)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.jobsCreateTitle),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => const [],
        body: const MyJobsTab(),
      ),
    );
  }
}
