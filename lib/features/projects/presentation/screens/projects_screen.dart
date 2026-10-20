import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_project_providers.dart';
import '../../application/projects_providers.dart';
import '../../data/models/project.dart';
import 'project_detail_screen.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';

/// A business's project management timeline (manufacturing/construction):
/// dated, dependent tasks with progress tracking. See
/// Api\V2\BusinessProjectController.
class ProjectsScreen extends ConsumerStatefulWidget {
  /// Open straight on the «new project» sheet, linked to this order / booking (from its chat).
  final OperationKey? linkTo;

  const ProjectsScreen({super.key, this.linkTo});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.linkTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _createProject();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(projectsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final referenceController = TextEditingController();
    DateTime? startsOn;
    DateTime? dueOn;
    String? error;
    int? templateId;
    final link = widget.linkTo;
    if (link != null) titleController.text = l10n.projectForOperation(link.id);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.projectsAdd, style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final plans = ref.watch(projectTemplatesProvider).valueOrNull ?? const [];
                      if (plans.isEmpty) return const SizedBox.shrink();
                      final picked = plans.where((t) => t.id == templateId).firstOrNull;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.projectTemplatePick, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final t in plans)
                                ChoiceChip(
                                  label: Text(t.title),
                                  selected: templateId == t.id,
                                  onSelected: (on) => setSheetState(() {
                                    templateId = on ? t.id : null;
                                    if (on && titleController.text.trim().isEmpty) titleController.text = t.title;
                                  }),
                                ),
                            ],
                          ),
                          if (picked != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                l10n.projectTemplateSummary(picked.stages.length, picked.totalDays),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: l10n.projectTitleLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: l10n.projectDescription),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: referenceController,
                    decoration: InputDecoration(labelText: l10n.projectReference),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.projectStartsOn),
                    trailing: Text(startsOn != null ? _formatDate(context, startsOn!) : '—'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: startsOn ?? EgyptTime.now(),
                        firstDate: EgyptTime.now().subtract(const Duration(days: 365)),
                        lastDate: EgyptTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) setSheetState(() => startsOn = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.projectDueOn),
                    trailing: Text(dueOn != null ? _formatDate(context, dueOn!) : '—'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: dueOn ?? startsOn ?? EgyptTime.now(),
                        firstDate: EgyptTime.now().subtract(const Duration(days: 365)),
                        lastDate: EgyptTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) setSheetState(() => dueOn = picked);
                    },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 4),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.projectTitleRequired);
                        return;
                      }
                      Navigator.of(sheetContext).pop(true);
                    },
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(projectsControllerProvider.notifier).create(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        reference: referenceController.text.trim(),
        startsOn: startsOn,
        dueOn: dueOn,
        templateId: templateId,
        operationType: link?.type,
        operationId: link?.id,
      );
      // the chat card reads this operation's project: let it see the new one
      if (link != null) ref.invalidate(customerProjectViewProvider(link));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(projectsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProject,
        child: const Icon(Icons.add_rounded),
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
                    onPressed: () => ref.read(projectsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.projectsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(projectsControllerProvider.notifier).load(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _ProjectTile(project: state.items[index]);
                },
              ),
            ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;
  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: project.id)),
        ),
        title: Text(project.title),
        subtitle: Text(
          '${_projectStatusLabel(project.status, l10n)} · ${project.progress}%'
          '${project.tasksCount != null ? ' · ${project.tasksCount}' : ''}',
        ),
        trailing: project.isOverdue
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.projectOverdueBadge,
                  style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              )
            : null,
      ),
    );
  }
}

String _formatDate(BuildContext context, DateTime d) => LocalFormat.date(context).format(d);

String _projectStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'planning' => l10n.projectStatusPlanning,
  'active' => l10n.projectStatusActive,
  'on_hold' => l10n.projectStatusOnHold,
  'completed' => l10n.projectStatusCompleted,
  'cancelled' => l10n.projectStatusCancelled,
  _ => status,
};
