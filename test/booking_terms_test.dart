import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking_settings/application/booking_settings_controller.dart';
import 'package:bim_app/features/booking_settings/data/booking_settings_api.dart';
import 'package:bim_app/features/booking_settings/data/models/booking_terms.dart';
import 'package:bim_app/features/booking_settings/presentation/screens/booking_terms_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «شروط الحجز» — deposit frozen in both wallets / the customer's guarantee / a transfer outside the app, in the
/// business's own words, with a live example for an 800 booking.
class _FakeApi implements BookingSettingsApi {
  BookingTerms stored = const BookingTerms();
  BookingTerms? saved;

  @override
  Future<BookingTerms> bookingTerms() async => stored;

  @override
  Future<BookingTerms> saveBookingTerms(BookingTerms terms) async {
    saved = terms;
    return terms;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('the preview does the server arithmetic: 25% of 800, half of it frozen from the business', () {
    const terms = BookingTerms(enabled: true, depositPercent: 25, businessCounterPercent: 50);
    final example = terms.previewFor(800);

    expect(example.deposit, 200);
    expect(example.customerHold, 200);
    expect(example.businessHold, 100);
  });

  test('a transfer outside the app freezes nothing, and a guarantee may be asked for several days\' worth', () {
    final outside = const BookingTerms(enabled: true, depositPercent: 20, mode: BookingSecurityMode.externalTransfer).previewFor(800);
    expect(outside.externalAmount, 160);
    expect(outside.customerHold, 0);

    final guarantee = const BookingTerms(enabled: true, depositPercent: 20, mode: BookingSecurityMode.guaranteeFreeze, guaranteeMultiple: 3).previewFor(800);
    expect(guarantee.guaranteeRequired, 2400);
  });

  testWidgets('off by default; turning it on shows the three ways, the preferred one chosen, and the example', (tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FakeApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookingSettingsApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const BookingTermsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('شروط الحجز'), findsOneWidget);
    expect(find.text('تجميد ديبوزت'), findsNothing, reason: 'nothing is asked until the merchant turns it on');
    expect(find.text('كل حجز ينتظر موافقتك قبل أن يتأكد.'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('تجميد ديبوزت'), findsOneWidget);
    expect(find.text('تجميد ضمان العميل'), findsOneWidget);
    expect(find.text('تحويل خارج التطبيق'), findsOneWidget);
    expect(find.text('مفضّل'), findsOneWidget);
    // 20% of 800 by default
    expect(find.text('الديبوزت: 160'), findsOneWidget);

    await tester.tap(find.text('25٪ من قيمة الحجز'));
    await tester.pumpAndSettle();
    expect(find.text('الديبوزت: 200'), findsOneWidget);
    expect(find.text('يُجمَّد منك: 100'), findsOneWidget);
  });

  testWidgets('outside transfer drops what the business freezes; guarantee mode asks how much; save sends it all', (tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FakeApi()..stored = const BookingTerms(enabled: true, depositPercent: 20);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookingSettingsApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const BookingTermsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ما تجمّده أنت مقابله'), findsOneWidget);

    await tester.tap(find.text('تحويل خارج التطبيق'));
    await tester.pumpAndSettle();
    expect(find.text('ما تجمّده أنت مقابله'), findsNothing);
    expect(find.text('يحوّله العميل مباشرة: 160'), findsOneWidget);

    await tester.tap(find.text('تجميد ضمان العميل'));
    await tester.pumpAndSettle();
    expect(find.text('حجم الضمان المطلوب'), findsOneWidget);

    await tester.ensureVisible(find.text('3× قيمة حجز اليوم'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3× قيمة حجز اليوم'));
    await tester.pumpAndSettle();
    expect(find.text('ضمان العميل المطلوب: 2400'), findsOneWidget);

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(api.saved?.mode, BookingSecurityMode.guaranteeFreeze);
    expect(api.saved?.guaranteeMultiple, 3);
    expect(api.saved?.enabled, isTrue);
    expect(find.text('تم حفظ شروط الحجز'), findsOneWidget);
  });
}
