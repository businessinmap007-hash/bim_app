import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/hr/data/hr_api.dart';
import '../../features/hr/presentation/hr_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import 'common.dart';

/// Move the month shown by the attendance and payroll pages.
class HrMonthSwitcher extends ConsumerWidget {
  const HrMonthSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(hrMonthProvider);
    final d = DateTime.parse('$month-01');
    void go(int delta) => ref.read(hrMonthProvider.notifier).state = hrMonthKey(DateTime(d.year, d.month + delta));

    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(onPressed: () => go(-1), icon: const Icon(Icons.chevron_right)),
      Text(month, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      IconButton(onPressed: () => go(1), icon: const Icon(Icons.chevron_left)),
    ]);
  }
}

/// «الحضور» — the month's board (each employee, day by day, from his punches against his shift and the business's
/// rules), the requests waiting for an answer, the employees with their shifts, and the business's own rules.
class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pending = ref.watch(hrPendingRequestsProvider).valueOrNull?.length ?? 0;

    return DefaultTabController(
      length: 4,
      child: SuitePage(
        title: l10n.hrAttendanceTitle,
        scroll: false,
        actions: const [HrMonthSwitcher()],
        child: Column(
          children: [
            TabBar(isScrollable: true, tabs: [
              Tab(text: l10n.hrBoard),
              Tab(text: pending > 0 ? '${l10n.hrRequests} ($pending)' : l10n.hrRequests),
              Tab(text: l10n.hrEmployeesShifts),
              Tab(text: l10n.hrRules),
            ]),
            const Expanded(child: TabBarView(children: [_Board(), _Requests(), _Employees(), _Rules()])),
          ],
        ),
      ),
    );
  }
}

class _Board extends ConsumerWidget {
  const _Board();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AsyncValueView(
      value: ref.watch(hrBoardProvider),
      onRetry: () => ref.invalidate(hrBoardProvider),
      builder: (context, data) {
        if (data.rows.isEmpty) return Center(child: Text(l10n.hrNoEmployees));
        final days = data.rows.first.month.days.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 12, runSpacing: 6, children: [
                for (final s in ['present', 'late', 'absent', 'leave', 'rest'])
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: HrLabels.cell(s), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 6),
                    Text(HrLabels.status(l10n, s)),
                  ]),
              ]),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(26),
                  columnWidths: {0: const FixedColumnWidth(140), days + 1: const FixedColumnWidth(70), days + 2: const FixedColumnWidth(60), days + 3: const FixedColumnWidth(80)},
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      Text(l10n.hrEmployee, style: const TextStyle(fontWeight: FontWeight.w800)),
                      for (var i = 1; i <= days; i++) Center(child: Text('$i', style: Theme.of(context).textTheme.bodySmall)),
                      Text(l10n.hrLate, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(l10n.hrAbsent, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(l10n.hrOvertimeSuggested, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    for (final r in data.rows)
                      TableRow(children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                        for (final d in r.month.days)
                          Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: Tooltip(
                              message: '${d.date}: ${HrLabels.status(l10n, d.status)} ${d.checkIn ?? ''}–${d.checkOut ?? ''}',
                              child: InkWell(
                                onTap: () => _day(context, ref, r, d),
                                child: Container(height: 24, decoration: BoxDecoration(color: HrLabels.cell(d.status), borderRadius: BorderRadius.circular(5))),
                              ),
                            ),
                          ),
                        Text('${r.month.total('late_minutes')} ${l10n.hrMinutesShort}'),
                        Text('${r.month.total('absent')}'),
                        Text('${HrLabels.hours(r.month.total('suggested_overtime_minutes') + r.month.total('suggested_overtime_night_minutes'))} ${l10n.hrHoursShort}'),
                      ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _day(BuildContext context, WidgetRef ref, HrBoardRow row, HrDay day) async {
    final l10n = AppLocalizations.of(context)!;
    final overtime = day.overtimeMinutes + day.overtimeNightMinutes;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${row.name} — ${day.date}'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(HrLabels.status(l10n, day.status), style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('${l10n.hrIn}: ${day.checkIn ?? '—'} · ${l10n.hrOut}: ${day.checkOut ?? '—'}'),
          if (day.lateMinutes > 0) Text('${l10n.hrLate}: ${day.lateMinutes} ${l10n.hrMinutesShort}'),
          if (day.earlyMinutes > 0) Text('${l10n.hrEarly}: ${day.earlyMinutes} ${l10n.hrMinutesShort}'),
          if (day.deduction > 0) Text(l10n.hrDeductionDays(day.deduction.toString())),
          if (overtime > 0) Text('${l10n.hrOvertimeSuggested}: ${HrLabels.hours(day.overtimeMinutes)} + ${HrLabels.hours(day.overtimeNightMinutes)} ${l10n.hrNightShort}'),
        ]),
        actions: [
          if (overtime > 0)
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await suiteRun(context, () async {
                  await ref.read(hrApiProvider).recordForEmployee(
                      {'user_id': row.userId, 'kind': 'overtime', 'date_from': day.date, 'minutes': day.overtimeMinutes, 'night_minutes': day.overtimeNightMinutes});
                  return true;
                }, queueable: false);
                ref.invalidate(hrBoardProvider);
              },
              child: Text(l10n.hrApproveOvertime),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonOk)),
        ],
      ),
    );
  }
}

class _Requests extends ConsumerWidget {
  const _Requests();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> decide(HrRequestRow r, bool approve) async {
      await suiteRun(context, () async {
        await ref.read(hrApiProvider).decide(r.id, approve);
        return true;
      }, queueable: false);
      ref.invalidate(hrPendingRequestsProvider);
      ref.invalidate(hrBoardProvider);
    }

    return AsyncValueView<List<HrRequestRow>>(
      value: ref.watch(hrPendingRequestsProvider),
      onRetry: () => ref.invalidate(hrPendingRequestsProvider),
      builder: (context, rows) => rows.isEmpty
          ? Center(child: Text(l10n.hrNoPending))
          : ListView(
              padding: const EdgeInsets.only(top: 12),
              children: [
                for (final r in rows)
                  Card(
                    child: ListTile(
                      title: Text('${r.userName ?? ''} — ${HrLabels.kind(l10n, r.kind)}'),
                      subtitle: Text(HrLabels.requestSummary(l10n, r.kind, r.data, r.dateFrom, r.dateTo) + (r.reason != null ? '\n${r.reason}' : '')),
                      trailing: Wrap(spacing: 8, children: [
                        FilledButton(onPressed: () => decide(r, true), child: Text(l10n.hrApprove)),
                        OutlinedButton(onPressed: () => decide(r, false), child: Text(l10n.stkReject)),
                      ]),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Employees extends ConsumerWidget {
  const _Employees();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shifts = ref.watch(hrShiftsProvider).valueOrNull ?? const <HrShift>[];

    return ListView(
      padding: const EdgeInsets.only(top: 12),
      children: [
        SuiteSection(
          title: l10n.hrShifts,
          actions: [TextButton.icon(icon: const Icon(Icons.add), label: Text(l10n.hrNewShift), onPressed: () => _shift(context, ref))],
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in shifts) ActionChip(label: Text('${s.name} ${s.startsAt}–${s.endsAt}'), onPressed: () => _shift(context, ref, shift: s)),
            if (shifts.isEmpty) Text(l10n.hrNoShifts),
          ]),
        ),
        SuiteSection(
          title: l10n.hrEmployees,
          child: AsyncValueView<List<HrEmployeeRow>>(
            value: ref.watch(hrEmployeesProvider),
            onRetry: () => ref.invalidate(hrEmployeesProvider),
            builder: (context, rows) => Column(children: [
              if (rows.isEmpty) Text(l10n.hrNoEmployees),
              for (final e in rows)
                ListTile(
                  title: Text('${e.name}${e.title != null ? ' · ${e.title}' : ''}'),
                  subtitle: Text([
                    shifts.where((s) => s.id == e.shiftId).firstOrNull?.name ?? l10n.hrNoShift,
                    l10n.hrLeaveBalance('${e.leave['remaining'] ?? 0}', '${e.leave['entitlement'] ?? 0}'),
                    if (e.seesPay) '${l10n.hrLineBasic}: ${e.basicSalary}',
                  ].join(' · ')),
                  trailing: TextButton(onPressed: () => _employee(context, ref, e, shifts), child: Text(l10n.suiteEdit)),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _shift(BuildContext context, WidgetRef ref, {HrShift? shift}) async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController(text: shift?.name);
    final from = TextEditingController(text: shift?.startsAt ?? '09:00');
    final to = TextEditingController(text: shift?.endsAt ?? '17:00');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(shift == null ? l10n.hrNewShift : shift.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: InputDecoration(labelText: l10n.hrShiftName)),
          TextField(controller: from, decoration: InputDecoration(labelText: l10n.hrStartsAt, hintText: 'HH:MM')),
          TextField(controller: to, decoration: InputDecoration(labelText: l10n.hrEndsAt, hintText: 'HH:MM')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await suiteRun(context, () async {
        await ref.read(hrApiProvider).saveShift(id: shift?.id, name: name.text.trim(), startsAt: from.text.trim(), endsAt: to.text.trim());
        return true;
      }, queueable: false);
      ref.invalidate(hrShiftsProvider);
    }
    for (final c in [name, from, to]) {
      c.dispose();
    }
  }

  Future<void> _employee(BuildContext context, WidgetRef ref, HrEmployeeRow e, List<HrShift> shifts) async {
    final l10n = AppLocalizations.of(context)!;
    int? shiftId = e.shiftId;
    final hire = TextEditingController(text: e.hireDate);
    final basic = TextEditingController(text: e.basicSalary?.toString() ?? '');
    final allowances = [
      for (final a in e.allowances) (TextEditingController(text: '${a['name']}'), TextEditingController(text: '${a['amount']}'), a['insurable'] == true),
    ];
    var insured = e.insured;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(e.name),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<int?>(
                  initialValue: shiftId,
                  decoration: InputDecoration(labelText: l10n.hrShift),
                  items: [DropdownMenuItem<int?>(value: null, child: Text(l10n.hrNoShift)), for (final s in shifts) DropdownMenuItem<int?>(value: s.id, child: Text(s.name))],
                  onChanged: (v) => setState(() => shiftId = v),
                ),
                TextField(controller: hire, decoration: InputDecoration(labelText: l10n.hrHireDate, hintText: 'YYYY-MM-DD')),
                if (e.seesPay) ...[
                  NumField(controller: basic, label: l10n.hrLineBasic, width: 520),
                  SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.hrInsured), value: insured, onChanged: (v) => setState(() => insured = v)),
                  for (var i = 0; i < allowances.length; i++)
                    Row(children: [
                      Expanded(child: TextField(controller: allowances[i].$1, decoration: InputDecoration(labelText: l10n.hrAllowanceName, isDense: true))),
                      const SizedBox(width: 8),
                      NumField(controller: allowances[i].$2, label: l10n.suiteAmount),
                      Checkbox(value: allowances[i].$3, onChanged: (v) => setState(() => allowances[i] = (allowances[i].$1, allowances[i].$2, v ?? false))),
                      Text(l10n.hrInsurable),
                    ]),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.hrAddAllowance),
                      onPressed: () => setState(() => allowances.add((TextEditingController(), TextEditingController(), true))),
                    ),
                  ),
                ],
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
          ],
        ),
      ),
    );

    if (ok == true && context.mounted) {
      await suiteRun(context, () async {
        await ref.read(hrApiProvider).updateEmployee(e.userId, {
          'shift_id': shiftId,
          if (hire.text.trim().isNotEmpty) 'hire_date': hire.text.trim(),
          if (e.seesPay && parseNum(basic.text) != null) 'basic_salary': parseNum(basic.text),
          if (e.seesPay) 'insured': insured,
          if (e.seesPay)
            'allowances': [
              for (final a in allowances)
                if (a.$1.text.trim().isNotEmpty && (parseNum(a.$2.text) ?? 0) > 0) {'name': a.$1.text.trim(), 'amount': parseNum(a.$2.text), 'insurable': a.$3},
            ],
        });
        return true;
      }, queueable: false);
      ref.invalidate(hrEmployeesProvider);
    }
    hire.dispose();
    basic.dispose();
  }
}

class _Rules extends ConsumerStatefulWidget {
  const _Rules();

  @override
  ConsumerState<_Rules> createState() => _RulesState();
}

class _RulesState extends ConsumerState<_Rules> {
  final _f = <String, TextEditingController>{};
  Set<int> _rest = {};
  bool _seeded = false;
  final _holidayDate = TextEditingController();
  final _holidayName = TextEditingController();

  TextEditingController _c(String key) => _f.putIfAbsent(key, TextEditingController.new);

  @override
  void dispose() {
    for (final c in [..._f.values, _holidayDate, _holidayName]) {
      c.dispose();
    }
    super.dispose();
  }

  void _seed(Map<String, dynamic> s) {
    if (_seeded) return;
    _seeded = true;
    for (final k in ['grace_minutes', 'absence_day_fraction', 'monthly_cap_days', 'overtime_day_pct', 'overtime_night_pct', 'days_per_month', 'hours_per_day', 'night_from', 'night_to']) {
      _c(k).text = s[k] == null ? '' : '${s[k]}';
    }
    final tiers = (s['late_tiers'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    _c('tier1_upto').text = tiers.isNotEmpty ? '${tiers[0]['upto_minutes'] ?? ''}' : '60';
    _c('tier1_fraction').text = tiers.isNotEmpty ? '${tiers[0]['day_fraction']}' : '0.25';
    _c('tier2_fraction').text = tiers.length > 1 ? '${tiers[1]['day_fraction']}' : '0.5';
    _rest = {...(s['rest_days'] as List<dynamic>? ?? const [5]).map((e) => (e as num).toInt())};
  }

  Future<void> _save() async {
    num? n(String k) => parseNum(_c(k).text);
    await suiteRun(context, () async {
      await ref.read(hrApiProvider).updateSettings({
        'grace_minutes': n('grace_minutes')?.toInt(),
        'late_tiers': [
          {'upto_minutes': n('tier1_upto')?.toInt(), 'day_fraction': n('tier1_fraction') ?? 0.25},
          {'upto_minutes': null, 'day_fraction': n('tier2_fraction') ?? 0.5},
        ],
        'absence_day_fraction': n('absence_day_fraction'),
        'monthly_cap_days': n('monthly_cap_days'),
        'overtime_day_pct': n('overtime_day_pct'),
        'overtime_night_pct': n('overtime_night_pct'),
        'days_per_month': n('days_per_month')?.toInt(),
        'hours_per_day': n('hours_per_day')?.toInt(),
        'night_from': _c('night_from').text.trim(),
        'night_to': _c('night_to').text.trim(),
        'rest_days': _rest.toList(),
      }..removeWhere((k, v) => v == null && k != 'monthly_cap_days'));
      return true;
    }, queueable: false);
    ref.invalidate(hrSettingsProvider);
    ref.invalidate(hrBoardProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = [
      (6, l10n.hrSat), (0, l10n.hrSun), (1, l10n.hrMon), (2, l10n.hrTue), (3, l10n.hrWed), (4, l10n.hrThu), (5, l10n.hrFri),
    ];
    final year = int.parse(ref.watch(hrMonthProvider).substring(0, 4));

    return AsyncValueView<Map<String, dynamic>>(
      value: ref.watch(hrSettingsProvider),
      onRetry: () => ref.invalidate(hrSettingsProvider),
      builder: (context, s) {
        _seed(s);
        return ListView(
          padding: const EdgeInsets.only(top: 12),
          children: [
            SuiteSection(
              title: l10n.hrYourRules,
              actions: [FilledButton(onPressed: _save, child: Text(l10n.commonSave))],
              child: Wrap(spacing: 12, runSpacing: 12, children: [
                NumField(controller: _c('grace_minutes'), label: l10n.hrGrace, width: 170),
                NumField(controller: _c('tier1_upto'), label: l10n.hrTier1Upto, width: 170),
                NumField(controller: _c('tier1_fraction'), label: l10n.hrTier1Fraction, width: 170),
                NumField(controller: _c('tier2_fraction'), label: l10n.hrTier2Fraction, width: 170),
                NumField(controller: _c('absence_day_fraction'), label: l10n.hrAbsenceFraction, width: 170),
                NumField(controller: _c('monthly_cap_days'), label: l10n.hrMonthlyCap, width: 170),
                NumField(controller: _c('overtime_day_pct'), label: l10n.hrOvertimeDayPct, width: 170),
                NumField(controller: _c('overtime_night_pct'), label: l10n.hrOvertimeNightPct, width: 170),
                SizedBox(width: 120, child: TextField(controller: _c('night_from'), decoration: InputDecoration(labelText: l10n.hrNightFrom))),
                SizedBox(width: 120, child: TextField(controller: _c('night_to'), decoration: InputDecoration(labelText: l10n.hrNightTo))),
                NumField(controller: _c('days_per_month'), label: l10n.hrDaysPerMonth, width: 170),
                NumField(controller: _c('hours_per_day'), label: l10n.hrHoursPerDay, width: 170),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.hrRestDays),
                  Wrap(spacing: 6, children: [
                    for (final d in days)
                      FilterChip(label: Text(d.$2), selected: _rest.contains(d.$1), onSelected: (v) => setState(() => v ? _rest.add(d.$1) : _rest.remove(d.$1))),
                  ]),
                ]),
              ]),
            ),
            SuiteSection(
              title: l10n.hrHolidays(year),
              child: FutureBuilder(
                future: ref.read(hrApiProvider).holidays(year),
                builder: (context, snap) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final h in snap.data ?? const <Map<String, dynamic>>[])
                    ListTile(
                      dense: true,
                      title: Text('${h['name']}'),
                      subtitle: Text('${h['date']}'.split('T').first),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.commonDelete,
                        onPressed: () async {
                          await ref.read(hrApiProvider).removeHoliday((h['id'] as num).toInt());
                          setState(() {});
                        },
                      ),
                    ),
                  Row(children: [
                    SizedBox(width: 150, child: TextField(controller: _holidayDate, decoration: const InputDecoration(hintText: 'YYYY-MM-DD'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _holidayName, decoration: InputDecoration(hintText: l10n.hrHolidayName))),
                    TextButton(
                      onPressed: () async {
                        await suiteRun(context, () async {
                          await ref.read(hrApiProvider).addHoliday(_holidayDate.text.trim(), _holidayName.text.trim());
                          return true;
                        }, queueable: false);
                        _holidayDate.clear();
                        _holidayName.clear();
                        setState(() {});
                      },
                      child: Text(l10n.hrAddHoliday),
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}
