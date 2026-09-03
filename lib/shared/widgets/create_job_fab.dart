import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/posts/application/posts_controller.dart';
import '../../features/posts/presentation/screens/create_job_screen.dart';
import '../../l10n/app_localizations.dart';

/// A [Scaffold.floatingActionButton] that only shows itself while the "My
/// Jobs" tab is the active one — job creation's own place, separate from
/// [CreatePostButton] in the AppBar. Reads the tab index straight off the
/// ambient [DefaultTabController] so [BusinessHomeScreen] doesn't need to
/// become stateful just to track which tab is showing.
class CreateJobFab extends ConsumerStatefulWidget {
  final int jobsTabIndex;
  const CreateJobFab({super.key, required this.jobsTabIndex});

  @override
  ConsumerState<CreateJobFab> createState() => _CreateJobFabState();
}

class _CreateJobFabState extends ConsumerState<CreateJobFab> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    if (controller != _controller) {
      _controller?.removeListener(_onTabChanged);
      _controller = controller..addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() => setState(() {});

  Future<void> _create() async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateJobScreen()));
    if (created == true) {
      ref.read(myJobsControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onJobsTab = _controller?.index == widget.jobsTabIndex;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: onJobsTab
          ? FloatingActionButton.extended(
              key: const ValueKey('create-job-fab'),
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: Text(l10n.jobsCreateTitle),
            )
          : const SizedBox.shrink(key: ValueKey('create-job-fab-hidden')),
    );
  }
}
