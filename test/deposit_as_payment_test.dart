import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/application/auth_controller.dart';
import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/booking/application/booking_providers.dart';
import 'package:bim_app/features/booking/data/booking_api.dart';
import 'package:bim_app/features/booking/data/models/booking.dart';
import 'package:bim_app/features/booking/presentation/screens/pending_settlement_gate.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «الديبوزت كدفعة» — an optional term of the business: the customer asks, the business answers. The mandatory
/// settlement prompt carries both halves.
class _FakeAuth extends StateNotifier<AuthState> implements AuthController {
  _FakeAuth(super.initial);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBookingApi implements BookingApi {
  final calls = <String>[];
  Booking afterShow = _booking(const DepositAsPayment(allowed: true, requested: true));

  @override
  Future<Booking> requestDepositAsPayment(int id) async {
    calls.add('request');

    return afterShow;
  }

  @override
  Future<Booking> show(int id) async => afterShow;

  @override
  Future<Booking> acceptDepositAsPayment(int id) async {
    calls.add('accept');

    return _booking(const DepositAsPayment(accepted: true, amount: 200));
  }

  @override
  Future<Booking> declineDepositAsPayment(int id) async {
    calls.add('decline');

    return afterShow = _booking(const DepositAsPayment(declined: true));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Booking _booking(DepositAsPayment state) => Booking(
  id: 7,
  status: 'in_progress',
  price: 1000,
  allDay: false,
  businessName: 'فندق',
  customerName: 'عميل',
  deposit: const BookingDeposit(id: 1, status: 'frozen', releaseAgreedClient: false, releaseAgreedBusiness: false, refundAgreedClient: false, refundAgreedBusiness: false),
  depositAsPayment: state,
);

Widget _app(_FakeBookingApi api, {required bool business, required Booking booking}) {
  final user = AuthUser(id: 5, name: 'x', email: 'x@x.test', phone: '0100', type: business ? 'business' : 'client');

  return ProviderScope(
    overrides: [
      bookingApiProvider.overrideWithValue(api),
      authControllerProvider.overrideWith((ref) => _FakeAuth(AuthSignedIn(user))),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: Builder(
        builder: (context) => TextButton(onPressed: () => showPendingSettlementGate(context, [booking]), child: const Text('open')),
      ),
    ),
  );
}

void main() {
  test('the booking reads the deposit-as-payment state that rides beside it', () {
    final booking = Booking.fromJson({
      'id': 1,
      'status': 'in_progress',
      'deposit_as_payment': {'allowed': true, 'requested': true, 'declined': false, 'accepted': false, 'amount': 0},
    });

    expect(booking.depositAsPayment.allowed, isTrue);
    expect(booking.depositAsPayment.requested, isTrue);
    expect(Booking.fromJson({'id': 2, 'status': 'x'}).depositAsPayment.allowed, isFalse);
  });

  testWidgets('the customer may ask only where it is allowed, and then waits for the answer', (tester) async {
    final api = _FakeBookingApi();
    await tester.pumpWidget(_app(api, business: false, booking: _booking(const DepositAsPayment(allowed: true))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('اطلب من النشاط اعتماد ديبوزتي كدفعة'), findsOneWidget);

    await tester.tap(find.text('اطلب من النشاط اعتماد ديبوزتي كدفعة'));
    await tester.pumpAndSettle();

    expect(api.calls, ['request']);
    expect(find.text('اطلب من النشاط اعتماد ديبوزتي كدفعة'), findsNothing);
    expect(find.textContaining('تم إرسال طلبك'), findsOneWidget);
  });

  testWidgets('without the term the customer is not offered it', (tester) async {
    await tester.pumpWidget(_app(_FakeBookingApi(), business: false, booking: _booking(const DepositAsPayment())));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('اطلب من النشاط اعتماد ديبوزتي كدفعة'), findsNothing);
  });

  testWidgets('the business sees the request and can decline it, staying on the prompt', (tester) async {
    final api = _FakeBookingApi();
    await tester.pumpWidget(_app(api, business: true, booking: _booking(const DepositAsPayment(allowed: true, requested: true))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('اعتمد الديبوزت كدفعة'), findsOneWidget);
    expect(find.text('ارفض'), findsOneWidget);

    await tester.tap(find.text('ارفض'));
    await tester.pumpAndSettle();

    expect(api.calls, ['decline']);
    expect(find.text('اعتمد الديبوزت كدفعة'), findsNothing);
    // the prompt is still there: the deposit stays frozen and must still be settled
    expect(find.text('تأكيد نجاح المعاملة'), findsWidgets);
  });

  testWidgets('accepting settles the deposit and clears the prompt', (tester) async {
    final api = _FakeBookingApi();
    await tester.pumpWidget(_app(api, business: true, booking: _booking(const DepositAsPayment(allowed: true, requested: true))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('اعتمد الديبوزت كدفعة'));
    await tester.pumpAndSettle();

    expect(api.calls, ['accept']);
    expect(find.text('اعتمد الديبوزت كدفعة'), findsNothing);
    expect(find.text('open'), findsOneWidget, reason: 'the queue is empty, so the prompt closed');
  });
}
