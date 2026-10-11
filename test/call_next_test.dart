import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/chairs/application/chairs_providers.dart';
import 'package:bim_app/features/chairs/data/chairs_api.dart';
import 'package:bim_app/features/chairs/data/models/service_chair.dart';
import 'package:bim_app/features/chairs/presentation/screens/call_next_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeApi implements ChairsApi {
  final called = <int>[];
  final started = <int>[];
  final finished = <int>[];

  @override
  Future<void> call(int bookingId, {int? businessId}) async => called.add(bookingId);

  @override
  Future<void> start(int bookingId, {int? businessId}) async => started.add(bookingId);

  @override
  Future<void> finish(int bookingId, {int? businessId}) async => finished.add(bookingId);

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
  testWidgets('each chair is its own line: its serving turn, its called turn and the first waiting one to call', (tester) async {
    // a tall screen: the whole queue is on it at once
    tester.view.physicalSize = const Size(1000, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeApi();
    final day = DateTime(2026, 10, 12);
    final queue = BusinessQueue(
      date: day,
      chairs: const [ServiceChair(id: 1, name: 'كرسي 1', personName: 'أحمد'), ServiceChair(id: 2, name: 'كرسي 2', personName: 'محمود')],
      items: [
        QueueItem(id: 10, turn: 1, status: 'in_progress', chairId: 1, customerName: 'منى', startsAt: DateTime(2026, 10, 12, 10)),
        QueueItem(id: 11, turn: 3, status: 'accepted', chairId: 1, customerName: 'سارة', startsAt: DateTime(2026, 10, 12, 10, 45)),
        QueueItem(id: 12, turn: 4, status: 'accepted', chairId: 1, customerName: 'هدى', startsAt: DateTime(2026, 10, 12, 11, 30)),
        QueueItem(id: 20, turn: 2, status: 'accepted', chairId: 2, customerName: 'عم سعيد', walkIn: true, calledAt: DateTime(2026, 10, 12, 10), startsAt: DateTime(2026, 10, 12, 10)),
      ],
    );

    await tester.pumpWidget(
      _host(const CallNextScreen(), [
        chairsApiProvider.overrideWithValue(api),
        businessQueueProvider.overrideWith((ref) async => queue),
      ]),
    );
    await tester.pumpAndSettle();

    // both barbers are shown (once in the filter row, once as a group header)
    expect(find.text('أحمد'), findsWidgets);
    expect(find.text('محمود'), findsWidgets);
    // only the first waiting turn of a chair has the call button
    expect(find.text('نادِ التالي'), findsOneWidget);
    await tester.tap(find.text('نادِ التالي'));
    await tester.pumpAndSettle();
    expect(api.called, [11]);

    // the serving one is finished, the called one is started
    await tester.tap(find.text('تمّت الخدمة'));
    await tester.pumpAndSettle();
    expect(api.finished, [10]);
    await tester.tap(find.text('ابدأ الخدمة'));
    await tester.pumpAndSettle();
    expect(api.started, [20]);
  });
}
