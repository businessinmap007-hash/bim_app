import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/training/application/training_providers.dart';
import 'package:bim_app/features/training/data/models/set_log.dart';
import 'package:bim_app/features/training/data/models/training_plan.dart';
import 'package:bim_app/features/training/data/training_api.dart';
import 'package:bim_app/features/training/presentation/screens/trainer_photo_library_screen.dart';
import 'package:bim_app/features/training/presentation/screens/training_monthly_summary_screen.dart';
import 'package:bim_app/features/training/presentation/screens/training_plan_detail_screen.dart';
import 'package:bim_app/features/training/presentation/widgets/set_log_sheet.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeTrainingApi implements TrainingApi {
  final calls = <String>[];
  bool finishesTheDay = false;
  final List<LibraryPhoto> photos = [
    const LibraryPhoto(id: 1, url: 'http://localhost/trainer-photos/1?signature=x'),
    const LibraryPhoto(id: 2, url: 'http://localhost/trainer-photos/2?signature=x'),
  ];

  @override
  Future<SetConfirmation> completeRound(int planId, int exerciseId, {DateTime? forDate, int? reps, double? weight}) async {
    calls.add('complete $exerciseId reps=$reps weight=$weight');
    return SetConfirmation(
      round: LoggedSet(id: 99, roundNumber: 1, reps: reps, weight: weight),
      completedRounds: 1,
      totalSets: 3,
      sessionCompleted: finishesTheDay,
    );
  }

  @override
  Future<LoggedSet> updateRound(int planId, int exerciseId, int roundId, {int? reps, double? weight}) async {
    calls.add('update $roundId reps=$reps weight=$weight');
    return LoggedSet(id: roundId, roundNumber: 1, reps: reps, weight: weight);
  }

  @override
  Future<TrainingMonthlySummary> monthlySummary(int planId, {required String month, bool trainer = false}) async {
    calls.add('summary trainer=$trainer');
    return TrainingMonthlySummary.fromJson({
      'month': month,
      'sessions_completed': 2,
      'active_days': 3,
      'total_sets': 9,
      'total_reps': 90,
      'volume_kg': 4200.5,
      'exercises': [
        {'exercise_id': 1, 'name': 'Squat', 'sets_done': 6, 'total_reps': 60, 'max_weight': 80, 'volume_kg': 3000},
      ],
      'sessions': [
        {'date': '$month-06', 'exercises_count': 2, 'sets_count': 5, 'total_reps': 50, 'volume_kg': 2100},
      ],
      'progress': {'check_ins': 2, 'first_weight': 80, 'latest_weight': 78.5},
    });
  }

  @override
  Future<List<DayLogExercise>> dayLog(int planId, DateTime date) async => [
    DayLogExercise.fromJson({
      'name': 'Squat',
      'target_sets': 3,
      'target_reps': '10',
      'target_weight': 60,
      'sets': [
        {'id': 1, 'round_number': 1, 'reps': 10, 'weight': 60},
        {'id': 2, 'round_number': 2, 'reps': 9, 'weight': 62.5},
      ],
    }),
  ];

  @override
  Future<List<LibraryPhoto>> trainerPhotos() async => photos;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, _FakeTrainingApi api, {List<Override> extra = const []}) => ProviderScope(
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

TrainingPlan _plan({List<LoggedSet> today = const []}) => TrainingPlan(
  id: 7,
  title: 'Strength',
  status: 'active',
  trainerId: 1,
  exercises: [
    PlanExercise(
      id: 11,
      name: 'Squat',
      sets: 3,
      reps: '10-12',
      targetWeight: 60,
      completedRoundsToday: today.length,
      todayRounds: today,
    ),
  ],
);

void main() {
  test('the reps box starts from the first number of the prescription', () {
    expect(firstNumber('10'), 10);
    expect(firstNumber('10-12'), 10);
    expect(firstNumber('AMRAP'), isNull);
    expect(firstNumber(null), isNull);
    expect(formatWeight(60), '60');
    expect(formatWeight(42.5), '42.5');
    expect(const LoggedSet(id: 1, roundNumber: 1, reps: 10, weight: 60).label, '10 × 60');
    expect(const LoggedSet(id: 1, roundNumber: 1).label, '– × –');
  });

  testWidgets('confirming a set asks for reps and weight, prefilled from the prescription', (tester) async {
    final api = _FakeTrainingApi();
    await tester.pumpWidget(
      _app(
        const TrainingPlanDetailScreen(planId: 7),
        api,
        extra: [trainingPlanDetailProvider(7).overrideWith((ref) async => _plan())],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weight: 60 kg'), findsOneWidget, reason: 'the prescribed weight is shown');

    await tester.tap(find.text('Complete a round'));
    await tester.pumpAndSettle();

    expect(find.text('Log set 1'), findsOneWidget);
    // Reps start at the first number of "10-12", weight at the target.
    expect(find.widgetWithText(TextField, '10'), findsOneWidget);
    expect(find.widgetWithText(TextField, '60'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, '10'), '11');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(api.calls, ['complete 11 reps=11 weight=60.0']);
  });

  testWidgets('a set can be confirmed without numbers, and finishing the day says so', (tester) async {
    final api = _FakeTrainingApi()..finishesTheDay = true;
    await tester.pumpWidget(
      _app(
        const TrainingPlanDetailScreen(planId: 7),
        api,
        extra: [trainingPlanDetailProvider(7).overrideWith((ref) async => _plan())],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete a round'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm without details'));
    await tester.pumpAndSettle();

    expect(api.calls, ['complete 11 reps=null weight=null']);
    expect(find.text("Well done! You finished today's workout and your trainer was told."), findsOneWidget);
  });

  testWidgets('a logged set shows as a chip and can be corrected', (tester) async {
    final api = _FakeTrainingApi();
    await tester.pumpWidget(
      _app(
        const TrainingPlanDetailScreen(planId: 7),
        api,
        extra: [
          trainingPlanDetailProvider(7).overrideWith(
            (ref) async => _plan(today: const [LoggedSet(id: 5, roundNumber: 1, reps: 10, weight: 60)]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1: 10 × 60'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm without details'), findsNothing, reason: 'a correction has no "skip"');

    await tester.enterText(find.widgetWithText(TextField, '10'), '12');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(api.calls, ['update 5 reps=12 weight=60.0']);
  });

  testWidgets('the monthly summary shows totals and the trainer can open a finished day', (tester) async {
    final api = _FakeTrainingApi();
    await tester.pumpWidget(_app(const TrainingMonthlySummaryScreen(planId: 7, trainer: true), api));
    await tester.pumpAndSettle();

    expect(api.calls, ['summary trainer=true']);
    expect(find.text('9'), findsOneWidget); // sets
    expect(find.text('90'), findsOneWidget); // reps
    expect(find.text('4200.5'), findsOneWidget); // volume
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Weight: 80 to 78.5 kg'), findsOneWidget);

    await tester.scrollUntilVisible(find.byIcon(Icons.check_circle_outline), 200);
    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    // The day view: sets against the prescription.
    expect(find.text('3 × 10 · 60 kg'), findsOneWidget);
    expect(find.text('1: 10 × 60'), findsOneWidget);
    expect(find.text('2: 9 × 62.5'), findsOneWidget);
  });

  testWidgets('the trainee sees the month but has no per-day drill-down', (tester) async {
    final api = _FakeTrainingApi();
    await tester.pumpWidget(_app(const TrainingMonthlySummaryScreen(planId: 7), api));
    await tester.pumpAndSettle();

    expect(api.calls, ['summary trainer=false']);
    await tester.scrollUntilVisible(find.byIcon(Icons.check_circle_outline), 200);
    expect(find.byIcon(Icons.chevron_right), findsNothing, reason: 'only the trainer opens a day');
  });

  testWidgets('the photo library lists the trainer\'s photos', (tester) async {
    final api = _FakeTrainingApi();
    await tester.pumpWidget(_app(const TrainerPhotoLibraryScreen(), api));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNWidgets(2));
    expect(find.byIcon(Icons.close), findsNWidgets(2), reason: 'each photo can be deleted');
    expect(find.text('Add photo'), findsOneWidget);
  });

  testWidgets('picking from the library returns the ticked photos, capped', (tester) async {
    final api = _FakeTrainingApi();
    List<int>? picked;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => picked = await pickLibraryPhotos(context, maxCount: 1),
              child: const Text('open'),
            ),
          ),
        ),
        api,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final tiles = find.byType(Image);
    await tester.tap(tiles.at(0));
    await tester.pump();
    await tester.tap(tiles.at(1)); // over the cap of 1: ignored
    await tester.pump();
    expect(find.text('Attach (1)'), findsOneWidget);

    await tester.tap(find.text('Attach (1)'));
    await tester.pumpAndSettle();
    expect(picked, [1]);
  });
}
