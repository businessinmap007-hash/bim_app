import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/assignment/assignee.dart';
import 'package:bim_app/core/assignment/assignment_providers.dart';
import 'package:bim_app/core/assignment/widgets/assignee_widgets.dart';
import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/staff/data/models/staff_member.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _host(Widget child, {List<Assignee> providers = const []}) => ProviderScope(
  overrides: [businessProvidersProvider.overrideWith((ref, id) async => providers)],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  ),
);

const _ahmed = Assignee(id: 5, name: 'أحمد', title: 'حلاق أول');
const _mona = Assignee(id: 6, name: 'منى');

void main() {
  group('Assignee', () {
    test('reads name + his title at the business, and tolerates a missing one', () {
      expect(Assignee.fromJson({'id': 5, 'name': 'أحمد', 'title': ' حلاق أول '}).line, 'أحمد — حلاق أول');
      expect(Assignee.fromJson({'id': 6, 'name': 'منى', 'title': ''}).line, 'منى');
      expect(Assignee.fromJson({'id': 6, 'name': 'منى'}).title, isNull);
    });

    test('a booking and a staff member carry it', () {
      final staff = StaffMember.fromJson({
        'user': {'id': 1, 'name': 'س'},
        'capabilities': <String>[],
        'is_active': true,
        'is_provider': true,
      });
      expect(staff.isProvider, isTrue);
      expect(staff.isPhysician, isFalse);

      // an older server that only knows physicians: a physician is a provider
      final physician = StaffMember.fromJson({
        'user': {'id': 2, 'name': 'د'},
        'capabilities': <String>[],
        'is_active': true,
        'is_physician': true,
      });
      expect(physician.isProvider, isTrue);
    });

    test('Booking.fromJson keeps who is responsible', () {
      final booking = Booking.fromJson({
        'id': 9,
        'business_id': 3,
        'status': 'pending',
        'assignee': {'id': 5, 'name': 'أحمد', 'title': 'حلاق أول'},
      });
      expect(booking.assignee?.id, 5);
    });
  });

  group('AssigneeTile', () {
    testWidgets('a business with no providers and nobody assigned is not asked', (tester) async {
      await tester.pumpWidget(_host(AssigneeTile(current: null, onAssign: (_) async => null)));
      await tester.pumpAndSettle();

      expect(find.text('المسؤول'), findsNothing);
    });

    testWidgets('choosing a provider calls onAssign with his id and then onChanged', (tester) async {
      int? asked;
      var changed = 0;

      await tester.pumpWidget(
        _host(
          AssigneeTile(
            current: null,
            onAssign: (id) async {
              asked = id;
              return _ahmed;
            },
            onChanged: () => changed++,
          ),
          providers: const [_ahmed, _mona],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لم يُعيَّن أحد بعد'), findsOneWidget);
      await tester.tap(find.text('تعيين'));
      await tester.pumpAndSettle();

      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('حلاق أول'), findsOneWidget);
      // nothing is assigned yet, so there is nothing to take back
      expect(find.text('بدون تعيين'), findsNothing);

      await tester.tap(find.text('أحمد'));
      await tester.pumpAndSettle();

      expect(asked, 5);
      expect(changed, 1);
    });

    testWidgets('an assigned item shows him and offers taking it back', (tester) async {
      var released = false;

      await tester.pumpWidget(
        _host(
          AssigneeTile(
            current: _ahmed,
            onAssign: (id) async {
              released = id == null;
              return null;
            },
          ),
          providers: const [_ahmed, _mona],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أحمد — حلاق أول'), findsOneWidget);
      await tester.tap(find.text('تغيير'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('بدون تعيين'));
      await tester.pumpAndSettle();

      expect(released, isTrue);
    });
  });

  testWidgets('AssigneeLine draws nothing for nobody and one labelled line for somebody', (tester) async {
    await tester.pumpWidget(_host(const AssigneeLine(null)));
    expect(find.textContaining('المسؤول'), findsNothing);

    await tester.pumpWidget(_host(const AssigneeLine(_ahmed)));
    expect(find.text('المسؤول: أحمد — حلاق أول'), findsOneWidget);
  });
}
