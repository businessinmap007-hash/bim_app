import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/staff/application/staff_groups_providers.dart';
import 'package:bim_app/features/staff/application/staff_providers.dart';
import 'package:bim_app/features/staff/data/models/staff_group.dart';
import 'package:bim_app/features/staff/data/models/staff_membership.dart';
import 'package:bim_app/features/staff/data/staff_api.dart';
import 'package:bim_app/features/staff/presentation/screens/staff_groups_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

// A genuine UTC instant — this is what Carbon::toIso8601String() sends
// (app.timezone is UTC). It must come back as a *local* clock time, not
// this raw UTC one, to the manager reading it.
const _checkedInIso = '2026-01-01T09:00:00.000000Z';

String _hhmm(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

class _FakeStaffApi implements StaffApi {
  @override
  Future<List<StaffGroup>> groups() async => [
    StaffGroup.fromJson({
      'capability': 'menu',
      'name_ar': 'المنيو',
      'name_en': 'Menu',
      'staff': [
        {
          'user_id': 1,
          'name': 'Ali',
          'is_active': true,
          'operations_today': 2,
          'attendance': {'is_present': true, 'checked_in_at': _checkedInIso, 'checked_out_at': null},
        },
      ],
    }),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a genuine UTC checked_in_at converts to local, keeping the same instant', () {
    final member = StaffGroupMember.fromJson({
      'user_id': 1,
      'name': 'Ali',
      'is_active': true,
      'operations_today': 0,
      'attendance': {'is_present': true, 'checked_in_at': _checkedInIso, 'checked_out_at': null},
    });

    expect(member.checkedInAt, isNotNull);
    expect(member.checkedInAt!.isUtc, isFalse, reason: 'must be converted to local, not left as UTC');
    expect(member.checkedInAt!.toUtc(), DateTime.parse(_checkedInIso).toUtc(), reason: 'same instant, only the representation changes');
  });

  test('the parallel AttendanceStatus model (my_work_screen) does the same conversion', () {
    final status = AttendanceStatus.fromJson({'is_present': true, 'checked_in_at': _checkedInIso, 'checked_out_at': null});
    expect(status.checkedInAt!.isUtc, isFalse);
    expect(status.checkedInAt!.toUtc(), DateTime.parse(_checkedInIso).toUtc());
  });

  testWidgets('the manager sees the check-in time, in local wall-clock time', (tester) async {
    final expectedLocal = _hhmm(DateTime.parse(_checkedInIso).toLocal());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [staffApiProvider.overrideWithValue(_FakeStaffApi())],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const StaffGroupsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Present since $expectedLocal'), findsOneWidget);
  });
}
