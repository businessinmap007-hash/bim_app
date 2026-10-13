import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/network/paginated.dart';
import 'package:bim_app/features/clinic/data/models/clinic_appointment.dart';
import 'package:bim_app/features/clinic_management/application/business_clinic_providers.dart';
import 'package:bim_app/features/clinic_management/data/business_clinic_api.dart';
import 'package:bim_app/features/clinic_management/data/models/business_clinic_appointment.dart';
import 'package:bim_app/features/clinic_management/presentation/widgets/visit_billing_card.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «عند الوصول رسم الزيارة وبعد الانتهاء تظهر تكلفة الخدمة» — المالك، 2026-10-15.
VisitBilling _billing({
  required bool done,
  double paid = 0,
  List<VisitPayment> payments = const [],
  double? installment,
  double carriedOver = 0,
  double carriedOverDue = 0,
}) => VisitBilling(
  visitFee: 300,
  services: [
    BillingService(itemId: 7, name: 'تنظيف الأسنان وإزالة الجير', price: 400, amount: done ? 400 : null, counted: done),
  ],
  servicesTotal: done ? 400 : 0,
  total: done ? 700 : 300,
  paid: paid,
  remaining: (done ? 700 : 300) - paid,
  servicesPending: !done,
  payments: payments,
  installmentAmount: installment,
  carriedOver: carriedOver,
  carriedOverDue: carriedOverDue,
);

BusinessClinicAppointment _appointment({required String status, required VisitBilling billing}) => BusinessClinicAppointment(
  id: 5,
  status: status,
  durationMinutes: 20,
  patientId: 9,
  patientName: 'منى علي',
  services: const [BookedService(name: 'تنظيف الأسنان وإزالة الجير', price: 400)],
  billing: billing,
);

class _FakeApi implements BusinessClinicApi {
  final BusinessClinicAppointment appointment;
  final payments = <(double, String, String?)>[];
  final prices = <double?>[];
  final removed = <int>[];
  final installments = <double?>[];

  _FakeApi(this.appointment);

  @override
  Future<Paginated<BusinessClinicAppointment>> appointments({String? status, int page = 1}) async =>
      Paginated(items: [appointment], currentPage: 1, lastPage: 1, total: 1);

  @override
  Future<VisitBilling> recordPayment(int appointmentId, double amount, String kind, {String? note}) async {
    payments.add((amount, kind, note));

    return _billing(done: appointment.status == 'completed', paid: amount);
  }

  @override
  Future<VisitBilling> setFinalPrice(int appointmentId, int itemId, double? price) async {
    prices.add(price);

    return _billing(done: true);
  }

  @override
  Future<VisitBilling> setInstallment(int appointmentId, double? amount) async {
    installments.add(amount);

    return _billing(done: true, installment: amount);
  }

  @override
  Future<VisitBilling> removePayment(int appointmentId, int paymentId) async {
    removed.add(paymentId);

    return _billing(done: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeApi api) => ProviderScope(
  overrides: [businessClinicApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: SingleChildScrollView(child: VisitBillingCard(appointment: api.appointment))),
  ),
);

void main() {
  testWidgets('on arrival the account is the visit fee, and the service cost is not charged yet', (tester) async {
    final api = _FakeApi(_appointment(status: 'confirmed', billing: _billing(done: false)));
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('300 ج'), findsWidgets);
    expect(find.text('تظهر تكلفة الخدمات بعد الانتهاء من الزيارة، ويمكن زيادتها أو إنقاصها.'), findsOneWidget);
    // the listed price is shown, but only the visit fee is in the total
    expect(find.text('400 ج'), findsOneWidget);
    expect(find.text('الإجمالي'), findsOneWidget);
  });

  testWidgets('the clinic records the fee as paid and the account updates', (tester) async {
    final api = _FakeApi(_appointment(status: 'confirmed', billing: _billing(done: false)));
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تسجيل دفعة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '300');
    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل دفعة'));
    await tester.pumpAndSettle();

    // the first payment of a visit is its fee, paid on arrival
    expect(api.payments, [(300.0, 'visit_fee', '')]);
  });

  testWidgets('after the visit the clinic may change what a service is charged', (tester) async {
    final api = _FakeApi(_appointment(status: 'completed', billing: _billing(done: true)));
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('700 ج'), findsWidgets, reason: 'fee + the listed cleaning, as the total and as what is left');

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '500');
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pumpAndSettle();

    expect(api.prices, [500.0]);
  });

  testWidgets('a payment recorded by mistake is taken back', (tester) async {
    final api = _FakeApi(
      _appointment(
        status: 'completed',
        billing: _billing(done: true, paid: 1000, payments: const [VisitPayment(id: 11, amount: 1000, kind: 'service', note: 'الدفعة الأولى')]),
      ),
    );
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.textContaining('الدفعة الأولى'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(api.removed, [11]);
  });

  test('the billing model reads the server shape and tolerates decimal strings', () {
    final b = VisitBilling.fromJsonOrNull({
      'visit_fee': '300.00',
      'services': [
        {'item_id': 7, 'name': 'x', 'price': '400.00', 'final_price': null, 'amount': null, 'counted': false},
      ],
      'services_total': 0,
      'total': '300.00',
      'paid': 0,
      'remaining': 300,
      'services_pending': true,
      'payments': [
        {'id': 1, 'amount': '300.00', 'kind': 'visit_fee', 'note': null, 'paid_at': null, 'recorded_by': 'سكرتير'},
      ],
    })!;

    expect(b.visitFee, 300.0);
    expect(b.services.single.price, 400.0);
    expect(b.services.single.amount, isNull);
    expect(b.servicesPending, isTrue);
    expect(b.payments.single.amount, 300.0);
    expect(VisitBilling.fromJsonOrNull(null), isNull);
  });

  testWidgets('each payment shows the patient\'s answer, and a confirmed one cannot be taken back', (tester) async {
    final api = _FakeApi(
      _appointment(
        status: 'completed',
        billing: _billing(
          done: true,
          paid: 1300,
          payments: const [
            VisitPayment(id: 1, amount: 300, kind: 'visit_fee', confirmation: 'confirmed', canRemove: false),
            VisitPayment(id: 2, amount: 1000, kind: 'service', confirmation: 'pending'),
            VisitPayment(id: 3, amount: 500, kind: 'service', confirmation: 'disputed', disputeNote: 'دفعت أقل'),
          ],
        ),
      ),
    );
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.textContaining('مؤكَّدة من المريض'), findsOneWidget);
    expect(find.textContaining('بانتظار تأكيد المريض'), findsOneWidget);
    expect(find.textContaining('دفعت أقل'), findsOneWidget);

    // the confirmed one has no remove button: two of the three can be taken back
    expect(find.byIcon(Icons.close), findsNWidgets(2));
  });

  testWidgets('the clinic sets what it will ask at the next session', (tester) async {
    final api = _FakeApi(_appointment(status: 'completed', billing: _billing(done: true, paid: 100)));
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('القسط عند الجلسة القادمة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '700');
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pumpAndSettle();

    expect(api.installments, [700.0]);
  });

  testWidgets('what is carried over from earlier visits is said first, with what is asked now', (tester) async {
    final api = _FakeApi(
      _appointment(status: 'confirmed', billing: _billing(done: false, carriedOver: 2200, carriedOverDue: 700)),
    );
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.textContaining('2200 ج'), findsOneWidget);
    expect(find.textContaining('700 ج'), findsWidgets);
  });
}
