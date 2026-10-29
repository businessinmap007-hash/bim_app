import 'package:bim_app/features/hr/data/hr_api.dart';
import 'package:bim_app/features/hr/presentation/hr_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a month and a payslip parse from the API shape', () {
    final month = HrMonth.fromJson({
      'days': [
        {'date': '2026-09-01', 'status': 'late', 'check_in': '09:40', 'check_out': '17:00', 'late_minutes': 40, 'deduction': 0.25},
        {'date': '2026-09-04', 'status': 'rest'},
      ],
      'totals': {'late_minutes': 40, 'deduction_days': 0.25, 'present': 21},
    });
    expect(month.days.first.lateMinutes, 40);
    expect(month.days.first.deduction, 0.25);
    expect(month.total('present'), 21);
    expect(month.totalD('deduction_days'), 0.25);

    final slip = HrPayslip.fromJson({
      'id': 1,
      'user_id': 7,
      'lines': [
        {'type': 'earning', 'key': 'basic', 'amount': 9000},
        {'type': 'earning', 'key': 'allowance', 'label': 'بدل مواصلات', 'amount': 1500},
        {'type': 'deduction', 'key': 'tax', 'amount': '727.25'},
      ],
      'gross': '10803.75',
      'deductions': 2456.25,
      'net': 8347.5,
      'attendance': {'review': false},
    });
    expect(slip.line('tax'), 727.25);
    expect(slip.gross, 10803.75);
    expect(slip.needsReview, isFalse);
  });

  test('hours read the way the board prints them', () {
    expect(HrLabels.hours(360), '6');
    expect(HrLabels.hours(90), '1.5');
    expect(hrMonthKey(DateTime(2026, 9, 15)), '2026-09');
  });
}
