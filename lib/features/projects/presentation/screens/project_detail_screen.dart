import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/assignment/assignment_providers.dart';
import '../../../../core/assignment/widgets/assignee_widgets.dart';
import '../../../media/application/media_picker_service.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/projects_providers.dart';
import '../widgets/business_project_panels.dart';
import '../widgets/project_agreement_widgets.dart';
import '../../data/models/project_agreement.dart';
import '../../data/models/project_timeline.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/local_format.dart';

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
    bool requiresApproval = false;
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
                    trailing: Text(endsOn != null ? _formatDate(context, endsOn!) : '—'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: endsOn ?? startsOn ?? EgyptTime.now(),
                        firstDate: EgyptTime.now().subtract(const Duration(days: 365)),
                        lastDate: EgyptTime.now().add(const Duration(days: 365 * 3)),
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
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: requiresApproval,
                    onChanged: (value) => setSheetState(() => requiresApproval = value),
                    title: Text(l10n.taskRequiresApproval),
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
        requiresApproval: requiresApproval,
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

  /// Main stages (those with works inside) as folding cards; a flat project's works as plain rows.
  List<Widget> _stages(List<ProjectTaskRow> tasks, AgreementBlock block, WidgetRef ref) {
    final byParent = <int, List<ProjectTaskRow>>{};
    for (final t in tasks) {
      if (t.parentId != null) byParent.putIfAbsent(t.parentId!, () => []).add(t);
    }

    return [
      for (final t in tasks.where((t) => t.parentId == null))
        if (byParent[t.id]?.isNotEmpty ?? false)
          _MainStageCard(projectId: projectId, stage: t, works: byParent[t.id]!, agreed: block.agreed)
        else
          _TaskTile(projectId: projectId, task: t),
    ];
  }

  Future<void> _generateBuilding(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final floors = TextEditingController(text: '5');
    final flats = TextEditingController(text: '3');
    bool basement = true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.buildingGenerate),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: floors, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.buildingFloors)),
            TextField(controller: flats, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.buildingFlats)),
            SwitchListTile(contentPadding: EdgeInsets.zero, value: basement, onChanged: (v) => setState(() => basement = v), title: Text(l10n.buildingBasement)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSubmit)),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      final made = await ref.read(projectDetailControllerProvider(projectId).notifier).generateBuilding(
        floors: int.tryParse(floors.text.trim()) ?? 1,
        basement: basement,
        flats: int.tryParse(flats.text.trim()) ?? 0,
      );
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.buildingGenerated(made))));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
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
                  const SizedBox(height: 12),
                  BusinessAgreementPanel(projectId: projectId, project: project, block: state.block),
                  const SizedBox(height: 20),
                  Text(l10n.projectTasksTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (timeline == null || timeline.tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(l10n.projectTasksEmpty),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.apartment_outlined),
                            onPressed: () => _generateBuilding(context, ref),
                            label: Text(l10n.buildingGenerate),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._stages(timeline.tasks, state.block, ref),
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
                Consumer(
                  builder: (context, ref, _) {
                    return AssigneeTile(
                      current: task.assignee,
                      onAssign: (id) async {
                        await ref.read(projectDetailControllerProvider(projectId).notifier).assignTask(task.id, id);
                        final now = ref.read(projectDetailControllerProvider(projectId)).timeline?.tasks.where((t) => t.id == task.id).firstOrNull;
                        return now?.assignee;
                      },
                      onChanged: () => ref.invalidate(businessProvidersProvider),
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera_outlined),
                  onPressed: () => Navigator.of(sheetContext).pop('photo'),
                  label: Text(l10n.taskTakePhoto),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.straighten_outlined),
                  onPressed: () => Navigator.of(sheetContext).pop('details'),
                  label: Text(l10n.taskDetailsTitle),
                ),
                const SizedBox(height: 8),
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
      } else if (result == 'details') {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => TaskDetailSheet(projectId: projectId, taskId: task.id),
        );
      } else if (result == 'photo') {
        final shot = await MediaPickerService().pickFromCamera();
        if (shot != null) await controller.uploadPhoto(task.id, await shot.file.readAsBytes());
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
            if (task.assignee != null) AssigneeLine(task.assignee),
            if (task.items.isNotEmpty)
              Text(task.items.map((i) => '${i.name} ${i.line()}').join(' · '), style: Theme.of(context).textTheme.bodySmall),
            if (task.approvalStatus != null)
              Text(
                switch (task.approvalStatus) {
                  'pending' => l10n.approvalPendingBusiness,
                  'approved' => l10n.approvalApproved,
                  'rejected' => l10n.approvalRejectedWithNote(task.approvalNote ?? ''),
                  _ => '',
                },
                style: TextStyle(
                  color: task.approvalStatus == 'rejected' ? AppColors.error : AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
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

String _formatDate(BuildContext context, DateTime d) => LocalFormat.date(context).format(d);

String _taskStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'pending' => l10n.taskStatusPending,
  'in_progress' => l10n.taskStatusInProgress,
  'blocked' => l10n.taskStatusBlocked,
  'done' => l10n.taskStatusDone,
  _ => status,
};

/// A main stage of a big project (foundations, the frame, finishing…): its progress, whether the customer approved its start,
/// and — folded — its works grouped by place («الدور الثالث / شقة 2»).
class _MainStageCard extends ConsumerWidget {
  final int projectId;
  final ProjectTaskRow stage;
  final List<ProjectTaskRow> works;
  final bool agreed;

  const _MainStageCard({required this.projectId, required this.stage, required this.works, required this.agreed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final byZone = <String, List<ProjectTaskRow>>{};
    for (final w in works) {
      byZone.putIfAbsent(w.zone ?? '', () => []).add(w);
    }

    final started = stage.startStatus == 'approved';
    final canAsk = agreed && !started && stage.startStatus != 'requested';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(children: [Expanded(child: Text(stage.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))), Text('${stage.progress}%')]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(value: stage.progress / 100),
            const SizedBox(height: 4),
            Text(
              [
                l10n.stageWorks(works.length),
                if (agreed)
                  switch (stage.startStatus) {
                    'approved' => l10n.startApproved,
                    'requested' => l10n.startRequested,
                    'declined' => l10n.startDeclined(stage.startNote ?? ''),
                    _ => l10n.startNotRequested,
                  },
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        children: [
          if (canAsk)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FilledButton.tonal(
                  onPressed: () async {
                    try {
                      await ref.read(projectDetailControllerProvider(projectId).notifier).requestStart(stage.id);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.startRequestSent)));
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
                      }
                    }
                  },
                  child: Text(l10n.startRequest),
                ),
              ),
            ),
          if (stage.status != 'done')
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton.icon(
                  icon: const Icon(Icons.event_repeat_outlined, size: 18),
                  label: Text(l10n.shiftStage),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final choice = await askShift(context, title: l10n.shiftStageTitle(stage.title), needReason: agreed);
                    if (choice == null || !context.mounted) return;
                    try {
                      final sent = await ref.read(projectDetailControllerProvider(projectId).notifier).shift(
                        taskId: stage.id,
                        days: choice.days,
                        newStart: choice.newStart,
                        reason: choice.reason.isEmpty ? null : choice.reason,
                      );
                      messenger.showSnackBar(SnackBar(content: Text(sent ? l10n.shiftRequestSent : l10n.shiftApplied)));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
                    }
                  },
                ),
              ),
            ),
          for (final entry in byZone.entries) ...[
            if (entry.key.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                child: Align(alignment: AlignmentDirectional.centerStart, child: Text(entry.key, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary))),
              ),
            for (final w in entry.value) _TaskTile(projectId: projectId, task: w),
          ],
        ],
      ),
    );
  }
}
