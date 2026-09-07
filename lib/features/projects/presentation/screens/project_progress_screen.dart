import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/customer_project_providers.dart';
import '../../data/models/customer_project_view.dart';

/// The customer's read-only view of the project a business linked to their
/// order/booking — which build stage it reached and the camera evidence for
/// each. No editing here; that's the business's own Projects screen.
class ProjectProgressScreen extends ConsumerWidget {
  final String operationType;
  final int operationId;

  const ProjectProgressScreen({super.key, required this.operationType, required this.operationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(customerProjectViewProvider(OperationKey(operationType, operationId)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectProgressTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () =>
                    ref.invalidate(customerProjectViewProvider(OperationKey(operationType, operationId))),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (view) {
          if (view == null) {
            return Center(child: Text(l10n.projectProgressEmpty));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(view.project.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${view.project.progress}%', style: Theme.of(context).textTheme.headlineMedium),
                  if (view.project.isOverdue) ...[
                    const SizedBox(width: 8),
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
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(value: view.project.progress / 100),
              const SizedBox(height: 20),
              Text(l10n.projectTasksTitle, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (view.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l10n.projectTasksEmpty),
                )
              else
                for (final task in view.tasks) _CustomerTaskTile(task: task),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerTaskTile extends StatelessWidget {
  final CustomerProjectTask task;
  const _CustomerTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('${_taskStatusLabel(task.status, l10n)} · ${task.progress}%'),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: task.progress / 100),
            if (task.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: MouseWheelHorizontalScroll(
                  builder: (context, controller) => ListView.separated(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: task.photoUrls.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(task.photoUrls[index], width: 72, height: 72, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _taskStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'pending' => l10n.taskStatusPending,
  'in_progress' => l10n.taskStatusInProgress,
  'blocked' => l10n.taskStatusBlocked,
  'done' => l10n.taskStatusDone,
  _ => status,
};
