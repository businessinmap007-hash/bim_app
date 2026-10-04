import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/business_menu/data/models/store_terms.dart';
import 'package:bim_app/features/business_menu/presentation/widgets/store_terms_view.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «شروط المتجر»: a policy answered once by the store. The merchant's copy lists every option with
/// `selected`; the customer's lists only what the store answered.
void main() {
  final merchant = StoreTermGroup.listFrom([
    {
      'group_id': 51,
      'group_name': 'الاستبدال والإرجاع',
      'options': [
        {'id': 1, 'name': 'تغيير', 'selected': false},
        {'id': 2, 'name': 'استبدال', 'selected': true},
      ],
    },
  ]);

  test('a merchant copy keeps every option and which are selected', () {
    expect(merchant.single.options.map((o) => o.selected), [false, true]);
    expect(merchant.single.answer, 'استبدال');
  });

  test('a customer copy has no selected flag: everything listed is the answer', () {
    final customer = StoreTermGroup.listFrom([
      {
        'group_id': 51,
        'group_name': 'الاستبدال والإرجاع',
        'options': [
          {'id': 2, 'name': 'استبدال'},
          {'id': 1, 'name': 'تغيير'},
        ],
      },
    ]);

    expect(customer.single.answer, 'استبدال، تغيير');
  });

  test('nothing sent means no terms', () {
    expect(StoreTermGroup.listFrom(null), isEmpty);
  });

  Future<void> pumpView(WidgetTester tester, List<StoreTermGroup> terms) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: StoreTermsView(terms: terms)),
    ),
  );

  testWidgets('the view lists what the store answered, one line per policy', (tester) async {
    await pumpView(tester, merchant);

    expect(find.text('شروط المتجر'), findsOneWidget);
    expect(find.textContaining('الاستبدال والإرجاع'), findsOneWidget);
    expect(find.textContaining('استبدال'), findsWidgets);
    expect(find.text('تغيير'), findsNothing, reason: 'an option the store did not choose is not promised');
  });

  testWidgets('a store that answered nothing shows nothing', (tester) async {
    await pumpView(tester, StoreTermGroup.listFrom([
      {'group_id': 51, 'group_name': 'الاستبدال والإرجاع', 'options': [{'id': 1, 'name': 'تغيير', 'selected': false}]},
    ]));

    expect(find.text('شروط المتجر'), findsNothing);
  });
}
