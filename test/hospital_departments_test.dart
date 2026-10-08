import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/hospital/application/hospital_providers.dart';
import 'package:bim_app/features/hospital/data/hospital_api.dart';
import 'package:bim_app/features/hospital/data/models/hospital_department.dart';
import 'package:bim_app/features/hospital/presentation/screens/hospital_doctors_screen.dart';
import 'package:bim_app/features/hospital/presentation/screens/hospital_invitations_screen.dart';
import 'package:bim_app/features/hospital/presentation/widgets/hospital_departments_tab.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «الأطباء تحت الأقسام» — المالك، 2026-10-09.
class _FakeApi implements HospitalApi {
  final added = <({int optionId, int? userId, String? name, String? title})>[];
  final accepted = <int>[];

  @override
  Future<List<HospitalDepartment>> departments(int hospitalId) async => _departments();

  @override
  Future<List<HospitalDepartment>> myDepartments() async => _departments();

  List<HospitalDepartment> _departments() => const [
    HospitalDepartment(optionId: 1, name: 'باطنه', doctors: [
      HospitalDoctorEntry(id: 1, name: 'د. سارة منصور', businessId: 77),
      HospitalDoctorEntry(id: 2, name: 'استشاري أحمد سمير'),
      HospitalDoctorEntry(id: 3, name: 'د. منى', businessId: 78, status: 'pending'),
    ]),
    HospitalDepartment(optionId: 2, name: 'أسنان'),
  ];

  @override
  Future<void> addDoctor({required int optionId, int? userId, String? name, String? title}) async {
    added.add((optionId: optionId, userId: userId, name: name, title: title));
  }

  @override
  Future<HospitalInvitations> invitations() async => const HospitalInvitations(
    pending: [HospitalInvitation(id: 9, hospitalId: 5, hospitalName: 'مستشفى الشفاء', department: 'باطنه', status: 'pending')],
    active: [HospitalInvitation(id: 10, hospitalId: 6, hospitalName: 'مستشفى النور', department: 'أسنان', status: 'active')],
  );

  @override
  Future<HospitalInvitations> accept(int id) async {
    accepted.add(id);
    return const HospitalInvitations();
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
  testWidgets('the department list shows its doctors; only an account has a page to visit', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: NestedScrollViewHost()), _FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('باطنه'), findsOneWidget);
    expect(find.text('أسنان'), findsOneWidget);
    expect(find.text('د. سارة منصور'), findsOneWidget);
    expect(find.text('استشاري أحمد سمير'), findsOneWidget);

    final account = tester.widget<ListTile>(find.widgetWithText(ListTile, 'د. سارة منصور'));
    final text = tester.widget<ListTile>(find.widgetWithText(ListTile, 'استشاري أحمد سمير'));
    expect(account.onTap, isNotNull);
    expect(text.onTap, isNull);
  });

  testWidgets('the hospital adds a doctor with no account under a department, and a pending one is marked', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const HospitalDoctorsScreen(), api));
    await tester.pumpAndSettle();

    expect(find.text('بانتظار موافقة الطبيب'), findsOneWidget);

    await tester.tap(find.text('إضافة طبيب').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('بدون حساب'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'اسم الطبيب'), 'نادية علي');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة طبيب'));
    await tester.pumpAndSettle();

    expect(api.added.single.optionId, 1);
    expect(api.added.single.userId, isNull);
    expect(api.added.single.name, 'نادية علي');
  });

  testWidgets('a doctor accepts a hospital invitation', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(const HospitalInvitationsScreen(), api));
    await tester.pumpAndSettle();

    expect(find.text('مستشفى الشفاء — باطنه'), findsOneWidget);
    expect(find.text('مستشفى النور — أسنان'), findsOneWidget);

    await tester.tap(find.text('قبول'));
    await tester.pumpAndSettle();
    expect(api.accepted, [9]);
  });
}

/// The tab sits inside the business page's NestedScrollView; give it the same host.
class NestedScrollViewHost extends StatelessWidget {
  const NestedScrollViewHost({super.key});

  @override
  Widget build(BuildContext context) => NestedScrollView(
    headerSliverBuilder: (context, _) => [
      SliverOverlapAbsorber(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context), sliver: const SliverToBoxAdapter(child: SizedBox(height: 10))),
    ],
    body: const HospitalDepartmentsTab(hospitalId: 5),
  );
}
