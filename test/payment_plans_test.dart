import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/business/data/models/menu_item_summary.dart';
import 'package:bim_app/features/business_menu/data/models/menu_item.dart';
import 'package:bim_app/features/cart/presentation/widgets/payment_plan_picker.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «خطط الدفع كاش أو أقساط» — a plan is a markup over the cash price, picked on the line.
void main() {
  final plan = MenuItemPaymentPlan.fromJson({'id': 7, 'months': 12, 'down': 12000, 'markup_percent': 20.0});

  test('a plan prices a unit as the cash price plus its markup, and splits what is left after the down payment', () {
    expect(plan.unitPrice(30000), 36000);
    expect(plan.monthly(30000), 2000, reason: '(36000 − 12000) / 12');
    expect(plan.unitPrice(40000), 48000, reason: 'the markup follows a changed cash price');
  });

  test('the merchant reads a plan back as the total one unit costs on it', () {
    final row = PaymentPlanRow.fromJson({'months': 12, 'down': 12000, 'unit_price': 36000});

    expect((row.months, row.down, row.totalPrice), (12, 12000.0, 36000.0));
  });

  Future<void> pump(WidgetTester tester, List<MenuItemPaymentPlan> plans, ValueChanged<int?> onChanged, {int? selected}) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PaymentPlanPicker(cashUnitPrice: 30000, plans: plans, selectedPlanId: selected, onChanged: onChanged),
      ),
    ),
  );

  testWidgets('cash and each plan are offered with their price; picking a plan reports its id', (tester) async {
    int? picked = -1;
    await pump(tester, [plan], (id) => picked = id);

    expect(find.text('كاش'), findsOneWidget);
    expect(find.text('30000'), findsOneWidget);
    expect(find.text('36000'), findsOneWidget);

    await tester.tap(find.text('تقسيط على 12 شهر'));
    await tester.pump();
    expect(picked, 7);

    await pump(tester, [plan], (id) => picked = id, selected: 7);
    await tester.tap(find.text('كاش'));
    await tester.pump();
    expect(picked, isNull, reason: 'cash = no plan');
  });

  testWidgets('an item that sells for cash only shows no payment choice', (tester) async {
    await pump(tester, const [], (_) {});

    expect(find.text('كاش'), findsNothing);
  });
}
