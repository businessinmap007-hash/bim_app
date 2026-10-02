import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/business_menu/data/models/menu_vocabulary.dart';
import 'package:bim_app/features/menu_search/application/menu_search_providers.dart';
import 'package:bim_app/features/menu_search/data/menu_search_api.dart';
import 'package:bim_app/features/menu_search/data/models/menu_search.dart';
import 'package:bim_app/features/menu_search/presentation/screens/menu_search_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

SearchItem _car(int id, String shop, double price, {int? product = 9}) => SearchItem(
  id: id,
  name: 'تويوتا كورولا',
  price: price,
  catalogProductId: product,
  summary: '2021 · 42500 كم',
  shop: SearchShop(id: id, name: shop),
);

class _FakeSearchApi implements MenuSearchApi {
  final searches = <({String? kind, Map<String, String> query, int? product})>[];

  @override
  Future<List<SearchKind>> kinds() async => const [
    SearchKind(code: 'cars', name: 'سيارات', count: 3, fields: [
      DetailField(id: 1, code: 'model_year', name: 'سنة الصنع', dataType: 'number'),
      DetailField(id: 2, code: 'transmission', name: 'ناقل الحركة', dataType: 'select', options: [
        DetailOption(id: 11, name: 'أوتوماتيك'),
        DetailOption(id: 12, name: 'مانيوال'),
      ]),
    ]),
    SearchKind(code: 'laptops', name: 'لاب توب', count: 1, fields: []),
  ];

  @override
  Future<SearchPage> search({
    String? kind,
    String? q,
    SearchFilters filters = const SearchFilters(),
    String sort = 'price_asc',
    int? catalogProductId,
    int page = 1,
  }) async {
    searches.add((kind: kind, query: filters.toQuery(), product: catalogProductId));
    return SearchPage(
      items: [_car(1, 'معرض النور', 520000), _car(2, 'معرض الأمل', 480000)],
      facets: const {
        'model_year': SearchFacet(type: 'number', min: 2018, max: 2023),
        'transmission': SearchFacet(type: 'select', options: [(id: 11, name: 'أوتوماتيك', count: 2)]),
      },
      page: 1,
      lastPage: 1,
      total: 2,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a kind opens on its own, its filters narrow the results, and a known product compares across shops', (tester) async {
    final api = _FakeSearchApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [menuSearchApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MenuSearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Never a search with no kind — that would be every restaurant's menu too.
    expect(api.searches.first.kind, 'cars');
    expect(find.text('معرض النور'), findsOneWidget);
    expect(find.text('2 نتيجة'), findsOneWidget);
    expect(find.text('2021 · 42500 كم'), findsNWidgets(2));

    // The filter sheet is drawn from the kind's fields, hinted with what is on offer.
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('سنة الصنع'), findsOneWidget);
    expect(find.text('أوتوماتيك (2)'), findsOneWidget, reason: 'only what is on offer, with counts');
    expect(find.text('مانيوال (2)'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'من'), '2020');
    await tester.tap(find.text('أوتوماتيك (2)'));
    await tester.tap(find.text('عرض النتائج'));
    await tester.pumpAndSettle();

    expect(api.searches.last.query, {'model_year_min': '2020', 'transmission': '11'});
    expect(find.text('الفلاتر'), findsNothing);

    // Another kind has other fields: the old kind's filters are dropped.
    await tester.tap(find.text('لاب توب'));
    await tester.pumpAndSettle();
    expect(api.searches.last.kind, 'laptops');
    expect(api.searches.last.query, isEmpty);

    // Compare opens the product's own list of shops.
    await tester.tap(find.text('قارن الأسعار').first);
    await tester.pumpAndSettle();
    expect(api.searches.last.product, 9);
    expect(find.text('الأرخص'), findsOneWidget);
    expect(find.textContaining('عن الأرخص'), findsOneWidget);
  });
}
