import 'package:bim_app/features/business/data/models/menu_item_summary.dart';
import 'package:bim_app/features/business/presentation/widgets/menu_item_grid_card.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:bim_app/shared/widgets/equal_height_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// «اسفل الكارت مساحة كبيرة فارغة لا لازمة ليها» — a row is as tall as its tallest card, no
/// taller: two cards of different content come out the same height, and that height is
/// what the taller one needs (not a fixed guess).
void main() {
  Widget host(Widget child) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: child))),
      );

  MenuItemSummary item(int id, {String? label, String? summary}) => MenuItemSummary(
        id: id,
        name: 'منتج $id',
        description: '',
        offeringLabel: label,
        imageUrls: const [],
        basePrice: 1000,
        variants: const [],
        extras: const [],
        cardSummary: summary,
      );

  testWidgets('cells of one row share the height of the tallest, and the grid adds nothing', (tester) async {
    await tester.pumpWidget(
      host(
        EqualHeightGrid(
          columns: 2,
          mainAxisSpacing: 6,
          children: [
            MenuItemGridCard(item: item(1)),
            MenuItemGridCard(item: item(2, label: 'غرفة نوم — ألترا كلاسيك — زان — أبلاكاش', summary: 'تفاصيل تانية طويلة جدا لتاخد سطرين')),
            MenuItemGridCard(item: item(3)),
          ],
        ),
      ),
    );

    final short = tester.getSize(find.byType(MenuItemGridCard).at(0)).height;
    final tall = tester.getSize(find.byType(MenuItemGridCard).at(1)).height;
    final alone = tester.getSize(find.byType(MenuItemGridCard).at(2)).height;

    expect(short, tall, reason: 'the shorter card is stretched to its neighbour');
    expect(alone, lessThan(tall), reason: 'a row of plainer cards is shorter — no shared fixed height');

    // The grid is exactly: row 1 + gap + row 2.
    expect(tester.getSize(find.byType(EqualHeightGrid)).height, tall + 6 + alone);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a last row with a missing cell keeps its column width', (tester) async {
    await tester.pumpWidget(host(EqualHeightGrid(columns: 3, children: [MenuItemGridCard(item: item(1)), MenuItemGridCard(item: item(2))])));

    final full = tester.getSize(find.byType(EqualHeightGrid)).width;
    final cell = tester.getSize(find.byType(MenuItemGridCard).first).width;

    expect(cell, closeTo((full - 20) / 3, 0.01));
  });
}
