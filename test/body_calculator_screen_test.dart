import 'package:bim_app/features/training/application/body_calculator_providers.dart';
import 'package:bim_app/features/training/data/body_measurement_store.dart';
import 'package:bim_app/features/training/presentation/screens/body_calculator_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app({RecordedBodyData recorded = const RecordedBodyData()}) {
  return ProviderScope(
    overrides: [recordedBodyDataProvider.overrideWith((ref) async => recorded)],
    child: const MaterialApp(
      locale: Locale('ar'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BodyCalculatorScreen(),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the result appears once age, height and weight are typed', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(
      find.text('اكتب العمر والطول والوزن لتظهر النتيجة.'),
      findsOneWidget,
    );

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
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '30');
    await tester.enterText(fields.at(1), '17');
    await tester.enterText(fields.at(2), '80');
    await tester.pump();

    expect(
      find.text('اكتب العمر والطول والوزن لتظهر النتيجة.'),
      findsOneWidget,
    );
  });

  testWidgets('the weight already recorded on the account fills the box', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        recorded: RecordedBodyData(
          weightKg: 82.5,
          weightOn: DateTime(2026, 10, 12),
          fatPercent: 22,
          reportOn: DateTime(2026, 10, 12),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('82.5'), findsWidgets);
    final weightField = tester.widget<TextField>(find.byType(TextField).at(2));
    expect(weightField.controller!.text, '82.5');
  });

  testWidgets('saving keeps the measurement and the profile on the phone', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '30');
    await tester.enterText(fields.at(1), '175');
    await tester.enterText(fields.at(2), '80');
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('حفظ القياس على هاتفي'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('حفظ القياس على هاتفي'));
    await tester.pumpAndSettle();

    final store = BodyMeasurementStore();
    final history = await store.readHistory(0);
    expect(history, hasLength(1));
    expect(history.first.weightKg, 80);
    expect(history.first.bmi, closeTo(26.12, 0.01));
    final profile = await store.readProfile(0);
    expect(profile.heightCm, 175);
    expect(find.text('قياساتي المحفوظة'), findsOneWidget);

    // a new visit starts with the remembered data: only the weight is typed
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final again = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(again.controller!.text, '175');
  });
}
