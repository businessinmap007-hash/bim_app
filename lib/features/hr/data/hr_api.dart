import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';

// «الحضور والمرتبات» (backend: HrController, PayrollController, StaffHrController). Shared by the desktop screens and
// the phone (the employee's «عملي» and the owner's approvals).

double _d(Object? v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
int _i(Object? v) => v == null ? 0 : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
List<Map<String, dynamic>> _rows(Object? v) => (v as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

class HrDay {
  final String date;
  final String status; // present | late | absent | leave | unpaid_leave | rest | holiday | none
  final String? checkIn;
  final String? checkOut;
  final int lateMinutes;
  final int earlyMinutes;
  final int overtimeMinutes;
  final int overtimeNightMinutes;
  final double deduction;
  final String? note;

  const HrDay({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    required this.lateMinutes,
    required this.earlyMinutes,
    required this.overtimeMinutes,
    required this.overtimeNightMinutes,
    required this.deduction,
    this.note,
  });

  factory HrDay.fromJson(Map<String, dynamic> j) => HrDay(
        date: j['date'] as String,
        status: j['status'] as String? ?? 'none',
        checkIn: j['check_in'] as String?,
        checkOut: j['check_out'] as String?,
        lateMinutes: _i(j['late_minutes']),
        earlyMinutes: _i(j['early_minutes']),
        overtimeMinutes: _i(j['overtime_minutes']),
        overtimeNightMinutes: _i(j['overtime_night_minutes']),
        deduction: _d(j['deduction']),
        note: j['note'] as String?,
      );
}

class HrMonth {
  final List<HrDay> days;
  final Map<String, dynamic> totals;

  const HrMonth({required this.days, required this.totals});

  factory HrMonth.fromJson(Map<String, dynamic> j) =>
      HrMonth(days: _rows(j['days']).map(HrDay.fromJson).toList(), totals: (j['totals'] as Map?)?.cast<String, dynamic>() ?? const {});

  int total(String key) => _i(totals[key]);
  double totalD(String key) => _d(totals[key]);
}

class HrBoardRow {
  final int userId;
  final String name;
  final HrMonth month;

  const HrBoardRow({required this.userId, required this.name, required this.month});

  factory HrBoardRow.fromJson(Map<String, dynamic> j) => HrBoardRow(userId: _i(j['user_id']), name: j['name'] as String? ?? '', month: HrMonth.fromJson(j));
}

class HrRequestRow {
  final int id;
  final int userId;
  final String? userName;
  final String kind; // leave | correction | overtime
  final String dateFrom;
  final String dateTo;
  final Map<String, dynamic> data;
  final String? reason;
  final String status;
  final String? decisionNote;

  const HrRequestRow({
    required this.id,
    required this.userId,
    this.userName,
    required this.kind,
    required this.dateFrom,
    required this.dateTo,
    required this.data,
    this.reason,
    required this.status,
    this.decisionNote,
  });

  factory HrRequestRow.fromJson(Map<String, dynamic> j) => HrRequestRow(
        id: _i(j['id']),
        userId: _i(j['user_id']),
        userName: j['user_name'] as String?,
        kind: j['kind'] as String? ?? 'leave',
        dateFrom: (j['date_from'] as String? ?? '').split('T').first,
        dateTo: (j['date_to'] as String? ?? '').split('T').first,
        data: (j['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        reason: j['reason'] as String?,
        status: j['status'] as String? ?? 'pending',
        decisionNote: j['decision_note'] as String?,
      );
}

class HrEmployeeRow {
  final int userId;
  final String name;
  final String? title;
  final int? shiftId;
  final String? hireDate;
  final Map<String, dynamic> leave;
  final double? basicSalary; // null when the viewer has no payroll capability
  final List<Map<String, dynamic>> allowances;
  final bool insured;
  final bool taxable;

  const HrEmployeeRow({
    required this.userId,
    required this.name,
    this.title,
    this.shiftId,
    this.hireDate,
    required this.leave,
    this.basicSalary,
    required this.allowances,
    required this.insured,
    required this.taxable,
  });

  bool get seesPay => basicSalary != null;

  factory HrEmployeeRow.fromJson(Map<String, dynamic> j) => HrEmployeeRow(
        userId: _i(j['user_id']),
        name: j['name'] as String? ?? '',
        title: j['title'] as String?,
        shiftId: j['shift_id'] == null ? null : _i(j['shift_id']),
        hireDate: j['hire_date'] as String?,
        leave: (j['leave'] as Map?)?.cast<String, dynamic>() ?? const {},
        basicSalary: j.containsKey('basic_salary') ? _d(j['basic_salary']) : null,
        allowances: _rows(j['allowances']),
        insured: j['insured'] != false,
        taxable: j['taxable'] != false,
      );
}

class HrShift {
  final int id;
  final String name;
  final String startsAt;
  final String endsAt;

  const HrShift({required this.id, required this.name, required this.startsAt, required this.endsAt});

  factory HrShift.fromJson(Map<String, dynamic> j) =>
      HrShift(id: _i(j['id']), name: j['name'] as String? ?? '', startsAt: j['starts_at'] as String? ?? '', endsAt: j['ends_at'] as String? ?? '');
}

class HrPayslip {
  final int id;
  final int userId;
  final String? userName;
  final String? month;
  final List<Map<String, dynamic>> lines;
  final Map<String, dynamic> attendance;
  final double gross;
  final double deductions;
  final double net;
  final double employerInsurance;
  final String? paidAt;
  final String? paidMethod;

  const HrPayslip({
    required this.id,
    required this.userId,
    this.userName,
    this.month,
    required this.lines,
    required this.attendance,
    required this.gross,
    required this.deductions,
    required this.net,
    required this.employerInsurance,
    this.paidAt,
    this.paidMethod,
  });

  double line(String key) => lines.where((l) => l['key'] == key).fold(0.0, (s, l) => s + _d(l['amount']));

  bool get needsReview => attendance['review'] == true;

  factory HrPayslip.fromJson(Map<String, dynamic> j) => HrPayslip(
        id: _i(j['id']),
        userId: _i(j['user_id']),
        userName: j['user_name'] as String?,
        month: j['month'] as String?,
        lines: _rows(j['lines']),
        attendance: (j['attendance'] as Map?)?.cast<String, dynamic>() ?? const {},
        gross: _d(j['gross']),
        deductions: _d(j['deductions']),
        net: _d(j['net']),
        employerInsurance: _d(j['employer_insurance']),
        paidAt: j['paid_at'] as String?,
        paidMethod: j['paid_method'] as String?,
      );
}

class HrRun {
  final String status; // draft | approved
  final Map<String, dynamic> totals;
  final List<HrPayslip> payslips;

  const HrRun({required this.status, required this.totals, required this.payslips});

  double total(String key) => _d(totals[key]);
}

class HrMe {
  final HrMonth month;
  final Map<String, dynamic> leave;
  final List<HrRequestRow> requests;
  final List<HrPayslip> payslips;

  const HrMe({required this.month, required this.leave, required this.requests, required this.payslips});
}

class HrApi {
  final ApiClient _c;

  const HrApi(this._c);

  Map<String, dynamic> _m(dynamic v) => (v as Map<String, dynamic>?) ?? const {};

  // ── manager ──
  Future<Map<String, dynamic>> settings() async => _m(_m(await _c.get('/business/hr/settings'))['settings']);
  Future<void> updateSettings(Map<String, dynamic> body) => _c.patch('/business/hr/settings', data: body);
  Future<List<HrShift>> shifts() async => _rows(_m(await _c.get('/business/hr/shifts'))['shifts']).map(HrShift.fromJson).toList();
  Future<void> saveShift({int? id, required String name, required String startsAt, required String endsAt}) => id == null
      ? _c.post('/business/hr/shifts', data: {'name': name, 'starts_at': startsAt, 'ends_at': endsAt})
      : _c.patch('/business/hr/shifts/$id', data: {'name': name, 'starts_at': startsAt, 'ends_at': endsAt});
  Future<List<Map<String, dynamic>>> holidays(int year) async => _rows(_m(await _c.get('/business/hr/holidays', query: {'year': year}))['holidays']);
  Future<void> addHoliday(String date, String name) => _c.post('/business/hr/holidays', data: {'date': date, 'name': name});
  Future<void> removeHoliday(int id) => _c.delete('/business/hr/holidays/$id');
  Future<List<HrEmployeeRow>> employees() async => _rows(_m(await _c.get('/business/hr/employees'))['employees']).map(HrEmployeeRow.fromJson).toList();
  Future<void> updateEmployee(int userId, Map<String, dynamic> body) => _c.patch('/business/hr/employees/$userId', data: body);
  Future<({List<HrBoardRow> rows, int pending})> board(String month) async {
    final d = _m(await _c.get('/business/hr/attendance', query: {'month': month}));
    return (rows: _rows(d['employees']).map(HrBoardRow.fromJson).toList(), pending: _i(d['pending_requests']));
  }

  Future<List<HrRequestRow>> requests({String? status}) async =>
      _rows(_m(await _c.get('/business/hr/requests', query: {'status': ?status}))['requests']).map(HrRequestRow.fromJson).toList();
  Future<void> decide(int id, bool approve, {String? note}) => _c.post('/business/hr/requests/$id/decide', data: {'approve': approve, 'note': ?note});
  Future<void> recordForEmployee(Map<String, dynamic> body) => _c.post('/business/hr/requests', data: body);

  // ── payroll ──
  Future<HrRun?> payroll(String month) async => _run(_m(await _c.get('/business/hr/payroll/$month')));
  Future<HrRun?> generate(String month) async => _run(_m(await _c.post('/business/hr/payroll/$month/generate')));
  Future<HrRun?> approve(String month) async => _run(_m(await _c.post('/business/hr/payroll/$month/approve')));
  Future<void> markPaid(int payslipId, String method) => _c.post('/business/hr/payslips/$payslipId/paid', data: {'method': method});
  Future<void> addAdvance({required int userId, required double amount, required int installments, required String firstMonth, String? note}) =>
      _c.post('/business/hr/advances', data: {'user_id': userId, 'amount': amount, 'installments': installments, 'first_month': firstMonth, 'note': ?note});
  Future<List<Map<String, dynamic>>> advances() async => _rows(_m(await _c.get('/business/hr/advances'))['advances']);
  Future<void> addAdjustment({required int userId, required String month, required String kind, required double amount, required String reason}) =>
      _c.post('/business/hr/adjustments', data: {'user_id': userId, 'month': month, 'kind': kind, 'amount': amount, 'reason': reason});

  HrRun? _run(Map<String, dynamic> d) {
    final run = d['run'] as Map<String, dynamic>?;
    if (run == null) return null;
    return HrRun(
      status: run['status'] as String? ?? 'draft',
      totals: (run['totals'] as Map?)?.cast<String, dynamic>() ?? const {},
      payslips: _rows(d['payslips']).map(HrPayslip.fromJson).toList(),
    );
  }

  // ── the employee himself ──
  Future<HrMe> me(String month) async {
    final d = _m(await _c.get('/staff/hr/me', query: {'month': month}));
    return HrMe(
      month: HrMonth.fromJson(_m(d['attendance'])),
      leave: _m(d['leave']),
      requests: _rows(d['requests']).map(HrRequestRow.fromJson).toList(),
      payslips: _rows(d['payslips']).map(HrPayslip.fromJson).toList(),
    );
  }

  Future<void> ask(Map<String, dynamic> body) => _c.post('/staff/hr/requests', data: body);
  Future<void> cancelRequest(int id) => _c.post('/staff/hr/requests/$id/cancel');
}

String hrMonthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

final hrApiProvider = Provider<HrApi>((ref) => HrApi(ref.watch(apiClientProvider)));

final hrMonthProvider = StateProvider<String>((ref) => hrMonthKey(DateTime.now()));

final hrBoardProvider = FutureProvider.autoDispose((ref) => ref.watch(hrApiProvider).board(ref.watch(hrMonthProvider)));
final hrPendingRequestsProvider = FutureProvider.autoDispose((ref) => ref.watch(hrApiProvider).requests(status: 'pending'));
final hrEmployeesProvider = FutureProvider.autoDispose((ref) => ref.watch(hrApiProvider).employees());
final hrShiftsProvider = FutureProvider.autoDispose((ref) => ref.watch(hrApiProvider).shifts());
final hrSettingsProvider = FutureProvider.autoDispose((ref) => ref.watch(hrApiProvider).settings());
final hrPayrollProvider = FutureProvider.autoDispose((ref) => ref.watch(hrApiProvider).payroll(ref.watch(hrMonthProvider)));
final hrMeProvider = FutureProvider.autoDispose((ref) => ref.watch(hrApiProvider).me(ref.watch(hrMonthProvider)));
