import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../features/hr/data/hr_api.dart';
import '../../features/hr/presentation/hr_labels.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../desktop_app.dart';
import '../print/suite_print.dart';
import 'attendance_page.dart';
import 'common.dart';

final _selectedSlipProvider = StateProvider.autoDispose<int?>((ref) => null);

/// «مسير المرتبات» — the month: compute the draft from attendance, advances and adjustments; approve and lock it;
/// record each payslip handed over (outside the app); print the payslips. Gross → net is explained line by line.
class PayrollPage extends ConsumerWidget {
  const PayrollPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final month = ref.watch(hrMonthProvider);
    final run = ref.watch(hrPayrollProvider);
    final approved = run.valueOrNull?.status == 'approved';

    Future<void> act(Future<Object?> Function() call) async {
      await suiteRun(context, () async {
        await call();
        return true;
      }, queueable: false);
      ref.invalidate(hrPayrollProvider);
    }

    return SuitePage(
      title: l10n.hrPayrollTitle(month),
      actions: [
        const HrMonthSwitcher(),
        OutlinedButton(onPressed: () => _advance(context, ref), child: Text(l10n.hrNewAdvance)),
        if (!approved) OutlinedButton(onPressed: () => _adjustment(context, ref), child: Text(l10n.hrBonusPenalty)),
        if (!approved) FilledButton(onPressed: () => act(() => ref.read(hrApiProvider).generate(month)), child: Text(l10n.hrGenerate)),
        if (run.valueOrNull?.status == 'draft')
          FilledButton(onPressed: () => act(() => ref.read(hrApiProvider).approve(month)), child: Text(l10n.hrApproveLock)),
        if (run.valueOrNull != null) OutlinedButton.icon(icon: const Icon(Icons.print_outlined), label: Text(l10n.hrPrintAll), onPressed: () => _printAll(context, ref, run.value!)),
      ],
      child: AsyncValueView<HrRun?>(
        value: run,
        onRetry: () => ref.invalidate(hrPayrollProvider),
        builder: (context, r) {
          if (r == null) return Padding(padding: const EdgeInsets.all(24), child: Text(l10n.hrNoRunYet));
          final selected = ref.watch(_selectedSlipProvider);
          final slip = r.payslips.where((p) => p.id == selected).firstOrNull ?? r.payslips.firstOrNull;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(spacing: 8, children: [
                Chip(
                  label: Text(r.status == 'approved' ? l10n.hrApprovedLocked : l10n.hrDraft, style: TextStyle(color: r.status == 'approved' ? Colors.white : null)),
                  backgroundColor: r.status == 'approved' ? const Color(0xFF1F7A44) : null,
                ),
                if ((r.totals['review'] ?? 0) as num > 0) Chip(label: Text(l10n.hrReviewTax), backgroundColor: const Color(0xFFFBF0D9)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: SuiteStat(label: l10n.hrGross, value: '${InvLabels.money(r.total('gross'))} ${l10n.stkCurrency}')),
                Expanded(child: SuiteStat(label: l10n.hrNetToPay, value: '${InvLabels.money(r.total('net'))} ${l10n.stkCurrency}', color: const Color(0xFF1F7A44))),
                Expanded(child: SuiteStat(label: l10n.hrInsuranceBoth, value: '${InvLabels.money(r.total('employee_insurance'))} + ${InvLabels.money(r.total('employer_insurance'))}')),
                Expanded(child: SuiteStat(label: l10n.hrTaxToRemit, value: '${InvLabels.money(r.total('tax'))} ${l10n.stkCurrency}', color: const Color(0xFFB93A22))),
              ]),
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(label: Text(l10n.hrEmployee)),
                      DataColumn(label: Text(l10n.hrLineBasic)),
                      DataColumn(label: Text(l10n.hrAllowances)),
                      DataColumn(label: Text(l10n.hrLineOvertime)),
                      DataColumn(label: Text(l10n.hrLineAttendance)),
                      DataColumn(label: Text(l10n.hrLineAdvance)),
                      DataColumn(label: Text(l10n.hrLineInsurance)),
                      DataColumn(label: Text(l10n.hrLineTax)),
                      DataColumn(label: Text(l10n.hrNet)),
                      DataColumn(label: Text(l10n.hrPaid)),
                      DataColumn(label: Text(l10n.hrEmployeeConfirmed)),
                    ],
                    rows: [
                      for (final p in r.payslips)
                        DataRow(
                          selected: p.id == slip?.id,
                          onSelectChanged: (_) => ref.read(_selectedSlipProvider.notifier).state = p.id,
                          cells: [
                            DataCell(Text(p.userName ?? '', style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(InvLabels.money(p.line('basic')))),
                            DataCell(Text(InvLabels.money(p.line('allowance')))),
                            DataCell(Text(InvLabels.money(p.line('overtime')), style: const TextStyle(color: Color(0xFF1F7A44)))),
                            DataCell(Text(InvLabels.money(p.line('attendance') + p.line('unpaid_leave')), style: const TextStyle(color: Color(0xFFB93A22)))),
                            DataCell(Text(InvLabels.money(p.line('advance')), style: const TextStyle(color: Color(0xFFB93A22)))),
                            DataCell(Text(InvLabels.money(p.line('insurance')), style: const TextStyle(color: Color(0xFFB93A22)))),
                            DataCell(Text(InvLabels.money(p.line('tax')), style: const TextStyle(color: Color(0xFFB93A22)))),
                            DataCell(Text(InvLabels.money(p.net), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(p.paidAt != null
                                ? Text(p.paidMethod == 'transfer' ? l10n.suiteTransferMoney : l10n.suiteCash)
                                : (r.status == 'approved'
                                    ? TextButton(onPressed: () => _paid(context, ref, p), child: Text(l10n.hrRecordPaid))
                                    : const Text('—'))),
                            DataCell(p.receivedAt != null
                                ? const Icon(Icons.verified_outlined, color: Color(0xFF1F7A44))
                                : Text(r.status == 'approved' ? l10n.hrNotConfirmedYet : '—')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              if (slip != null) _Explain(slip: slip),
            ],
          );
        },
      ),
    );
  }

  Future<void> _paid(BuildContext context, WidgetRef ref, HrPayslip p) async {
    final l10n = AppLocalizations.of(context)!;
    final method = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('${l10n.hrRecordPaid} — ${p.userName ?? ''}'),
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(l10n.hrPaidOutsideHint, style: Theme.of(ctx).textTheme.bodySmall)),
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'cash'), child: Text(l10n.suiteCash)),
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'transfer'), child: Text(l10n.suiteTransferMoney)),
        ],
      ),
    );
    if (method == null || !context.mounted) return;
    await suiteRun(context, () async {
      await ref.read(hrApiProvider).markPaid(p.id, method);
      return true;
    }, queueable: false);
    ref.invalidate(hrPayrollProvider);
  }

  Future<void> _printAll(BuildContext context, WidgetRef ref, HrRun run) async {
    for (final p in run.payslips) {
      await printPayslip(context, ref, p, ref.read(hrMonthProvider));
    }
  }

  Future<void> _advance(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final employees = await ref.read(hrApiProvider).employees();
    if (!context.mounted) return;
    int? who;
    final amount = TextEditingController();
    final count = TextEditingController(text: '6');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.hrNewAdvance),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: l10n.hrEmployee),
              items: [for (final e in employees) DropdownMenuItem(value: e.userId, child: Text(e.name))],
              onChanged: (v) => setState(() => who = v),
            ),
            NumField(controller: amount, label: l10n.suiteAmount, width: 300),
            NumField(controller: count, label: l10n.hrInstallments, width: 300),
            Text(l10n.hrAdvanceFrom(ref.read(hrMonthProvider)), style: Theme.of(ctx).textTheme.bodySmall),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
          ],
        ),
      ),
    );
    if (ok == true && who != null && (parseNum(amount.text) ?? 0) > 0 && context.mounted) {
      await suiteRun(context, () async {
        await ref.read(hrApiProvider).addAdvance(userId: who!, amount: parseNum(amount.text)!.toDouble(), installments: (parseNum(count.text) ?? 1).toInt(), firstMonth: ref.read(hrMonthProvider));
        return true;
      }, queueable: false);
    }
    amount.dispose();
    count.dispose();
  }

  Future<void> _adjustment(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final employees = await ref.read(hrApiProvider).employees();
    if (!context.mounted) return;
    int? who;
    var kind = 'bonus';
    final amount = TextEditingController();
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.hrBonusPenalty),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: l10n.hrEmployee),
              items: [for (final e in employees) DropdownMenuItem(value: e.userId, child: Text(e.name))],
              onChanged: (v) => setState(() => who = v),
            ),
            SegmentedButton<String>(
              segments: [ButtonSegment(value: 'bonus', label: Text(l10n.hrLineBonus)), ButtonSegment(value: 'penalty', label: Text(l10n.hrLinePenalty))],
              selected: {kind},
              onSelectionChanged: (s) => setState(() => kind = s.first),
            ),
            NumField(controller: amount, label: l10n.suiteAmount, width: 300),
            TextField(controller: reason, decoration: InputDecoration(labelText: l10n.stkReason)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
          ],
        ),
      ),
    );
    if (ok == true && who != null && (parseNum(amount.text) ?? 0) > 0 && reason.text.trim().isNotEmpty && context.mounted) {
      await suiteRun(context, () async {
        await ref.read(hrApiProvider).addAdjustment(userId: who!, month: ref.read(hrMonthProvider), kind: kind, amount: parseNum(amount.text)!.toDouble(), reason: reason.text.trim());
        return true;
      }, queueable: false);
      ref.invalidate(hrPayrollProvider);
    }
    amount.dispose();
    reason.dispose();
  }
}

class _Explain extends ConsumerWidget {
  final HrPayslip slip;
  const _Explain({required this.slip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SuiteSection(
      title: l10n.hrHowCalculated(slip.userName ?? ''),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.print_outlined),
          label: Text(l10n.suitePrint),
          onPressed: () => printPayslip(context, ref, slip, ref.read(hrMonthProvider)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in slip.lines)
            Row(children: [
              Expanded(child: Text('${HrLabels.lineLabel(l10n, line)}${line['detail'] != null ? ' — ${line['detail']}' : ''}')),
              Text('${line['type'] == 'deduction' ? '−' : '+'}${InvLabels.money((line['amount'] as num?) ?? 0)}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: line['type'] == 'deduction' ? const Color(0xFFB93A22) : const Color(0xFF1F7A44))),
            ]),
          const SizedBox(height: 8),
          // white text on the navy block — dark ink on navy is unreadable (owner, 2026-10-30)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(child: Text(l10n.hrNet, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
              Text('${InvLabels.money(slip.net)} ${l10n.stkCurrency}', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w800, fontSize: 20)),
            ]),
          ),
          Text(l10n.hrEmployerInsurance(InvLabels.money(slip.employerInsurance)), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// One payslip on A4: earnings and deductions line by line, the net, and the two signatures.
Future<void> printPayslip(BuildContext context, WidgetRef ref, HrPayslip p, String month) async {
  final l10n = AppLocalizations.of(context)!;
  final pdf = await SuitePrint.document(
    businessName: ref.read(suiteBusinessProvider)?.name ?? '',
    title: l10n.hrPayslipTitle(month),
    facts: [(l10n.hrEmployee, p.userName ?? ''), (l10n.hrGross, InvLabels.money(p.gross)), (l10n.hrDeductions, InvLabels.money(p.deductions))],
    headers: [l10n.hrItem, l10n.hrDetail, l10n.suiteAmount],
    rows: [
      for (final line in p.lines)
        [
          HrLabels.lineLabel(l10n, line),
          '${line['detail'] ?? ''}',
          '${line['type'] == 'deduction' ? '−' : '+'}${InvLabels.money((line['amount'] as num?) ?? 0)}',
        ],
    ],
    totalLabel: l10n.hrNet,
    total: '${InvLabels.money(p.net)} ${l10n.stkCurrency}',
    signatures: [l10n.hrSignAccountant, l10n.hrSignEmployee],
  );
  await ref.read(suitePrintProvider).print(pdf, receipt: false, name: 'payslip-${p.userName ?? p.userId}-$month');
}
