import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/booking/presentation/widgets/booking_grid_widgets.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _app(Widget bar, {double width = 390}) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(
    body: Align(alignment: Alignment.bottomCenter, child: SizedBox(width: width, child: bar)),
  ),
);

void main() {
  testWidgets('the date and the time sit on one line above the button, the kind and service above them', (tester) async {
    await tester.pumpWidget(
      _app(
        BookingSummaryBar(
          summary: 'كشف — تنظيف الأسنان وإزالة الجير',
          when: 'الثلاثاء، 13 أكتوبر 6:30 م',
          price: 300,
          label: 'اطلب الحجز',
          onPressed: () {},
        ),
      ),
    );

    final when = find.text('الثلاثاء، 13 أكتوبر 6:30 م');
    expect(when, findsOneWidget);

    final text = tester.widget<Text>(when);
    expect(text.maxLines, 1);
    expect(text.softWrap, isFalse);

    // one line: the whole text is as tall as a single line of its style
    expect(tester.getSize(when).height, lessThan(30));

    final summary = find.text('كشف — تنظيف الأسنان وإزالة الجير');
    expect(tester.getTopLeft(summary).dy, lessThan(tester.getTopLeft(when).dy));
    expect(tester.getBottomLeft(when).dy, lessThan(tester.getTopLeft(find.byType(FilledButton)).dy));
    expect(find.text('300 ج'), findsOneWidget);
  });

  testWidgets('a narrow phone shrinks the date line rather than breaking it', (tester) async {
    await tester.pumpWidget(
      _app(
        BookingSummaryBar(
          summary: 'قص وتصفيف',
          when: 'الثلاثاء، 13 أكتوبر 2026 — 10:45 صباحًا',
          price: 120,
          label: 'تأكيد الموعد',
          onPressed: () {},
        ),
        width: 260,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text('الثلاثاء، 13 أكتوبر 2026 — 10:45 صباحًا')).height, lessThan(30));
  });

  testWidgets('a bar with no date keeps its single summary line', (tester) async {
    await tester.pumpWidget(_app(BookingSummaryBar(summary: 'اختر يومًا ووقتًا للحجز', label: 'اطلب الحجز', onPressed: null)));

    expect(find.text('اختر يومًا ووقتًا للحجز'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
  });
}
