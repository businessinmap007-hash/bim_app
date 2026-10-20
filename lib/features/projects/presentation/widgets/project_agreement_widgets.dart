import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/project_agreement.dart';

/// «2027-06-30» → «30 يونيو 2027» (the string comes straight from the API).
String projectDate(BuildContext context, String? iso) {
  final d = DateTime.tryParse(iso ?? '');

  return d == null ? (iso ?? '—') : LocalFormat.date(context).format(d);
}

/// The plan as agreed: version, delivery date, end of the grace, who agreed when. The actions (offer / agree / decline /
/// ask for more time) are the caller's [actions] — the business and the customer draw different buttons under the same facts.
class AgreementSummary extends StatelessWidget {
  final AgreementInfo agreement;
  final List<Widget> actions;

  const AgreementSummary({super.key, required this.agreement, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final agreed = agreement.isAgreed;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.agreementTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(agreed ? l10n.agreementStatusAgreed : l10n.agreementStatusProposed, style: const TextStyle(fontSize: 11)),
                  backgroundColor: (agreed ? AppColors.success : AppColors.accentGold).withValues(alpha: 0.15),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.agreementDue(projectDate(context, agreement.dueOn)), style: theme.textTheme.bodyLarge),
            Text(l10n.agreementGrace(projectDate(context, agreement.graceUntil)), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              [
                l10n.agreementVersion(agreement.version),
                if (agreement.customerAgreedAt != null) l10n.agreementAgreedOn(LocalFormat.date(context).addClock().format(agreement.customerAgreedAt!)),
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            if (agreement.contentHash.length >= 12) Text('#${agreement.contentHash.substring(0, 12)}', style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

/// A request for more time or a change of scope. [actions] are the customer's approve / reject; the business sees it as a status.
class ChangeRequestCard extends StatelessWidget {
  final ChangeRequestInfo request;
  final List<Widget> actions;

  const ChangeRequestCard({super.key, required this.request, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = request.payload;

    final line = request.isExtension
        ? l10n.requestExtensionLine((p['extra_days'] as num?)?.toInt() ?? 0, projectDate(context, p['grace_until'] as String?))
        : request.isShift
        ? l10n.requestShiftLine((p['days'] as num?)?.toInt() ?? 0, p['scope'] == 'stage' ? l10n.shiftScopeStage : l10n.shiftScopePlan)
        : switch (p['op']) {
            'planned' => l10n.requestScopePlanned('${p['from']}', '${p['to']}'),
            'add' => l10n.requestScopeAdd('${p['name']}', '${p['planned']}'),
            'delete' => l10n.requestScopeDelete('${p['name']}'),
            _ => l10n.requestScopeLine,
          };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            if ((request.note ?? '').isNotEmpty) Text(request.note!, style: theme.textTheme.bodyMedium),
            if (!request.isPending)
              Text(
                request.status == 'approved' ? l10n.requestApproved : l10n.requestRejectedWith(request.decisionNote ?? ''),
                style: TextStyle(color: request.status == 'approved' ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            if (request.isPending && actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

/// «عدد الأعمدة — 18 / 24 عمود» with its bar.
class QuantityLines extends StatelessWidget {
  final List<QuantityItem> items;
  final void Function(QuantityItem item)? onTap;

  const QuantityLines({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final i in items)
          InkWell(
            onTap: onTap == null ? null : () => onTap!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(i.name, style: theme.textTheme.bodyMedium)),
                      Text(i.line(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (onTap != null) ...[const SizedBox(width: 6), Icon(Icons.edit_outlined, size: 16, color: theme.hintColor)],
                    ],
                  ),
                  const SizedBox(height: 2),
                  LinearProgressIndicator(value: i.ratio, minHeight: 4),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The history of the quantities, for the customer and the business to read.
Future<void> showQuantityLog(BuildContext context, List<QuantityLogEntry> log) {
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (ctx, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(l10n.quantityLogTitle, style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (log.isEmpty) Text(l10n.quantityLogEmpty),
          for (final e in log)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text('${e.task ?? ''} — ${_fieldLabel(l10n, e.field)}: ${e.oldValue == null ? '' : '${e.oldValue} ← '}${e.newValue ?? ''}'),
              subtitle: Text([
                if (e.by != null) e.by!,
                if (e.at != null) LocalFormat.date(ctx).addClock().format(e.at!),
                if (e.viaRequest) l10n.quantityLogViaRequest,
                if ((e.reason ?? '').isNotEmpty) e.reason!,
              ].join(' · ')),
            ),
        ],
      ),
    ),
  );
}

String _fieldLabel(AppLocalizations l10n, String field) => switch (field) {
  'planned' => l10n.itemPlanned,
  'done' => l10n.itemDone,
  'created' => l10n.quantityLogCreated,
  'deleted' => l10n.quantityLogDeleted,
  'name' => l10n.itemName,
  'unit' => l10n.itemUnit,
  _ => field,
};

/// What the person chose when postponing: a number of days (a week = 7, a month = 30) or a later start date, and a reason.
class ShiftChoice {
  final int? days;
  final DateTime? newStart;
  final String reason;

  const ShiftChoice({this.days, this.newStart, this.reason = ''});
}

/// «ترحيل»: a week, two weeks, a month, or a chosen start date — and why. [needReason] once the plan is agreed (the other side
/// reads it); [title] says what is being moved. Returns null when cancelled.
Future<ShiftChoice?> askShift(BuildContext context, {required String title, required bool needReason}) {
  final l10n = AppLocalizations.of(context)!;
  final reason = TextEditingController();
  int? days = 7;
  DateTime? picked;

  return showDialog<ShiftChoice>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final (label, d) in [(l10n.shiftWeek, 7), (l10n.shiftTwoWeeks, 14), (l10n.shiftMonth, 30)])
                    ChoiceChip(label: Text(label), selected: picked == null && days == d, onSelected: (_) => setState(() { days = d; picked = null; })),
                  ChoiceChip(
                    label: Text(picked == null ? l10n.shiftPickDate : projectDate(ctx, picked!.toIso8601String())),
                    selected: picked != null,
                    onSelected: (_) async {
                      final d = await showDatePicker(context: ctx, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 3)));
                      if (d != null) setState(() { picked = d; days = null; });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: reason, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: l10n.extensionReason)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () {
              if (needReason && reason.text.trim().isEmpty) return;
              Navigator.of(ctx).pop(ShiftChoice(days: days, newStart: picked, reason: reason.text.trim()));
            },
            child: Text(l10n.commonSubmit),
          ),
        ],
      ),
    ),
  );
}

/// Asks for a reason (or a number of days and a reason) in a small dialog; returns null when cancelled.
Future<String?> askText(BuildContext context, {required String title, required String hint, bool required = true, int minLines = 2}) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true, minLines: minLines, maxLines: 5, decoration: InputDecoration(hintText: hint)),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            if (required && text.isEmpty) return;
            Navigator.of(ctx).pop(text);
          },
          child: Text(l10n.commonSubmit),
        ),
      ],
    ),
  );
}
