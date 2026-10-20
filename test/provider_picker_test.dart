import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/assignment/assignee.dart';
import 'package:bim_app/core/assignment/widgets/provider_picker.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: child),
);

void main() {
  const people = [
    Assignee(id: 1, name: 'Ahmed', title: 'Senior barber'),
    Assignee(id: 2, name: 'Sara'),
  ];

  testWidgets('lists «anyone» first and then each provider with his title', (tester) async {
    int? picked = -1;
    await tester.pumpWidget(_wrap(ProviderPicker(providers: people, selected: null, onPick: (id) => picked = id)));

    expect(find.text('Anyone available'), findsOneWidget);
    expect(find.text('Ahmed — Senior barber'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);

    await tester.tap(find.text('Sara'));
    expect(picked, 2);

    await tester.tap(find.text('Anyone available'));
    expect(picked, isNull);
  });

  testWidgets('draws nothing for a business with no providers', (tester) async {
    await tester.pumpWidget(_wrap(ProviderPicker(providers: const [], selected: null, onPick: (_) {})));

    expect(find.byType(ChoiceChip), findsNothing);
  });
}
