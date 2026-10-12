import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/business/data/models/business_profile.dart';
import 'package:bim_app/features/specialty_services/application/specialty_services_providers.dart';
import 'package:bim_app/features/specialty_services/data/specialty_services_api.dart';
import 'package:bim_app/features/specialty_services/data/models/specialty_service.dart';
import 'package:bim_app/features/specialty_services/presentation/screens/specialty_services_manage_screen.dart';
import 'package:bim_app/features/specialty_services/presentation/widgets/specialty_widgets.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:bim_app/l10n/app_localizations_ar.dart';
import 'package:bim_app/l10n/app_localizations_en.dart';

/// «أنشئ قائمة خدمات عيادات الأسنان» — المالك، 2026-10-13.
class _FakeApi implements SpecialtyServicesApi {
  Map<int, double?>? saved;
  List<int>? removed;

  @override
  Future<List<ServiceOfferingSection>> offered(int clinicId) async => const [
    ServiceOfferingSection(
      kind: 'preventive',
      services: [ServiceOffering(id: 11, name: 'تنظيف الأسنان وإزالة الجير', price: 400)],
    ),
    ServiceOfferingSection(kind: 'surgical', services: [ServiceOffering(id: 12, name: 'زراعة سن')]),
  ];

  @override
  Future<List<ServiceCatalogSection>> catalog() async => const [
    ServiceCatalogSection(
      kind: 'preventive',
      entries: [
        ServiceCatalogEntry(id: 11, name: 'تنظيف الأسنان وإزالة الجير', offered: true, price: 400),
        ServiceCatalogEntry(id: 12, name: 'تلميع الأسنان'),
      ],
    ),
    ServiceCatalogSection(kind: 'cosmetic'),
  ];

  @override
  Future<List<ServiceCatalogSection>> save(Map<int, double?> offered, List<int> removed) async {
    saved = offered;
    this.removed = removed;

    return catalog();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, _FakeApi api) => ProviderScope(
  overrides: [specialtyServicesApiProvider.overrideWithValue(api)],
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
  testWidgets('the clinic ticks what it does, prices it, and saves with the standard button', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const SpecialtyServicesManageScreen(), api));
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

  test('the page and the account carry the specialty-services flags and default to off', () {
    expect(BusinessSections.fromJson({'specialty_services': true}).specialtyServices, isTrue);
    expect(BusinessSections.fromJson(const {}).specialtyServices, isFalse);

    final user = AuthUser.fromJson({'id': 1, 'specialty_services': true});
    expect(user.hasSpecialtyServices, isTrue);
    expect(AuthUser.fromJson({'id': 2}).hasSpecialtyServices, isFalse);
  });

  test('every kind of every specialty has its own heading in both languages', () {
    for (final l10n in [AppLocalizationsAr(), AppLocalizationsEn()]) {
      final labels = [for (final k in specialtyKinds) specialtyKindLabel(l10n, k)];

      expect(labels.toSet().length, specialtyKinds.length, reason: 'each kind is told apart: $labels');
      expect(labels.every((l) => l.trim().isNotEmpty), isTrue);
    }

    expect(specialtyKindLabel(AppLocalizationsAr(), 'injectables'), 'الحقن التجميلية');
    expect(specialtyKindLabel(AppLocalizationsAr(), 'preventive'), 'الوقاية والتنظيف');
  });
}
