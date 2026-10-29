import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../inventory/presentation/inventory_labels.dart';
import '../../data/hr_api.dart';
import '../hr_labels.dart';

/// «حضوري ومرتبي» — the employee's own month at one employer: his days, lateness and overtime, his leave balance, his
/// requests (leave, a forgotten punch, overtime) and his payslips once the month is approved. Every call names the
/// employer (X-Business-Id) while the screen is open.
class MyHrScreen extends ConsumerStatefulWidget {
  final int businessId;
  final String businessName;

  const MyHrScreen({super.key, required this.businessId, required this.businessName});

  @override
  ConsumerState<MyHrScreen> createState() => _MyHrScreenState();
}

class _MyHrScreenState extends ConsumerState<MyHrScreen> {
  late final _client = ref.read(apiClientProvider);

  @override
  void initState() {
    super.initState();
    _client.actingBusinessId = widget.businessId;
  }

  @override
  void dispose() {
    _client.actingBusinessId = null;
    super.dispose();
  }

  Future<void> _ask() async {
    final l10n = AppLocalizations.of(context)!;
    final made = await showModalBottomSheet<Map<String, dynamic>>(context: context, isScrollControlled: true, builder: (_) => const _AskSheet());
    if (made == null || !mounted) return;
    try {
      await ref.read(hrApiProvider).ask(made);
      ref.invalidate(hrMeProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.hrRequestSent)));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final me = ref.watch(hrMeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.hrMyWork} — ${widget.businessName}')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _ask, icon: const Icon(Icons.add), label: Text(l10n.hrNewRequest)),
      body: AsyncValueView<HrMe>(
        value: me,
        onRetry: () => ref.invalidate(hrMeProvider),
        builder: (context, d) => ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Row(children: [
                Expanded(child: _Stat(value: '${d.month.total('present')}', label: l10n.hrDaysPresent)),
                Expanded(child: _Stat(value: '${d.month.total('late_minutes')} ${l10n.hrMinutesShort}', label: l10n.hrLateThisMonth)),
                Expanded(child: _Stat(value: '${d.leave['remaining'] ?? 0}', label: l10n.hrLeaveLeft)),
              ]),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(spacing: 4, runSpacing: 4, children: [
                    for (final day in d.month.days)
                      Tooltip(
                        message: '${day.date}: ${HrLabels.status(l10n, day.status)} ${day.checkIn ?? ''}–${day.checkOut ?? ''}',
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: HrLabels.cell(day.status), borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(context).dividerColor)),
                          child: Text(day.date.substring(8), style: const TextStyle(fontSize: 12, color: Color(0xFF1B2433))),
                        ),
                      ),
                  ]),
                ),
              ),
              if (d.requests.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.hrMyRequests, style: Theme.of(context).textTheme.titleMedium),
                for (final r in d.requests.take(10))
                  ListTile(
                    dense: true,
                    title: Text('${HrLabels.kind(l10n, r.kind)} · ${HrLabels.requestStatus(l10n, r.status)}'),
                    subtitle: Text(HrLabels.requestSummary(l10n, r.kind, r.data, r.dateFrom, r.dateTo)),
                    trailing: r.status == 'pending'
                        ? TextButton(
                            onPressed: () async {
                              await ref.read(hrApiProvider).cancelRequest(r.id);
                              ref.invalidate(hrMeProvider);
                            },
                            child: Text(l10n.commonCancel),
                          )
                        : null,
                  ),
              ],
              const SizedBox(height: 8),
              Text(l10n.hrMyPayslips, style: Theme.of(context).textTheme.titleMedium),
              if (d.payslips.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(l10n.hrNoPayslips)),
              for (final p in d.payslips)
                Card(
                  child: ExpansionTile(
                    title: Text(l10n.hrPayslipTitle(p.month ?? '')),
                    subtitle: Text(p.paidAt != null ? l10n.hrPaid : l10n.hrNotPaidYet),
                    trailing: Text('${InvLabels.money(p.net)} ${l10n.stkCurrency}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1F7A44))),
                    children: [
                      for (final line in p.lines)
                        ListTile(
                          dense: true,
                          title: Text(HrLabels.lineLabel(l10n, line)),
                          subtitle: line['detail'] == null ? null : Text('${line['detail']}'),
                          trailing: Text('${line['type'] == 'deduction' ? '−' : '+'}${InvLabels.money((line['amount'] as num?) ?? 0)}'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ]),
        ),
      );
}

/// The three things an employee asks for: leave, a correction of a forgotten punch, overtime.
class _AskSheet extends StatefulWidget {
  const _AskSheet();

  @override
  State<_AskSheet> createState() => _AskSheetState();
}

class _AskSheetState extends State<_AskSheet> {
  String _kind = 'leave';
  String _leaveType = 'annual';
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  final _in = TextEditingController();
  final _out = TextEditingController();
  final _hours = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() {
    for (final c in [_in, _out, _hours, _reason]) {
      c.dispose();
    }
    super.dispose();
  }

  String _ymd(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pick(bool start) async {
    final picked = await showDatePicker(context: context, initialDate: start ? _from : _to, firstDate: DateTime(2024), lastDate: DateTime(2030));
    if (picked != null) setState(() => start ? _from = picked : _to = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'leave', label: Text(l10n.hrKindLeave)),
              ButtonSegment(value: 'correction', label: Text(l10n.hrKindCorrection)),
              ButtonSegment(value: 'overtime', label: Text(l10n.hrKindOvertime)),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 12),
          if (_kind == 'leave')
            DropdownButtonFormField<String>(
              initialValue: _leaveType,
              decoration: InputDecoration(labelText: l10n.hrLeaveType),
              items: [for (final t in ['annual', 'casual', 'sick', 'unpaid']) DropdownMenuItem(value: t, child: Text(HrLabels.leaveType(l10n, t)))],
              onChanged: (v) => setState(() => _leaveType = v ?? 'annual'),
            ),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _pick(true), child: Text('${l10n.hrFrom}: ${_ymd(_from)}'))),
            if (_kind == 'leave') ...[
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => _pick(false), child: Text('${l10n.hrTo}: ${_ymd(_to)}'))),
            ],
          ]),
          if (_kind == 'correction')
            Row(children: [
              Expanded(child: TextField(controller: _in, decoration: InputDecoration(labelText: l10n.hrIn, hintText: 'HH:MM'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _out, decoration: InputDecoration(labelText: l10n.hrOut, hintText: 'HH:MM'))),
            ]),
          if (_kind == 'overtime')
            TextField(controller: _hours, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.hrOvertimeHours)),
          TextField(controller: _reason, decoration: InputDecoration(labelText: l10n.stkReason)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pop(context, <String, dynamic>{
              'kind': _kind,
              'date_from': _ymd(_from),
              if (_kind == 'leave') 'date_to': _ymd(_to),
              if (_kind == 'leave') 'leave_type': _leaveType,
              if (_kind == 'correction' && _in.text.trim().isNotEmpty) 'check_in': _in.text.trim(),
              if (_kind == 'correction' && _out.text.trim().isNotEmpty) 'check_out': _out.text.trim(),
              if (_kind == 'overtime') 'minutes': ((double.tryParse(_hours.text.trim()) ?? 0) * 60).round(),
              if (_reason.text.trim().isNotEmpty) 'reason': _reason.text.trim(),
            }),
            child: Text(l10n.commonSubmit),
          ),
        ],
      ),
    );
  }
}

/// «الموظفون اليوم» — the owner on his phone: who is in today, the requests waiting for his yes, and the month's payroll.
class StaffApprovalsScreen extends ConsumerWidget {
  const StaffApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final board = ref.watch(hrBoardProvider);
    final pending = ref.watch(hrPendingRequestsProvider);
    final payroll = ref.watch(hrPayrollProvider);
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    Future<void> decide(HrRequestRow r, bool approve) async {
      try {
        await ref.read(hrApiProvider).decide(r.id, approve);
        ref.invalidate(hrPendingRequestsProvider);
        ref.invalidate(hrBoardProvider);
      } on ApiException catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hrStaffToday)),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (board.valueOrNull case final b?)
              Builder(builder: (context) {
                final days = b.rows.map((r) => r.month.days.where((d) => d.date == todayKey).firstOrNull).whereType<HrDay>().toList();
                int count(Set<String> s) => days.where((d) => s.contains(d.status)).length;
                return Row(children: [
                  Expanded(child: _Stat(value: '${count({'present', 'late'})}', label: l10n.hrPresent)),
                  Expanded(child: _Stat(value: '${count({'late'})}', label: l10n.hrLate)),
                  Expanded(child: _Stat(value: '${count({'leave', 'unpaid_leave'})}', label: l10n.hrOnLeave)),
                ]);
              }),
            const SizedBox(height: 8),
            Text(l10n.hrAwaitingYou, style: Theme.of(context).textTheme.titleMedium),
            AsyncValueView<List<HrRequestRow>>(
              value: pending,
              onRetry: () => ref.invalidate(hrPendingRequestsProvider),
              builder: (context, rows) => Column(children: [
                if (rows.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(l10n.hrNoPending)),
                for (final r in rows)
                  Card(
                    child: ListTile(
                      title: Text('${r.userName ?? ''} — ${HrLabels.kind(l10n, r.kind)}'),
                      subtitle: Text(HrLabels.requestSummary(l10n, r.kind, r.data, r.dateFrom, r.dateTo)),
                      trailing: Wrap(spacing: 4, children: [
                        IconButton.filled(tooltip: l10n.hrApprove, onPressed: () => decide(r, true), icon: const Icon(Icons.check)),
                        IconButton.outlined(tooltip: l10n.stkReject, onPressed: () => decide(r, false), icon: const Icon(Icons.close)),
                      ]),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            if (payroll.valueOrNull case final run? when run.status == 'draft')
              // white text on navy — dark ink there is unreadable (owner, 2026-10-30)
              Card(
                color: AppColors.primaryNavy,
                child: ListTile(
                  title: Text(l10n.hrPayrollReady(ref.watch(hrMonthProvider)), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  subtitle: Text('${l10n.hrNetToPay}: ${InvLabels.money(run.total('net'))} ${l10n.stkCurrency}', style: const TextStyle(color: Color(0xFFD9DEE7))),
                  trailing: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.accentGold, foregroundColor: AppColors.primaryNavy),
                    onPressed: () async {
                      try {
                        await ref.read(hrApiProvider).approve(ref.read(hrMonthProvider));
                        ref.invalidate(hrPayrollProvider);
                      } on ApiException catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    },
                    child: Text(l10n.hrApprove),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
