import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/network/paginated.dart';
import 'package:bim_app/features/training/application/training_providers.dart';
import 'package:bim_app/features/training/data/models/trainer_weekly_summary.dart';
import 'package:bim_app/features/training/data/models/training_plan.dart';
import 'package:bim_app/features/training/data/training_api.dart';
import 'package:bim_app/features/training/presentation/screens/my_training_clients_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeTrainingApi implements TrainingApi {
  @override
  Future<Paginated<TrainingPlan>> myClientPlans({String? status, int page = 1}) async => const Paginated(
    items: [
      TrainingPlan(id: 1, title: 'Cut', status: 'active', trainerId: 5, clientName: 'Sara'),
      TrainingPlan(id: 2, title: 'Bulk', status: 'active', trainerId: 5, clientName: 'Omar'),
    ],
    currentPage: 1,
    lastPage: 1,
    total: 2,
  );

  @override
  Future<TrainerWeeklySummary> trainerWeeklySummary() async => TrainerWeeklySummary.fromJson({
    'from': '2026-09-19',
    'to': '2026-09-25',
    'plans': 2,
    'average_adherence': 40,
    'clients': [
      {
        'plan_id': 1,
        'weekly_target_rounds': 10,
        'completed_rounds': 8,
        'adherence_percent': 80,
        'active_days': 4,
        'check_ins': 2,
      },
      {'plan_id': 2, 'weekly_target_rounds': 0, 'completed_rounds': 0, 'adherence_percent': null},
    ],
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('the clients list leads with the average and shows each client\'s week', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [trainingApiProvider.overrideWithValue(_FakeTrainingApi())],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MyTrainingClientsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Your clients' average adherence this week: 40%"), findsOneWidget);
    expect(find.text('80% · 8 of 10 rounds · 4 active days · 2 check-ins'), findsOneWidget);
    expect(find.text('No exercises scheduled yet'), findsOneWidget, reason: 'a plan with no sets has no target to score');
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
