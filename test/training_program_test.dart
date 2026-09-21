import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/training/application/training_providers.dart';
import 'package:bim_app/features/training/data/models/body_report.dart';
import 'package:bim_app/features/training/data/models/set_log.dart';
import 'package:bim_app/features/training/data/models/training_plan.dart';
import 'package:bim_app/features/training/data/training_api.dart';
import 'package:bim_app/features/training/presentation/screens/training_plan_detail_screen.dart';
import 'package:bim_app/features/training/presentation/screens/training_plan_manage_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeTrainingApi implements TrainingApi {
  final calls = <String>[];
  final TrainingPlan current;

  _FakeTrainingApi(this.current);

  @override
  Future<TrainingPlan> businessPlan(int id) async => current;

  @override
  Future<List<BodyReport>> bodyReports(int planId) async => const [];

  @override
  Future<void> updateProgram(int planId, {int? weeks, int? everyWeeks, double? incrementKg}) async {
    calls.add('program weeks=$weeks every=$everyWeeks inc=$incrementKg');
  }

  @override
  Future<SetConfirmation> completeRound(int planId, int exerciseId, {DateTime? forDate, int? reps, double? weight}) async {
    calls.add('complete reps=$reps weight=$weight');
    return SetConfirmation(round: LoggedSet(id: 1, roundNumber: 1, reps: reps, weight: weight), completedRounds: 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, _FakeTrainingApi api, {List<Override> extra = const []}) => ProviderScope(
  key: UniqueKey(), // a fresh scope per pump, so cached provider data never leaks between iterations
  overrides: [trainingApiProvider.overrideWithValue(api), ...extra],
  child: MaterialApp(
    locale: const Locale('en'),
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

TrainingPlan _programme({int completedToday = 0}) => TrainingPlan(
  id: 7,
  title: 'Push Pull Legs',
  status: 'active',
  trainerId: 1,
  clientName: 'Sara',
  weekNumber: 3,
  totalWeeks: 8,
  exercises: [
    PlanExercise(
      id: 11,
      name: 'Bench press',
      dayOfWeek: 1,
      dayLabel: 'Push',
      sets: 3,
      reps: '8',
      currentTargets: const [25, 30, 35],
      nextTargets: const [30, 35, 40],
      completedRoundsToday: completedToday,
    ),
  ],
);

void main() {
  test('weights are read the way a trainer writes them', () {
    expect(parseWeightList('20-25-30'), [20, 25, 30]);
    expect(parseWeightList('20,25,30'), [20, 25, 30], reason: 'a comma separates weights, it is not a decimal point');
    expect(parseWeightList('20 25 30'), [20, 25, 30]);
    expect(parseWeightList('42.5'), [42.5]);
    expect(parseWeightList(''), isEmpty);
    expect(formatWeightList(const [25, 30, 35]), '25 · 30 · 35');
    expect(formatWeightList(const [42.5, 45]), '42.5 · 45');
  });

  test('the programme fields are read from the server', () {
    final plan = TrainingPlan.fromJson({
      'id': 1,
      'title': 'P',
      'status': 'active',
      'week_number': 3,
      'total_weeks': 8,
      'exercises': [
        {
          'id': 2,
          'name': 'Bench',
          'day_label': 'Push',
          'current_targets': [25, 30.5],
          'next_targets': [30, 35.5],
        },
        {'id': 3, 'name': 'Plank'},
      ],
    });

    expect(plan.weekNumber, 3);
    expect(plan.totalWeeks, 8);
    expect(plan.exercises![0].dayLabel, 'Push');
    expect(plan.exercises![0].currentTargets, [25, 30.5]);
    expect(plan.exercises![0].nextTargets, [30, 35.5]);
    expect(plan.exercises![1].currentTargets, isEmpty);
    expect(plan.exercises![1].nextTargets, isEmpty);
  });

  testWidgets('the trainee sees the week, the day name and this week\'s and next week\'s weights', (tester) async {
    final api = _FakeTrainingApi(_programme());
    await tester.pumpWidget(
      _app(
        const TrainingPlanDetailScreen(planId: 7),
        api,
        extra: [trainingPlanDetailProvider(7).overrideWith((ref) async => _programme())],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Week 3 of 8'), findsOneWidget);
    expect(find.text('Monday · Push'), findsOneWidget);
    expect(find.text('This week: 25 · 30 · 35 kg'), findsOneWidget);
    expect(find.text('Next week: 30 · 35 · 40 kg'), findsOneWidget);
  });

  testWidgets('each set starts at that set\'s own weight for the week', (tester) async {
    for (final (done, expected) in [(0, '25'), (1, '30'), (2, '35')]) {
      final api = _FakeTrainingApi(_programme(completedToday: done));
      await tester.pumpWidget(
        _app(
          const TrainingPlanDetailScreen(planId: 7),
          api,
          extra: [trainingPlanDetailProvider(7).overrideWith((ref) async => _programme(completedToday: done))],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete a round'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, expected),
        findsOneWidget,
        reason: 'set ${done + 1} of the ramp 25-30-35 should start at $expected',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(api.calls.single, 'complete reps=8 weight=$expected.0');
    }
  });

  testWidgets('the trainer sets the length and the climb for the whole plan', (tester) async {
    final api = _FakeTrainingApi(_programme());
    await tester.pumpWidget(_app(const TrainingPlanManageScreen(planId: 7), api));
    await tester.pumpAndSettle();

    // The programme card shows where the plan stands, and this week's weights are on the exercise.
    expect(find.text('Programme'), findsOneWidget);
    expect(find.text('Week 3 of 8'), findsOneWidget);
    expect(find.textContaining('25 · 30 · 35 kg'), findsOneWidget);

    await tester.tap(find.text('Programme'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '12');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '2.5');
    await tester.tap(find.text('Apply to every exercise'));
    await tester.pumpAndSettle();

    expect(api.calls, ['program weeks=12 every=2 inc=2.5']);
  });
}
