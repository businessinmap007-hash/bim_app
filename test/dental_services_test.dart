import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/business/data/models/business_profile.dart';
import 'package:bim_app/features/dental/application/dental_providers.dart';
import 'package:bim_app/features/dental/data/dental_api.dart';
import 'package:bim_app/features/dental/data/models/dental_service.dart';
import 'package:bim_app/features/dental/presentation/screens/dental_services_manage_screen.dart';
import 'package:bim_app/features/dental/presentation/widgets/dental_services_tab.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «أنشئ قائمة خدمات عيادات الأسنان» — المالك، 2026-10-13.
class _FakeApi implements DentalApi {
  Map<int, double?>? saved;
  List<int>? removed;

  @override
  Future<List<DentalOfferingSection>> offered(int clinicId) async => const [
    DentalOfferingSection(
      kind: 'preventive',
      services: [DentalOffering(id: 11, name: 'تنظيف الأسنان وإزالة الجير', price: 400)],
    ),
    DentalOfferingSection(kind: 'surgical', services: [DentalOffering(id: 12, name: 'زراعة سن')]),
  ];

  @override
  Future<List<DentalCatalogSection>> catalog() async => const [
    DentalCatalogSection(
      kind: 'preventive',
      entries: [
        DentalCatalogEntry(id: 11, name: 'تنظيف الأسنان وإزالة الجير', offered: true, price: 400),
        DentalCatalogEntry(id: 12, name: 'تلميع الأسنان'),
      ],
    ),
    DentalCatalogSection(kind: 'cosmetic'),
  ];

  @override
  Future<List<DentalCatalogSection>> save(Map<int, double?> offered, List<int> removed) async {
    saved = offered;
    this.removed = removed;

    return catalog();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, _FakeApi api) => ProviderScope(
  overrides: [dentalApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  ),
);

void main() {
  testWidgets('a patient reads the clinic\'s services by kind with a price or «after the exam»', (tester) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: const SliverToBoxAdapter(child: SizedBox(height: 10)),
              ),
            ],
            body: const DentalServicesTab(clinicId: 5),
          ),
        ),
        _FakeApi(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الوقاية والتنظيف'), findsOneWidget);
    expect(find.text('الجراحة والزراعة'), findsOneWidget);
    expect(find.text('تنظيف الأسنان وإزالة الجير'), findsOneWidget);
    expect(find.text('400 ج'), findsOneWidget);
    expect(find.text('السعر بعد الكشف'), findsOneWidget);
  });

  testWidgets('the clinic ticks what it does, prices it, and saves with the standard button', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const DentalServicesManageScreen(), api));
    await tester.pumpAndSettle();

    expect(find.text('تم الحفظ'), findsOneWidget, reason: 'nothing to save yet');
    // a kind with nothing in it draws no heading
    expect(find.text('تجميل الأسنان'), findsNothing);

    // tick the polishing and price it; untick the cleaning
    final boxes = find.byType(Checkbox);
    await tester.tap(boxes.at(1));
    await tester.tap(boxes.at(0));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '150');
    await tester.pump();

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(api.saved, {12: 150.0});
    expect(api.removed, [11]);
  });

  test('the page and the account carry the dental flags and default to off', () {
    expect(BusinessSections.fromJson({'dental': true}).dental, isTrue);
    expect(BusinessSections.fromJson(const {}).dental, isFalse);

    final user = AuthUser.fromJson({'id': 1, 'dental_clinic': true});
    expect(user.dentalClinic, isTrue);
    expect(AuthUser.fromJson({'id': 2}).dentalClinic, isFalse);
  });
}
