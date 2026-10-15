import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/deposit/visit_deposit.dart';
import 'package:bim_app/core/deposit/widgets/visit_deposit_card.dart';
import 'package:bim_app/features/booking_settings/data/models/booking_terms.dart';
import 'package:bim_app/features/clinic/data/models/clinic_appointment.dart';
import 'package:bim_app/features/clinic_management/data/models/business_clinic_appointment.dart';
import 'package:bim_app/features/hospital/data/models/hospital_procedure.dart';
import 'package:bim_app/features/investigations/data/models/investigation.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _host(Widget child) => ProviderScope(
  child: MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  group('«عربون الجدية» of a health visit', () {
    test('reads what the business asks and where it stands', () {
      final d = VisitDeposit.fromJsonOrNull({'mode': 'wallet', 'status': 'held', 'amount': 20, 'counter_amount': 10, 'dispute_id': 7})!;

      expect(d.amount, 20);
      expect(d.counterAmount, 10);
      expect(d.status, VisitDeposit.held);
      expect(d.isExternal, isFalse);
      expect(d.disputeId, 7);
      expect(VisitDeposit.fromJsonOrNull(null), isNull);
      expect(VisitDeposit.fromJsonOrNull({'mode': 'wallet', 'status': 'quoted', 'amount': 0}), isNull);
      expect(VisitDeposit.fromJsonOrNull({'mode': 'external', 'status': 'void', 'amount': 20})!.isHidden, isTrue);
    });

    test('says how much of each share stands on a guarantee', () {
      final d = VisitDeposit.fromJsonOrNull({
        'mode': 'wallet',
        'status': 'held',
        'amount': 20,
        'counter_amount': 10,
        'guarantee_amount': 8,
        'business_guarantee_amount': 10,
      })!;

      expect(d.guaranteeAmount, 8);
      expect(d.businessGuaranteeAmount, 10);
      expect(VisitDeposit.fromJsonOrNull({'mode': 'wallet', 'status': 'held', 'amount': 20})!.guaranteeAmount, 0);
    });

    test('a business with no guarantee of its own reads the in-app modes as closed', () {
      expect(BookingTerms.fromJson({'enabled': true, 'security_mode': 'external_transfer', 'has_guarantee': false}).hasGuarantee, isFalse);
      expect(BookingTerms.fromJson({'enabled': true, 'security_mode': 'deposit_freeze', 'has_guarantee': true}).hasGuarantee, isTrue);
      // an older server says nothing: nothing is closed
      expect(BookingTerms.fromJson({'enabled': true}).hasGuarantee, isTrue);
    });

    test('every kind of visit carries it', () {
      final json = {'mode': 'external', 'status': 'pending', 'amount': 50};

      expect(ClinicAppointment.fromJson({'id': 1, 'status': 'confirmed', 'deposit': json}).deposit!.isExternal, isTrue);
      expect(
        BusinessClinicAppointment.fromJson({'id': 1, 'status': 'confirmed', 'deposit': json}).deposit!.status,
        VisitDeposit.pending,
      );
      expect(InvestigationOrder.fromJson({'id': 1, 'status': 'sent', 'deposit': json}).deposit!.amount, 50);
      expect(ProcedureRequestItem.fromJson({'id': 1, 'status': 'requested', 'deposit': json}).deposit!.amount, 50);

      // a business that asks nothing sends nothing
      expect(ClinicAppointment.fromJson({'id': 2, 'status': 'confirmed'}).deposit, isNull);
    });

    test('a cancelled appointment keeps its deposit line when only the status is merged', () {
      final a = ClinicAppointment.fromJson({
        'id': 1,
        'status': 'confirmed',
        'deposit': {'mode': 'wallet', 'status': 'held', 'amount': 20, 'counter_amount': 0},
      });

      expect(a.copyWith(status: 'cancelled').deposit!.status, VisitDeposit.held);
    });

    testWidgets('the patient reads what will be asked, and nothing else to press', (tester) async {
      await tester.pumpWidget(
        _host(
          const VisitDepositCard(
            deposit: VisitDeposit(mode: 'wallet', status: VisitDeposit.quoted, amount: 20, counterAmount: 10),
            kind: VisitKind.clinicAppointment,
            subjectId: 1,
            forBusiness: false,
          ),
        ),
      );

      expect(find.textContaining('20'), findsWidgets);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('the business answers a deposit owed outside the platform', (tester) async {
      await tester.pumpWidget(
        _host(
          const VisitDepositCard(
            deposit: VisitDeposit(mode: 'external', status: VisitDeposit.pending, amount: 50),
            kind: VisitKind.investigationOrder,
            subjectId: 1,
            forBusiness: true,
          ),
        ),
      );

      // «استلمت كاش» · «استلمت تحويلًا» · «قبول العربون — بلا دفع خارج المنصة»
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(2));
    });

    testWidgets('after a no-show a held deposit may be given back or disputed', (tester) async {
      await tester.pumpWidget(
        _host(
          const VisitDepositCard(
            deposit: VisitDeposit(mode: 'wallet', status: VisitDeposit.held, amount: 20, counterAmount: 10),
            kind: VisitKind.clinicAppointment,
            subjectId: 1,
            forBusiness: true,
            visitEnded: true,
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget); // give back
      expect(find.byType(OutlinedButton), findsOneWidget); // dispute
    });

    testWidgets('a held deposit of a visit still ahead offers nothing to press', (tester) async {
      await tester.pumpWidget(
        _host(
          const VisitDepositCard(
            deposit: VisitDeposit(mode: 'wallet', status: VisitDeposit.held, amount: 20, counterAmount: 10),
            kind: VisitKind.procedureRequest,
            subjectId: 1,
            forBusiness: true,
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('a void deposit shows nothing', (tester) async {
      await tester.pumpWidget(
        _host(
          const VisitDepositCard(
            deposit: VisitDeposit(mode: 'external', status: VisitDeposit.voided, amount: 20),
            kind: VisitKind.clinicAppointment,
            subjectId: 1,
            forBusiness: false,
          ),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });
  });
}
