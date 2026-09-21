import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/discovery/application/discovery_providers.dart';
import 'package:bim_app/features/discovery/data/discovery_api.dart';
import 'package:bim_app/features/discovery/data/models/child_offering.dart';
import 'package:bim_app/features/discovery/presentation/screens/child_offerings_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeDiscoveryApi implements DiscoveryApi {
  final asked = <List<int>>[];

  @override
  Future<List<OfferingLine>> offeringLines({required int childId}) async => const [
    OfferingLine(key: '7', label: 'X-ray', optionIds: [7], offerings: 2),
    OfferingLine(key: '8:9', label: 'Scan — Full', optionIds: [8, 9], offerings: 1),
  ];

  @override
  Future<List<ChildOffering>> offerings({required int childId, List<int> optionIds = const [], int perPage = 50}) async {
    asked.add(optionIds);
    return [
      ChildOffering(
        id: 1,
        source: 'bookable',
        label: optionIds.isEmpty ? 'Everything' : 'Bone X-ray',
        price: 300,
        currency: 'EGP',
        businessId: 3,
        businessName: 'BIM Hospital',
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a line chip narrows the priced rows and rows show shop + price', (tester) async {
    final api = _FakeDiscoveryApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [discoveryApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ChildOfferingsScreen(childId: 4, title: 'Radiology'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Everything'), findsOneWidget);
    expect(find.text('BIM Hospital'), findsOneWidget);
    expect(find.text('300 EGP'), findsOneWidget);

    await tester.tap(find.text('Scan — Full (1)'));
    await tester.pumpAndSettle();

    expect(api.asked.last, [8, 9]);
    expect(find.text('Bone X-ray'), findsOneWidget);
  });
}
