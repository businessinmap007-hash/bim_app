import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/training/application/training_providers.dart';
import 'package:bim_app/features/training/data/models/exercise_library.dart';
import 'package:bim_app/features/training/data/training_api.dart';
import 'package:bim_app/features/training/presentation/widgets/exercise_picker_sheet.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeTrainingApi implements TrainingApi {
  @override
  Future<ExerciseLibrary> exerciseLibrary() async => ExerciseLibrary.fromJson({
    'categories': [
      {'id': 1, 'name': 'Chest'},
      {'id': 2, 'name': 'Cardio'},
    ],
    'kinds': [
      {'key': 'strength', 'label': 'Strength'},
      {'key': 'cardio', 'label': 'Cardio kind'},
    ],
    'equipment': [
      {'key': 'dumbbell', 'label': 'Dumbbell'},
      {'key': 'machine', 'label': 'Machine'},
    ],
    'exercises': [
      {
        'id': 10,
        'category_id': 1,
        'name': 'Bench press',
        'kind': 'strength',
        'equipment': 'dumbbell',
        'default_sets': 4,
        'default_reps': '8-10',
      },
      {'id': 11, 'category_id': 1, 'name': 'Push-up', 'kind': 'strength', 'equipment': null},
      {'id': 20, 'category_id': 2, 'name': 'Treadmill run', 'kind': 'cardio', 'equipment': 'machine'},
    ],
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  LibraryExercise? picked;

  Future<void> open(WidgetTester tester) async {
    picked = null;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [trainingApiProvider.overrideWithValue(_FakeTrainingApi())],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => picked = await pickLibraryExercise(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the catalogue with section, equipment and suggested sets', (tester) async {
    await open(tester);

    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Push-up'), findsOneWidget);
    expect(find.text('Treadmill run'), findsOneWidget);
    expect(find.text('Chest · Dumbbell · 4 × 8-10'), findsOneWidget);
  });

  testWidgets('section, kind, equipment and search all narrow the list', (tester) async {
    await open(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Cardio'));
    await tester.pump();
    expect(find.text('Treadmill run'), findsOneWidget);
    expect(find.text('Bench press'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All').first);
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Machine'));
    await tester.pump();
    expect(find.text('Treadmill run'), findsOneWidget);
    expect(find.text('Push-up'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All').last);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'push');
    await tester.pump();
    expect(find.text('Push-up'), findsOneWidget);
    expect(find.text('Bench press'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No matching exercises.'), findsOneWidget);
  });

  testWidgets('tapping an exercise returns it', (tester) async {
    await open(tester);

    await tester.tap(find.text('Bench press'));
    await tester.pumpAndSettle();

    expect(picked?.id, 10);
    expect(picked?.defaultSets, 4);
    expect(picked?.defaultReps, '8-10');
  });
}
