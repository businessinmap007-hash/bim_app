import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/training/application/training_providers.dart';
import 'package:bim_app/features/training/data/training_api.dart';
import 'package:bim_app/features/training_templates/application/training_templates_providers.dart';
import 'package:bim_app/features/training_templates/data/models/template_item.dart';
import 'package:bim_app/features/training_templates/data/models/training_template.dart';
import 'package:bim_app/features/training_templates/data/training_templates_api.dart';
import 'package:bim_app/features/training_templates/presentation/widgets/apply_template_sheet.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeTrainingApi implements TrainingApi {
  final lookups = <String>[];

  @override
  Future<({int id, String name, String phone})?> lookupClient(String query) async {
    lookups.add(query);
    return query == '01012345678' ? (id: 42, name: 'Sara', phone: '01012345678') : null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTemplatesApi implements TrainingTemplatesApi {
  Map<String, Object?>? applied;

  @override
  Future<int> apply(int id, {required int clientId, DateTime? startsOn, int? weeks}) async {
    applied = {'template': id, 'client': clientId, 'weeks': weeks, 'hasStart': startsOn != null};
    return 777;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _template = TrainingTemplate(id: 5, title: 'Push Pull Legs', durationWeeks: 8);

void main() {
  int? planId;
  late _FakeTrainingApi training;
  late _FakeTemplatesApi templates;

  Future<void> open(WidgetTester tester) async {
    planId = null;
    training = _FakeTrainingApi();
    templates = _FakeTemplatesApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trainingApiProvider.overrideWithValue(training),
          trainingTemplatesApiProvider.overrideWithValue(templates),
        ],
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
                onPressed: () async => planId = await showApplyTemplateSheet(context, _template),
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

  Finder createButton() => find.widgetWithText(FilledButton, 'Create the plan and send it to the client');

  testWidgets('the plan cannot be created until a client is found', (tester) async {
    await open(tester);

    expect(tester.widget<FilledButton>(createButton()).onPressed, isNull);
    // The template's own length is the starting point.
    expect(find.widgetWithText(TextField, '8'), findsOneWidget);
    expect(find.text('Type the phone or e-mail exactly as registered, then tap Search.'), findsOneWidget);
  });

  testWidgets('an exact phone finds the client, and applying sends the chosen weeks', (tester) async {
    await open(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Client phone or e-mail'), '01012345678');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(training.lookups, ['01012345678']);
    expect(find.text('Sara — 01012345678'), findsOneWidget);
    expect(tester.widget<FilledButton>(createButton()).onPressed, isNotNull);

    await tester.enterText(find.widgetWithText(TextField, '8'), '12');
    await tester.tap(createButton());
    await tester.pumpAndSettle();

    expect(templates.applied, {'template': 5, 'client': 42, 'weeks': 12, 'hasStart': true});
    expect(planId, 777, reason: 'the new plan\'s id comes back so it can be opened');
  });

  testWidgets('a phone nobody has says so and keeps the button off', (tester) async {
    await open(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Client phone or e-mail'), '0100');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('No client has exactly this phone or e-mail.'), findsOneWidget);
    expect(tester.widget<FilledButton>(createButton()).onPressed, isNull);
  });

  testWidgets('editing the term after a match un-confirms the client', (tester) async {
    await open(tester);

    final field = find.widgetWithText(TextField, 'Client phone or e-mail');
    await tester.enterText(field, '01012345678');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Sara — 01012345678'), findsOneWidget);

    // A different number is a different, unconfirmed person: no stale client id can be applied.
    await tester.enterText(field, '01012345679');
    await tester.pump();

    expect(find.text('Sara — 01012345678'), findsNothing);
    expect(tester.widget<FilledButton>(createButton()).onPressed, isNull);
  });

  test('a template carries its length and each exercise its programme', () {
    final t = TrainingTemplate.fromJson({
      'id': 1,
      'title': 'PPL',
      'duration_weeks': 6,
      'exercises': [
        {
          'id': 2,
          'name': 'Bench',
          'sort_order': 0,
          'day_label': 'Push',
          'set_weights': [20, 25.5, 30],
          'progress_every_weeks': 2,
          'progress_increment_kg': 5,
        },
        {'id': 3, 'name': 'Plank', 'sort_order': 1},
      ],
    });

    expect(t.durationWeeks, 6);
    final TemplateExercise bench = t.exercises[0];
    expect(bench.dayLabel, 'Push');
    expect(bench.setWeights, [20, 25.5, 30]);
    expect(bench.progressEveryWeeks, 2);
    expect(bench.progressIncrementKg, 5);
    expect(t.exercises[1].setWeights, isEmpty);
  });
}
