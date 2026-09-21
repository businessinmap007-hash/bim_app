import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/network/paginated.dart';
import 'package:bim_app/features/offers/application/offers_providers.dart';
import 'package:bim_app/features/offers/data/models/commercial_offer.dart';
import 'package:bim_app/features/offers/data/offers_api.dart';
import 'package:bim_app/features/offers/presentation/screens/offers_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeOffersApi implements OffersApi {
  final requests = <({int? category, bool openNow})>[];

  @override
  Future<List<OfferCategory>> categories() async => const [
    OfferCategory(id: 5, nameAr: 'ملابس', nameEn: 'Clothing', offersCount: 24),
  ];

  @override
  Future<Paginated<CommercialOffer>> browse({
    String? q,
    String? sort,
    int? categoryId,
    bool openNow = false,
    int page = 1,
  }) async {
    requests.add((category: categoryId, openNow: openNow));
    return const Paginated(items: [], currentPage: 1, lastPage: 1, total: 0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('the category chips and open-now toggle narrow the offers list', (tester) async {
    final api = _FakeOffersApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [offersApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const OffersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clothing (24)'), findsOneWidget);

    await tester.tap(find.text('Clothing (24)'));
    await tester.pumpAndSettle();
    expect(api.requests.last, (category: 5, openNow: false));

    await tester.tap(find.text('Open now'));
    await tester.pumpAndSettle();
    expect(api.requests.last, (category: 5, openNow: true));

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(api.requests.last, (category: null, openNow: true));
  });
}
