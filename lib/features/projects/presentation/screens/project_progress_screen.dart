import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/assignment/widgets/assignee_widgets.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/customer_project_providers.dart';
import '../../data/models/customer_project_view.dart';
import '../widgets/project_agreement_widgets.dart';

/// The customer's read-only view of the project a business linked to their
/// order/booking — which build stage it reached and the camera evidence for
/// each. No editing here; that's the business's own Projects screen.
class ProjectProgressScreen extends ConsumerWidget {
  final String operationType;
  final int operationId;

  const ProjectProgressScreen({super.key, required this.operationType, required this.operationId});

  /// Main stages (with works inside) as folding cards; a flat project's stages as plain rows.
  List<Widget> _stages(CustomerProjectView view) {
    final byParent = <int, List<CustomerProjectTask>>{};
    for (final t in view.tasks) {
      if (t.parentId != null) byParent.putIfAbsent(t.parentId!, () => []).add(t);
    }

    return [
      for (final t in view.tasks.where((t) => t.parentId == null))
        if (byParent[t.id]?.isNotEmpty ?? false)
          _MainStage(stage: t, works: byParent[t.id]!, view: view, operationType: operationType, operationId: operationId)
        else
          _CustomerTaskTile(task: t, canDecide: !view.viewerIsBusiness, operationType: operationType, operationId: operationId),
    ];
  }

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
              const SizedBox(height: 12),
              _AgreementSection(view: view, operationType: operationType, operationId: operationId),
              const SizedBox(height: 20),
              Text(l10n.projectTasksTitle, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (view.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l10n.projectTasksEmpty),
                )
              else
                ..._stages(view),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerTaskTile extends ConsumerWidget {
  final CustomerProjectTask task;
  final bool canDecide;
  final String operationType;
  final int operationId;
  const _CustomerTaskTile({required this.task, required this.canDecide, required this.operationType, required this.operationId});

  Future<void> _decide(BuildContext context, WidgetRef ref, {required bool approve}) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    String? note;

    if (!approve) {
      final controller = TextEditingController();
      note = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.approvalRejectTitle),
          content: TextField(controller: controller, autofocus: true, minLines: 2, maxLines: 5, decoration: InputDecoration(hintText: l10n.approvalRejectHint)),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: Text(l10n.approvalReject)),
          ],
        ),
      );
      if (note == null || note.isEmpty) return;
    }

    try {
      final api = ref.read(customerProjectApiProvider);
      if (approve) {
        await api.approve(operationType, operationId, task.id);
      } else {
        await api.reject(operationType, operationId, task.id, note!);
      }
      ref.invalidate(customerProjectViewProvider(OperationKey(operationType, operationId)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            if (task.assignee != null) AssigneeLine(task.assignee),
            if ((task.details ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(task.details!, style: Theme.of(context).textTheme.bodySmall)),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: task.progress / 100),
            if (task.items.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: QuantityLines(items: task.items)),
            if (task.approvalStatus == 'approved')
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l10n.approvalApproved, style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            if (task.approvalStatus == 'rejected')
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l10n.approvalRejectedWithNote(task.approvalNote ?? ''), style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            if (task.waitsForMe) ...[
              const SizedBox(height: 8),
              Text(canDecide ? l10n.approvalPendingCustomer : l10n.approvalPendingBusiness, style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w700)),
              if (canDecide)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Expanded(child: FilledButton(onPressed: () => _decide(context, ref, approve: true), child: Text(l10n.approvalApprove))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton(onPressed: () => _decide(context, ref, approve: false), child: Text(l10n.approvalReject))),
                    ],
                  ),
                ),
            ],
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

/// Runs one customer decision and refreshes the view; says why when the server refuses (a balance too low, a missing note…).
Future<void> _decide(BuildContext context, WidgetRef ref, String type, int id, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  final fallback = AppLocalizations.of(context)!.commonSomethingWentWrong;
  try {
    await action();
    ref.invalidate(customerProjectViewProvider(OperationKey(type, id)));
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message.isEmpty ? fallback : e.message)));
  }
}

/// The agreement as the customer sees it: the plan offered to him (agree or decline), the version in force with its dates, the
/// requests for more time or a change of scope waiting for his word, and the history of the quantities.
class _AgreementSection extends ConsumerWidget {
  final CustomerProjectView view;
  final String operationType;
  final int operationId;

  const _AgreementSection({required this.view, required this.operationType, required this.operationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final block = view.block;
    final a = block.agreement;
    final customer = !view.viewerIsBusiness;
    final api = ref.read(customerProjectApiProvider);

    if (a == null) return const SizedBox.shrink();

    final req = block.requirement;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (req != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              req.customerOk == true ? l10n.guaranteeRequirementMet(req.name) : l10n.guaranteeRequirementNotMet(req.name),
              style: TextStyle(color: req.customerOk == true ? AppColors.success : AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        AgreementSummary(
          agreement: a,
          actions: [
            if (customer && a.isAgreed)
              OutlinedButton(
                onPressed: () async {
                  final choice = await askShift(context, title: l10n.shiftPlanTitle, needReason: true);
                  if (choice == null || !context.mounted) return;
                  await _decide(context, ref, operationType, operationId, () => api.requestShift(operationType, operationId, days: choice.days, newStart: choice.newStart, reason: choice.reason));
                },
                child: Text(l10n.shiftAskPostpone),
              ),
            if (customer && a.isProposed) ...[
              FilledButton(
                onPressed: () => _decide(context, ref, operationType, operationId, () => api.agreeToPlan(operationType, operationId)),
                child: Text(l10n.agreementAgree),
              ),
              OutlinedButton(
                onPressed: () async {
                  final note = await askText(context, title: l10n.agreementDecline, hint: l10n.agreementDeclineHint);
                  if (note == null || !context.mounted) return;
                  await _decide(context, ref, operationType, operationId, () => api.declinePlan(operationType, operationId, note));
                },
                child: Text(l10n.agreementDecline),
              ),
            ],
            OutlinedButton(onPressed: () => showQuantityLog(context, block.log), child: Text(l10n.quantityLogTitle)),
          ],
        ),
        for (final r in block.pendingRequests) ...[
          const SizedBox(height: 8),
          ChangeRequestCard(
            request: r,
            actions: customer && r.requestedByBusiness
                ? [
                    FilledButton(
                      onPressed: () => _decide(context, ref, operationType, operationId, () => api.decideRequest(operationType, operationId, r.id, approve: true)),
                      child: Text(l10n.requestApprove),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final note = await askText(context, title: l10n.requestReject, hint: l10n.agreementDeclineHint);
                        if (note == null || !context.mounted) return;
                        await _decide(context, ref, operationType, operationId, () => api.decideRequest(operationType, operationId, r.id, approve: false, note: note));
                      },
                      child: Text(l10n.requestReject),
                    ),
                  ]
                : const [],
          ),
        ],
      ],
    );
  }
}

/// A main stage of a big project: its progress, the request to start it (the customer approves or declines, and both sides pay
/// the platform's fee on approval), and — folded — its works by place, with their quantities.
class _MainStage extends ConsumerWidget {
  final CustomerProjectTask stage;
  final List<CustomerProjectTask> works;
  final CustomerProjectView view;
  final String operationType;
  final int operationId;

  const _MainStage({required this.stage, required this.works, required this.view, required this.operationType, required this.operationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customer = !view.viewerIsBusiness;
    final api = ref.read(customerProjectApiProvider);

    final byZone = <String, List<CustomerProjectTask>>{};
    for (final w in works) {
      byZone.putIfAbsent(w.zone ?? '', () => []).add(w);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        initiallyExpanded: stage.startRequested,
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
                if (view.block.agreed)
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
          if (customer && stage.startRequested)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => _decide(context, ref, operationType, operationId, () => api.decideStart(operationType, operationId, stage.id, approve: true)),
                    child: Text(l10n.startApproveAction),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final note = await askText(context, title: l10n.startDeclineAction, hint: l10n.agreementDeclineHint);
                      if (note == null || !context.mounted) return;
                      await _decide(context, ref, operationType, operationId, () => api.decideStart(operationType, operationId, stage.id, approve: false, note: note));
                    },
                    child: Text(l10n.startDeclineAction),
                  ),
                ],
              ),
            ),
          for (final entry in byZone.entries) ...[
            if (entry.key.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                child: Align(alignment: AlignmentDirectional.centerStart, child: Text(entry.key, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary))),
              ),
            for (final w in entry.value)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _CustomerTaskTile(task: w, canDecide: customer, operationType: operationType, operationId: operationId),
              ),
          ],
        ],
      ),
    );
  }
}
