import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/table/application/table_providers.dart';
import 'package:bim_app/features/table/data/table_api.dart';
import 'package:bim_app/features/table/presentation/screens/table_calls_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeTableApi implements TableApi {
  final calls = <TableCall>[
    const TableCall(id: 1, type: 'waiter', tableLabel: 'T4'),
    const TableCall(id: 2, type: 'bill', tableLabel: 'T7', note: 'card'),
  ];
  final resolved = <int>[];

  @override
  Future<List<TableCall>> pendingCalls() async => List.of(calls);

  @override
  Future<void> resolveCall(int id) async {
    resolved.add(id);
    calls.removeWhere((c) => c.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeTableApi api) => ProviderScope(
  overrides: [tableApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const TableCallsScreen(),
  ),
);

void main() {
  testWidgets('pending calls are listed and one can be marked handled', (tester) async {
    final api = _FakeTableApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('Table T4'), findsOneWidget);
    expect(find.text('Call waiter'), findsOneWidget);
    expect(find.text('Ask for the bill · card'), findsOneWidget);

    await tester.tap(find.text('Handled').first);
    await tester.pumpAndSettle();

    expect(api.resolved, [1]);
    expect(find.text('Table T4'), findsNothing);
    expect(find.text('Table T7'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an empty queue says so', (tester) async {
    final api = _FakeTableApi()..calls.clear();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    expect(find.text('No table is calling right now.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
