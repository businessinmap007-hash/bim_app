import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/projects_providers.dart';
import '../../data/models/project.dart';
import '../../data/models/project_agreement.dart';
import '../../data/models/project_timeline.dart';
import 'project_agreement_widgets.dart';

void _say(ScaffoldMessengerState messenger, String message) => messenger.showSnackBar(SnackBar(content: Text(message)));

String _msg(Object e, AppLocalizations l10n) => e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;

/// The engineer's side of the agreement: offer the plan with a delivery date and a grace, then — once the customer agreed —
/// ask for more time. Requests waiting for the customer are listed under it.
class BusinessAgreementPanel extends ConsumerWidget {
  final int projectId;
  final Project project;
  final AgreementBlock block;

  const BusinessAgreementPanel({super.key, required this.projectId, required this.project, required this.block});

  Future<void> _propose(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    DateTime? starts = project.startsOn != null && project.startsOn!.isAfter(DateTime.now()) ? project.startsOn : DateTime.now().add(const Duration(days: 30));
    DateTime? due = project.dueOn;
    String? guarantee;
    final graceController = TextEditingController(text: '30');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.agreementPropose),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.agreementProposeStart),
                subtitle: Text(l10n.agreementProposeStartHint),
                trailing: Text(starts == null ? '—' : projectDate(ctx, starts!.toIso8601String())),
                onTap: () async {
                  final picked = await showDatePicker(context: ctx, initialDate: starts ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 3)));
                  if (picked != null) setState(() => starts = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.agreementProposeDue),
                trailing: Text(due == null ? '—' : projectDate(ctx, due!.toIso8601String())),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: due ?? EgyptTime.now().add(const Duration(days: 90)),
                    firstDate: EgyptTime.now(),
                    lastDate: EgyptTime.now().add(const Duration(days: 365 * 6)),
                  );
                  if (picked != null) setState(() => due = picked);
                },
              ),
              TextField(controller: graceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.agreementProposeGrace)),
              const SizedBox(height: 12),
              Align(alignment: AlignmentDirectional.centerStart, child: Text(l10n.agreementRequireGuarantee, style: Theme.of(ctx).textTheme.titleSmall)),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(label: Text(l10n.agreementNoGuarantee), selected: guarantee == null, onSelected: (_) => setState(() => guarantee = null)),
                  for (final (code, label) in [('bronze', l10n.guaranteeBronze), ('silver', l10n.guaranteeSilver), ('gold', l10n.guaranteeGold)])
                    ChoiceChip(label: Text(label), selected: guarantee == code, onSelected: (_) => setState(() => guarantee = code)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: due == null || starts == null ? null : () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSubmit)),
          ],
        ),
      ),
    );
    if (ok != true || due == null || starts == null || !context.mounted) return;

    try {
      await ref.read(projectDetailControllerProvider(projectId).notifier).proposeAgreement(
        startsOn: starts!,
        dueOn: due!,
        graceDays: int.tryParse(graceController.text.trim()) ?? 0,
        requiredGuarantee: guarantee,
      );
    } catch (e) {
      _say(messenger, _msg(e, l10n));
    }
  }

  Future<void> _shift(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final choice = await askShift(context, title: l10n.shiftPlanTitle, needReason: block.agreed);
    if (choice == null || !context.mounted) return;

    try {
      final sent = await ref.read(projectDetailControllerProvider(projectId).notifier).shift(days: choice.days, newStart: choice.newStart, reason: choice.reason.isEmpty ? null : choice.reason);
      _say(messenger, sent ? l10n.shiftRequestSent : l10n.shiftApplied);
    } catch (e) {
      _say(messenger, _msg(e, l10n));
    }
  }

  Future<void> _extend(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final days = TextEditingController(text: '15');
    final reason = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.requestExtensionTitle),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: days, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.extensionDays)),
          TextField(controller: reason, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: l10n.extensionReason)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSubmit)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await ref.read(projectDetailControllerProvider(projectId).notifier).requestExtension(extraDays: int.tryParse(days.text.trim()) ?? 0, reason: reason.text.trim());
      _say(messenger, l10n.extensionSent);
    } catch (e) {
      _say(messenger, _msg(e, l10n));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final a = block.agreement;

    if (a == null) {
      if (!project.hasOperation) return Text(l10n.agreementNeedsOperation, style: Theme.of(context).textTheme.bodySmall);

      return OutlinedButton.icon(
        icon: const Icon(Icons.handshake_outlined),
        onPressed: (project.tasksCount ?? 0) == 0 ? null : () => _propose(context, ref),
        label: Text(l10n.agreementPropose),
      );
    }

    final requirement = block.requirement;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AgreementSummary(
          agreement: a,
          actions: [
            if (a.isAgreed) OutlinedButton(onPressed: () => _extend(context, ref), child: Text(l10n.extensionRequest)),
            if (a.isAgreed) OutlinedButton(onPressed: () => _shift(context, ref), child: Text(l10n.shiftPlan)),
            if (a.isProposed) Text(l10n.agreementWaitingCustomer, style: Theme.of(context).textTheme.bodySmall),
            OutlinedButton(onPressed: () => showQuantityLog(context, block.log), child: Text(l10n.quantityLogTitle)),
          ],
        ),
        if (requirement != null) ...[
          const SizedBox(height: 6),
          Text(l10n.guaranteeRequired(requirement.name), style: Theme.of(context).textTheme.bodySmall),
        ],
        for (final r in block.requests.where((r) => r.isPending || r.status == 'rejected').take(5)) ...[
          const SizedBox(height: 8),
          ChangeRequestCard(
            request: r,
            // a postponement the CUSTOMER asked for is answered by the business
            actions: r.isShift && !r.requestedByBusiness
                ? [
                    FilledButton(onPressed: () => ref.read(projectDetailControllerProvider(projectId).notifier).decideShift(r.id, approve: true), child: Text(l10n.requestApprove)),
                    OutlinedButton(
                      onPressed: () async {
                        final note = await askText(context, title: l10n.requestReject, hint: l10n.agreementDeclineHint);
                        if (note == null || !context.mounted) return;
                        await ref.read(projectDetailControllerProvider(projectId).notifier).decideShift(r.id, approve: false, note: note);
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

/// Everything about one work beyond its progress: where it is, its details, and its quantities — the columns, the concrete,
/// the bricks. Changing what was PLANNED after the plan was agreed only sends a request; what was DONE is reported at once.
class TaskDetailSheet extends ConsumerStatefulWidget {
  final int projectId;
  final int taskId;

  const TaskDetailSheet({super.key, required this.projectId, required this.taskId});

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  late final TextEditingController _zone;
  late final TextEditingController _details;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _zone = TextEditingController();
    _details = TextEditingController();
  }

  @override
  void dispose() {
    _zone.dispose();
    _details.dispose();
    super.dispose();
  }

  ProjectTaskRow? _task(ProjectDetailState s) => s.timeline?.tasks.where((t) => t.id == widget.taskId).firstOrNull;

  Future<void> _run(Future<bool> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final sent = await action();
      if (sent) _say(messenger, l10n.itemRequestSent);
    } catch (e) {
      _say(messenger, _msg(e, l10n));
    }
  }

  Future<void> _saveInfo() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(projectDetailControllerProvider(widget.projectId).notifier).updateTaskInfo(widget.taskId, zone: _zone.text.trim(), details: _details.text.trim());
      _say(messenger, l10n.commonSave);
    } catch (e) {
      _say(messenger, _msg(e, l10n));
    }
  }

  Future<void> _editItem(QuantityItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final done = TextEditingController(text: _fmt(item.done));
    final planned = TextEditingController(text: _fmt(item.planned));
    final reason = TextEditingController();

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: done, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: '${l10n.itemDone}${item.unit == null ? '' : ' (${item.unit})'}')),
          TextField(controller: planned, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.itemPlanned)),
          TextField(controller: reason, decoration: InputDecoration(labelText: l10n.itemReason)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop('delete'), child: Text(l10n.commonDelete)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop('save'), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (action == null || !mounted) return;

    final controller = ref.read(projectDetailControllerProvider(widget.projectId).notifier);

    if (action == 'delete') {
      await _run(() => controller.deleteItem(widget.taskId, item.id));

      return;
    }

    final newDone = double.tryParse(done.text.trim());
    final newPlanned = double.tryParse(planned.text.trim());
    await _run(() => controller.updateItem(
      widget.taskId,
      item.id,
      done: newDone != null && newDone != item.done ? newDone : null,
      planned: newPlanned != null && newPlanned != item.planned ? newPlanned : null,
      reason: reason.text.trim().isEmpty ? null : reason.text.trim(),
    ));
  }

  Future<void> _addItem() async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController();
    final unit = TextEditingController();
    final planned = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.itemAdd),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: InputDecoration(labelText: l10n.itemName)),
          TextField(controller: unit, decoration: InputDecoration(labelText: l10n.itemUnit)),
          TextField(controller: planned, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.itemPlanned)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty || !mounted) return;

    await _run(() => ref.read(projectDetailControllerProvider(widget.projectId).notifier).addItem(
      widget.taskId,
      name: name.text.trim(),
      unit: unit.text.trim().isEmpty ? null : unit.text.trim(),
      planned: double.tryParse(planned.text.trim()) ?? 0,
    ));
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(projectDetailControllerProvider(widget.projectId));
    final task = _task(state);

    if (task == null) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));

    if (!_loaded) {
      _zone.text = task.zone ?? '';
      _details.text = task.details ?? '';
      _loaded = true;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(task.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(controller: _zone, decoration: InputDecoration(labelText: l10n.taskZone)),
            const SizedBox(height: 8),
            TextField(controller: _details, minLines: 3, maxLines: 8, decoration: InputDecoration(labelText: l10n.taskDetails)),
            Align(alignment: AlignmentDirectional.centerEnd, child: TextButton(onPressed: _saveInfo, child: Text(l10n.commonSave))),
            const Divider(),
            Row(
              children: [
                Expanded(child: Text(l10n.itemsTitle, style: theme.textTheme.titleSmall)),
                TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add, size: 18), label: Text(l10n.itemAdd)),
              ],
            ),
            if (task.items.isEmpty) Text(l10n.itemsEmpty, style: theme.textTheme.bodySmall) else QuantityLines(items: task.items, onTap: _editItem),
          ],
        ),
      ),
    );
  }
}
