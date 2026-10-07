import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/investigations/application/investigations_providers.dart';
import 'package:bim_app/features/investigations/data/investigations_api.dart';
import 'package:bim_app/features/investigations/data/models/investigation.dart';
import 'package:bim_app/features/investigations/presentation/screens/center_investigations_screen.dart';
import 'package:bim_app/features/investigations/presentation/screens/investigation_order_detail_screen.dart';
import 'package:bim_app/features/investigations/presentation/screens/issue_investigation_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «الطبيب يطلب تحاليل وأشعة والمريض يشاركها مع معمل مسجّل» — المالك، 2026-10-08.
class _FakeApi implements InvestigationsApi {
  final issuedCalls = <({int patientId, List<int> optionIds, String? notes})>[];
  final sentTo = <int>[];
  Map<int, double?>? savedPrices;

  var fixed = const InvestigationOrder(
    id: 5,
    status: InvestigationOrder.issued,
    doctor: InvestigationParty(id: 2, name: 'د. سارة'),
    items: [
      InvestigationItem(id: 1, kind: 'lab', name: 'صورة دم كاملة'),
      InvestigationItem(id: 2, kind: 'radiology', name: 'سونار بطن'),
    ],
    notes: 'صيام 10 ساعات',
  );

  @override
  Future<InvestigationCatalog> catalog() async => const InvestigationCatalog(
    lab: [CatalogTest(id: 10, name: 'صورة دم كاملة', kind: 'lab'), CatalogTest(id: 11, name: 'سكر صائم', kind: 'lab')],
    radiology: [CatalogTest(id: 20, name: 'سونار بطن', kind: 'radiology')],
  );

  @override
  Future<InvestigationOrder> issue({required int patientId, required List<int> optionIds, String? notes}) async {
    issuedCalls.add((patientId: patientId, optionIds: optionIds, notes: notes));

    return fixed;
  }

  @override
  Future<InvestigationOrder> order(int id) async => fixed;

  @override
  Future<List<InvestigationCenter>> centers(int orderId) async => const [
    InvestigationCenter(id: 7, name: 'معمل الأمل', covers: 2, of: 2, total: 430),
    InvestigationCenter(id: 8, name: 'معمل النور', covers: 1, of: 2, total: 395, missing: ['سونار بطن']),
  ];

  @override
  Future<InvestigationOrder> send(int orderId, int centerId) async {
    sentTo.add(centerId);

    return fixed;
  }

  @override
  Future<List<CenterTest>> priceList() async => const [
    CenterTest(optionId: 10, kind: 'lab', name: 'صورة دم كاملة', price: 100),
    CenterTest(optionId: 11, kind: 'lab', name: 'سكر صائم'),
  ];

  @override
  Future<List<CenterTest>> savePrices(Map<int, double?> prices) async {
    savedPrices = prices;

    return [
      CenterTest(optionId: 10, kind: 'lab', name: 'صورة دم كاملة', price: prices[10]),
      CenterTest(optionId: 11, kind: 'lab', name: 'سكر صائم', price: prices[11]),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, _FakeApi api) => ProviderScope(
  overrides: [investigationsApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: home,
  ),
);

void main() {
  test('an order reads its status, its steps and its files', () {
    final order = InvestigationOrder.fromJson({
      'id': 9,
      'status': 'accepted',
      'doctor': {'id': 2, 'name': 'د. سارة'},
      'patient': {'id': 3, 'name': 'محمد'},
      'center': {'id': 7, 'name': 'معمل'},
      'items': [
        {'id': 1, 'kind': 'lab', 'name': 'CBC', 'price': 100},
      ],
      'total': 100,
      'appointment_at': '2026-10-20T09:00:00+00:00',
      'result_files': <dynamic>[],
    });

    expect(order.step, 3);
    expect(order.canSend, isFalse);
    expect(order.canCancel, isFalse);
    expect(order.items.single.price, 100);
    expect(order.appointmentAt, isNotNull);
    expect(const InvestigationOrder(id: 1, status: 'issued').canSend, isTrue);
    expect(const InvestigationOrder(id: 1, status: 'declined').step, 0);
  });

  testWidgets('the doctor picks tests and exams from the lists and sends the order', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const IssueInvestigationScreen(patientId: 3, patientName: 'محمد علي'), api));
    await tester.pumpAndSettle();

    expect(find.text('للمريض: محمد علي'), findsOneWidget);
    expect(find.text('لم تختر فحصًا بعد'), findsOneWidget);

    await tester.tap(find.text('صورة دم كاملة'));
    await tester.tap(find.text('سكر صائم'));
    // the radiology list is its own tab
    await tester.tap(find.text('أشعة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سونار بطن'));
    await tester.pumpAndSettle();
    expect(find.text('في الطلب: 3'), findsOneWidget);

    await tester.tap(find.text('أرسل الطلب للمريض'));
    await tester.pumpAndSettle();

    expect(api.issuedCalls.single.patientId, 3);
    expect(api.issuedCalls.single.optionIds.toSet(), {10, 11, 20});
  });

  testWidgets('the patient sees what each centre charges for the whole order and shares it with one', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const InvestigationOrderDetailScreen(orderId: 5), api));
    await tester.pumpAndSettle();

    expect(find.text('من د. سارة'), findsOneWidget);
    expect(find.text('ملاحظة الطبيب: صيام 10 ساعات'), findsOneWidget);
    expect(find.text('معمل الأمل'), findsOneWidget);
    expect(find.text('430 ج'), findsOneWidget);
    expect(find.text('يغطي كل الفحوصات'), findsOneWidget);
    expect(find.text('يغطي 1 من 2'), findsOneWidget);
    expect(find.text('لا يصل الطلب لأي جهة إلا بعد أن تختارها أنت.'), findsOneWidget);

    // the first (best) centre is chosen; the patient picks another
    expect(find.text('شارك مع معمل الأمل'), findsOneWidget);
    await tester.tap(find.text('معمل النور'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('شارك مع معمل النور'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('شارك مع معمل النور'));
    await tester.pumpAndSettle();

    expect(api.sentTo, [8]);
  });

  testWidgets('a centre prices only the tests it does, in one list with the standard save button', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const CenterPriceListScreen(), api));
    await tester.pumpAndSettle();

    expect(find.text('تم الحفظ'), findsOneWidget, reason: 'nothing to save yet');

    await tester.enterText(find.byType(TextField).last, '60');
    await tester.pump();
    expect(find.text('حفظ'), findsOneWidget);

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(api.savedPrices, {10: 100.0, 11: 60.0});
    expect(find.text('تم الحفظ'), findsOneWidget);
  });
}
