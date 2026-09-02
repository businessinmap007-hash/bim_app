import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/widgets/category_picker_field.dart';
import '../../application/jobs_providers.dart';
import '../../data/models/job_follow.dart';

/// "Follow this field for new vacancies" — Api\V2\JobFollowController. Each
/// follow targets one specialty (CategoryPickerField always drills to a
/// leaf), the same picker job-posting already uses.
class JobFollowsScreen extends ConsumerStatefulWidget {
  const JobFollowsScreen({super.key});

  @override
  ConsumerState<JobFollowsScreen> createState() => _JobFollowsScreenState();
}

class _JobFollowsScreenState extends ConsumerState<JobFollowsScreen> {
  Future<void> _addFollow() async {
    final l10n = AppLocalizations.of(context)!;
    final selection = await showModalBottomSheet<CategorySelection>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SafeArea(
          child: _FollowPickerContent(title: l10n.jobFollowPickTitle),
        ),
      ),
    );
    if (selection == null || !mounted) return;

    try {
      await ref
          .read(jobFollowsControllerProvider.notifier)
          .follow(categoryChildId: selection.childId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.jobFollowed)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(jobFollowsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jobFollowsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFollow,
        icon: const Icon(Icons.add),
        label: Text(l10n.jobFollowAdd),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(jobFollowsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.jobFollowsEmpty))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final follow = state.items[index];
                return _FollowTile(
                  follow: follow,
                  onUnfollow: () => ref.read(jobFollowsControllerProvider.notifier).unfollow(follow.id),
                );
              },
            ),
    );
  }
}

class _FollowTile extends StatelessWidget {
  final JobFollow follow;
  final VoidCallback onUnfollow;
  const _FollowTile({required this.follow, required this.onUnfollow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.notifications_none),
        title: Text(follow.label('#${follow.id}')),
        trailing: TextButton(onPressed: onUnfollow, child: Text(l10n.jobUnfollow)),
      ),
    );
  }
}

class _FollowPickerContent extends StatefulWidget {
  final String title;
  const _FollowPickerContent({required this.title});

  @override
  State<_FollowPickerContent> createState() => _FollowPickerContentState();
}

class _FollowPickerContentState extends State<_FollowPickerContent> {
  CategorySelection? _selection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        CategoryPickerField(
          value: _selection,
          onChanged: (v) => setState(() => _selection = v),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _selection == null ? null : () => Navigator.of(context).pop(_selection),
          child: Text(l10n.jobFollowAdd),
        ),
      ],
    );
  }
}
