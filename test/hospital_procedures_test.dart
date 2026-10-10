import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/hospital/application/hospital_providers.dart';
import 'package:bim_app/features/hospital/data/hospital_api.dart';
import 'package:bim_app/features/hospital/data/models/hospital_procedure.dart';
import 'package:bim_app/features/hospital/presentation/screens/hospital_procedure_requests_screen.dart';
import 'package:bim_app/features/hospital/presentation/screens/hospital_procedures_manage_screen.dart';
import 'package:bim_app/features/hospital/presentation/screens/my_procedure_requests_screen.dart';
import 'package:bim_app/features/hospital/presentation/widgets/hospital_procedures_tab.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «إجراء طبي في المستشفى» — المالك، 2026-10-10.
class _FakeApi implements HospitalApi {
  final asked = <int>[];
  final cancelled = <int>[];
  final declined = <int>[];
  Map<int, double?>? saved;
  List<int>? removed;

  @override
  Future<List<ProcedureOfferingSection>> offeredProcedures(int hospitalId) async => const [
    ProcedureOfferingSection(kind: 'surgery', procedures: [
      ProcedureOffering(id: 11, name: 'استئصال الزائدة الدودية', price: 12000),
      ProcedureOffering(id: 12, name: 'تغيير مفصل الركبة'),
    ]),
    ProcedureOfferingSection(kind: 'endoscopy', procedures: [ProcedureOffering(id: 13, name: 'منظار المعدة', price: 1500)]),
  ];

  @override
  Future<ProcedureRequestItem> requestProcedure({required int offeringId, DateTime? preferredDate, String? notes}) async {
    asked.add(offeringId);

    return const ProcedureRequestItem(id: 1, status: 'requested', kind: 'surgery', name: 'x');
  }

  @override
  Future<List<ProcedureRequestItem>> myProcedureRequests() async => const [
    ProcedureRequestItem(id: 5, status: 'requested', kind: 'surgery', name: 'تغيير مفصل الركبة', hospitalName: 'مستشفى الشفاء'),
    ProcedureRequestItem(id: 6, status: 'completed', kind: 'endoscopy', name: 'منظار المعدة', price: 1500, hospitalName: 'مستشفى الشفاء'),
  ];

  @override
  Future<ProcedureRequestItem> cancelProcedureRequest(int id) async {
    cancelled.add(id);

    return const ProcedureRequestItem(id: 5, status: 'cancelled', kind: 'surgery', name: 'x');
  }

  @override
  Future<List<ProcedureCatalogSection>> procedureCatalog() async => const [
    ProcedureCatalogSection(kind: 'surgery', entries: [
      ProcedureCatalogEntry(id: 11, name: 'استئصال الزائدة الدودية', offered: true, price: 12000),
      ProcedureCatalogEntry(id: 12, name: 'تغيير مفصل الركبة'),
    ]),
    ProcedureCatalogSection(kind: 'endoscopy'),
    ProcedureCatalogSection(kind: 'procedure'),
  ];

  @override
  Future<List<ProcedureCatalogSection>> saveProcedures(Map<int, double?> offered, List<int> removed) async {
    saved = offered;
    this.removed = removed;

    return procedureCatalog();
  }

  @override
  Future<List<ProcedureRequestItem>> hospitalProcedureRequests(String tab) async => tab == 'incoming'
      ? const [ProcedureRequestItem(id: 9, status: 'requested', kind: 'surgery', name: 'ولادة قيصرية', patientName: 'منى علي', patientPhone: '0100')]
      : const [];

  @override
  Future<ProcedureRequestItem> declineProcedure(int id, {String? note}) async {
    declined.add(id);

    return const ProcedureRequestItem(id: 9, status: 'declined', kind: 'surgery', name: 'x');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, _FakeApi api) => ProviderScope(
  overrides: [hospitalApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: home,
  ),
);

void main() {
  testWidgets('a patient reads the procedures by kind, with a price or «after assessment», and asks for one', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(
      Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverOverlapAbsorber(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context), sliver: const SliverToBoxAdapter(child: SizedBox(height: 10))),
          ],
          body: const HospitalProceduresTab(hospitalId: 5),
        ),
      ),
      api,
    ));
    await tester.pumpAndSettle();

    expect(find.text('عمليات جراحية'), findsOneWidget);
    expect(find.text('مناظير'), findsOneWidget);
    expect(find.text('12000 ج'), findsOneWidget);
    expect(find.text('السعر بعد التقييم'), findsOneWidget);

    await tester.tap(find.text('تغيير مفصل الركبة'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'اطلب الإجراء'));
    await tester.pumpAndSettle();

    expect(api.asked, [12]);
  });

  testWidgets('the patient sees her requests and cancels one that is still open', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const MyProcedureRequestsScreen(), api));
    await tester.pumpAndSettle();

    expect(find.text('بانتظار رد المستشفى'), findsOneWidget);
    expect(find.text('تم'), findsOneWidget);
    // only the open one offers a cancel
    expect(find.text('إلغاء الطلب'), findsOneWidget);

    await tester.tap(find.text('إلغاء الطلب'));
    await tester.pumpAndSettle();
    expect(api.cancelled, [5]);
  });

  testWidgets('the hospital ticks what it does, prices it, and saves with the standard button', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const HospitalProceduresManageScreen(), api));
    await tester.pumpAndSettle();

    expect(find.text('تم الحفظ'), findsOneWidget, reason: 'nothing to save yet');

    // tick the second surgery and give it a price; untick the first
    final boxes = find.byType(Checkbox);
    await tester.tap(boxes.at(1));
    await tester.tap(boxes.at(0));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '45000');
    await tester.pump();

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(api.saved, {12: 45000.0});
    expect(api.removed, [11]);
  });

  testWidgets('the hospital sees a new request and declines it', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const HospitalProcedureRequestsScreen(), api));
    await tester.pumpAndSettle();

    expect(find.text('ولادة قيصرية'), findsOneWidget);
    expect(find.textContaining('منى علي'), findsOneWidget);
    expect(find.text('قبول وتحديد موعد'), findsOneWidget);

    await tester.tap(find.text('اعتذر'));
    await tester.pumpAndSettle();
    expect(api.declined, [9]);
  });
}
