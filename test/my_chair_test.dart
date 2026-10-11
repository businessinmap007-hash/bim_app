import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/chairs/application/chairs_providers.dart';
import 'package:bim_app/features/chairs/data/chairs_api.dart';
import 'package:bim_app/features/chairs/data/models/service_chair.dart';
import 'package:bim_app/features/chairs/presentation/screens/my_chair_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeApi implements ChairsApi {
  final called = <(int, int?)>[];
  final started = <(int, int?)>[];

  @override
  Future<void> call(int bookingId, {int? businessId}) async => called.add((bookingId, businessId));

  @override
  Future<void> start(int bookingId, {int? businessId}) async => started.add((bookingId, businessId));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(Widget home, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  ),
);

void main() {
  testWidgets("the barber's screen is his chair alone: its line, its count, and calls name his employer", (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeApi();
    final queue = BusinessQueue(
      date: DateTime(2026, 10, 12),
      served: 4,
      chairs: const [ServiceChair(id: 1, name: 'كرسي 1', personName: 'أحمد')],
      items: [
        QueueItem(id: 10, turn: 3, status: 'accepted', chairId: 1, customerName: 'منى', startsAt: DateTime(2026, 10, 12, 10)),
        QueueItem(id: 11, turn: 5, status: 'accepted', chairId: 1, customerName: 'سارة', startsAt: DateTime(2026, 10, 12, 10, 45)),
      ],
    );

    await tester.pumpWidget(
      _host(const MyChairScreen(businessId: 77, businessName: 'صالون النجمة'), [
        chairsApiProvider.overrideWithValue(api),
        myChairQueueProvider(77).overrideWith((ref) async => queue),
      ]),
    );
    await tester.pumpAndSettle();

    // his face, his employer, and the day's count
    expect(find.text('أحمد'), findsOneWidget);
    expect(find.text('صالون النجمة'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // served today
    expect(find.text('2'), findsOneWidget); // waiting

    // the next customer is called — for the employer, not for the barber's own account
    await tester.tap(find.text('نادِ التالي'));
    await tester.pumpAndSettle();
    expect(api.called, [(10, 77)]);
  });

  testWidgets('an account with no chair is told so instead of seeing the house', (tester) async {
    await tester.pumpWidget(
      _host(const MyChairScreen(businessId: 77), [
        myChairQueueProvider(77).overrideWith((ref) async => BusinessQueue(date: DateTime(2026, 10, 12))),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('لم يُربط حسابك بكرسي'), findsOneWidget);
    expect(find.text('نادِ التالي'), findsNothing);
  });
}
