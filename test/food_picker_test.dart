import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/training/application/business_training_providers.dart';
import 'package:bim_app/features/training/data/models/food_library.dart';
import 'package:bim_app/features/training/presentation/widgets/food_picker_sheet.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «اضف جدول التغذية … ليختار منها المتخصص مباشرة الاكل مع امكانية اضافة من المتخصص لنوع غذاء» — المالك، 2026-10-08.
const _library = FoodLibrary(
  sections: [FoodSection(id: 1, name: 'خبز ونشويات'), FoodSection(id: 2, name: 'فواكه')],
  foods: [
    LibraryFood(id: 10, categoryId: 1, name: 'رغيف عيش بلدي', serving: 'رغيف (90 جم)', calories: 245, proteinG: 8, carbsG: 49, fatG: 1.5),
    LibraryFood(id: 11, categoryId: 2, name: 'تفاح', serving: 'حبة متوسطة (180 جم)', calories: 95),
    LibraryFood(id: 12, categoryId: 1, name: 'كشري أمي', serving: 'طبق (300 جم)', calories: 480, mine: true),
  ],
);

void main() {
  test('the calories of a pick are the food’s times the servings', () {
    expect(const PickedFood(_f, 2).calories, 490);
    expect(const PickedFood(_f, 0.5).calories, 123);
  });

  testWidgets('the specialist picks a food, chooses the servings and gets the calories worked out', (tester) async {
    PickedFood? result;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [foodLibraryProvider.overrideWith((ref) async => _library)],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(onPressed: () async => result = await pickLibraryFood(context), child: const Text('open')),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // the shared foods and the specialist's own, the own one marked
    expect(find.text('رغيف عيش بلدي'), findsOneWidget);
    expect(find.text('كشري أمي'), findsOneWidget);
    expect(find.text('من إضافتك'), findsOneWidget);
    expect(find.text('أضف صنفًا خاصًا'), findsOneWidget);

    // a section narrows the list
    await tester.tap(find.widgetWithText(ChoiceChip, 'فواكه'));
    await tester.pumpAndSettle();
    expect(find.text('رغيف عيش بلدي'), findsNothing);
    expect(find.text('تفاح'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'الكل'));
    await tester.pumpAndSettle();

    // pick the bread, two servings: 490
    await tester.tap(find.text('رغيف عيش بلدي'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('490 سعرة'), findsOneWidget);

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(result!.food.id, 10);
    expect(result!.servings, 2);
    expect(result!.calories, 490);
  });
}

const _f = LibraryFood(id: 1, categoryId: 1, name: 'x', serving: 's', calories: 245);
