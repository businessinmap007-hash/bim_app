import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/application/booking_providers.dart';
import 'package:bim_app/features/booking/data/booking_api.dart';
import 'package:bim_app/features/booking/data/models/booking_financial_preview.dart';
import 'package:bim_app/features/booking/presentation/widgets/booking_money_card.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeBookingApi implements BookingApi {
  final Map<String, dynamic> body;
  _FakeBookingApi(this.body);

  @override
  Future<BookingFinancialPreview> financialPreview(int id) async => BookingFinancialPreview.fromJson(body);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _body({double balance = 500, bool ready = true, String status = 'accepted', double fee = 20, bool other = true}) => {
  'side': 'client',
  'status': status,
  'deposit': {'required': true, 'already_frozen': false, 'my_wallet_required': 150, 'covered_by_guarantee': false, 'guarantee_applied': 0},
  'fees': {
    'my_required': fee,
    'promotions': [
      {'name': 'Launch', 'message': 'Launch: 50% off the fee'},
    ],
  },
  'me': {'balance': balance, 'required_total': 150 + fee, 'ready': ready},
  'counterpart_ready': other,
  'messages': [],
};

Widget _app(Map<String, dynamic> body) => ProviderScope(
  overrides: [bookingApiProvider.overrideWithValue(_FakeBookingApi(body))],
  child: MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const Scaffold(body: BookingMoneyCard(bookingId: 7)),
  ),
);

void main() {
  testWidgets('shows the deposit, fee, total and that the balance is enough', (tester) async {
    await tester.pumpWidget(_app(_body()));
    await tester.pumpAndSettle();

    expect(find.text('Deposit held from your wallet'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('170'), findsOneWidget);
    expect(find.text('Launch: 50% off the fee'), findsOneWidget);
    expect(find.text('Your balance is enough'), findsOneWidget);
    expect(find.text('The service fee is not refundable once the booking is in progress.'), findsOneWidget);
  });

  testWidgets('says so when the balance falls short, and when the other side is pending', (tester) async {
    await tester.pumpWidget(_app(_body(balance: 10, ready: false, other: false)));
    await tester.pumpAndSettle();

    expect(find.text('Your balance is not enough'), findsOneWidget);
    expect(find.text('The other side has not met its part yet.'), findsOneWidget);
  });

  testWidgets('is silent once the booking is over', (tester) async {
    await tester.pumpWidget(_app(_body(status: 'completed')));
    await tester.pumpAndSettle();
    expect(find.text('What you need up front for this booking'), findsNothing);
  });

  test('a party with nothing asked of it has an empty preview', () {
    final p = BookingFinancialPreview.fromJson({
      'side': 'business',
      'status': 'pending',
      'deposit': {'required': false},
      'fees': {'my_required': 0},
      'me': {'required_total': 0, 'ready': true},
    });
    expect(p.isEmpty, isTrue);
  });
}
