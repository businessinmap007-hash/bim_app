import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/projects_providers.dart';
import '../../data/models/project_timeline.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final int projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  Future<void> _addTask(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? startsOn;
    DateTime? endsOn;
    bool requiresPhoto = false;
    String? error;

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
                  Text(l10n.projectAddTask, style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: l10n.taskTitleLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.taskNotes),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.projectStartsOn),
                    trailing: Text(startsOn != null ? _formatDate(startsOn!) : '—'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: startsOn ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) setSheetState(() => startsOn = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.projectDueOn),
                    trailing: Text(endsOn != null ? _formatDate(endsOn!) : '—'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: endsOn ?? startsOn ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) setSheetState(() => endsOn = picked);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: requiresPhoto,
                    onChanged: (value) => setSheetState(() => requiresPhoto = value),
                    title: Text(l10n.taskRequiresPhoto),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 4),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.taskTitleRequired);
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
      await ref.read(projectDetailControllerProvider(projectId).notifier).addTask(
        title: titleController.text.trim(),
        notes: notesController.text.trim(),
        startsOn: startsOn,
        endsOn: endsOn,
        requiresPhoto: requiresPhoto,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)),
        );
      }
    }
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.projectDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(projectsControllerProvider.notifier).delete(projectId);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonSomethingWentWrong)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(projectDetailControllerProvider(projectId));
    final project = state.project;
    final timeline = state.timeline;

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.title ?? l10n.projectsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteProject(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: state.isLoading && project == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && project == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(projectDetailControllerProvider(projectId).notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : project == null
          ? const SizedBox.shrink()
          : RefreshIndicator(
              onRefresh: () => ref.read(projectDetailControllerProvider(projectId).notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${project.progress}%', style: Theme.of(context).textTheme.headlineMedium),
                      if (project.isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.projectOverdueBadge,
                            style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: project.progress / 100),
                  if (project.description != null && project.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(project.description!),
                  ],
                  const SizedBox(height: 20),
                  Text(l10n.projectTasksTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (timeline == null || timeline.tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(l10n.projectTasksEmpty),
                    )
                  else
                    for (final task in timeline.tasks) _TaskTile(projectId: projectId, task: task),
                ],
              ),
            ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final int projectId;
  final ProjectTaskRow task;
  const _TaskTile({required this.projectId, required this.task});

  Future<void> _openProgressSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    int progress = task.progress;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text('${l10n.taskProgressLabel}: $progress%'),
                Slider(
                  value: progress.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '$progress%',
                  onChanged: (value) => setSheetState(() => progress = value.round()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop('save'),
                        child: Text(l10n.commonSave),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop('done'),
                        child: Text(l10n.taskMarkDone),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop('delete'),
                  style: OutlinedButton.styleFrom(foregroundColor: Theme.of(sheetContext).colorScheme.error),
                  child: Text(l10n.commonDelete),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == null || !context.mounted) return;
    final controller = ref.read(projectDetailControllerProvider(projectId).notifier);
    try {
      if (result == 'save') {
        await controller.updateTaskProgress(task.id, progress: progress);
      } else if (result == 'done') {
        await controller.updateTaskProgress(task.id, status: 'done');
      } else if (result == 'delete') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(l10n.taskDeleteConfirm),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
            ],
          ),
        );
        if (confirmed == true) await controller.deleteTask(task.id);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _openProgressSheet(context, ref),
        title: Row(
          children: [
            Expanded(child: Text(task.title)),
            if (task.isCritical)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.taskCriticalBadge,
                  style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_taskStatusLabel(task.status, l10n)} · ${task.progress}%'
              '${task.plannedStart != null ? ' · ${task.plannedStart}' : ''}',
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: task.progress / 100),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _taskStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'pending' => l10n.taskStatusPending,
  'in_progress' => l10n.taskStatusInProgress,
  'blocked' => l10n.taskStatusBlocked,
  'done' => l10n.taskStatusDone,
  _ => status,
};
