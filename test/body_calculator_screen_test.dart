import 'package:bim_app/features/training/presentation/screens/body_calculator_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => const MaterialApp(
  locale: Locale('ar'),
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: BodyCalculatorScreen(),
);

void main() {
  testWidgets('the result appears once age, height and weight are typed', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.text('اكتب العمر والطول والوزن لتظهر النتيجة.'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '30');
    await tester.enterText(fields.at(1), '175');
    await tester.enterText(fields.at(2), '80');
    await tester.pump();

    expect(find.text('26.1'), findsOneWidget);
    expect(find.text('وزن زائد'), findsOneWidget);
    expect(find.textContaining('56.7'), findsOneWidget);
  });

  testWidgets('a typing slip shows no result', (tester) async {
    await tester.pumpWidget(_app());
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '30');
    await tester.enterText(fields.at(1), '17');
    await tester.enterText(fields.at(2), '80');
    await tester.pump();

    expect(find.text('اكتب العمر والطول والوزن لتظهر النتيجة.'), findsOneWidget);
  });
}
