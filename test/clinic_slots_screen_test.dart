import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/clinic/application/clinic_providers.dart';
import 'package:bim_app/features/clinic/data/clinic_api.dart';
import 'package:bim_app/features/clinic/data/models/clinic_appointment.dart';
import 'package:bim_app/features/clinic/data/models/clinic_slot.dart';
import 'package:bim_app/features/clinic/presentation/screens/clinic_slots_screen.dart';
import 'package:bim_app/features/specialty_services/application/specialty_services_providers.dart';
import 'package:bim_app/features/specialty_services/data/models/specialty_service.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeApi implements ClinicApi {
  final booked = <int>[];
  final attendees = <String?>[];
  final services = <List<int>>[];

  @override
  Future<ClinicAppointment> bookSlot(
    int slotId, {
    String? reason,
    List<int> specialtyServiceIds = const [],
    String? forName,
    String? forPhone,
  }) async {
    booked.add(slotId);
    attendees.add(forName);
    services.add(specialtyServiceIds);
    throw StateError('stop after recording');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a patient picks a day, then a time, and the bar sums the visit up before booking', (tester) async {
    final api = _FakeApi();
    ClinicSlot slot(int id, int day, int hour, {String? kind, double? price}) =>
        ClinicSlot(id: id, startsAt: DateTime(2026, 10, day, hour), durationMinutes: 30, visitKind: kind, price: price);
    final slots = [
      slot(1, 14, 17, kind: 'كشف', price: 300),
      slot(2, 14, 18, kind: 'كشف', price: 300),
      slot(3, 15, 17, kind: 'استشارة', price: 200),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clinicApiProvider.overrideWithValue(api),
          clinicSlotsBoardProvider(7).overrideWith((ref) async => ClinicSlotsResult(slots: slots)),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const ClinicSlotsScreen(clinicId: 7, clinicName: 'عيادة د. سارة'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اختر يومًا ووقتًا للحجز'), findsOneWidget);
    // nothing to book until a time is chosen
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    // the visit kinds on offer come first; «كشف» is chosen, so only its day (the 14th) and its two times remain
    expect(find.text('نوع الزيارة'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('الوقت'), findsOneWidget);

    final times = find.descendant(of: find.byType(GridView), matching: find.byType(InkWell));
    expect(times, findsNWidgets(2));
    await tester.tap(times.last); // 18:00 of the 14th
    await tester.pumpAndSettle();
    expect(find.textContaining('300'), findsWidgets);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);

    // choosing the other kind swaps the days and the times, and clears the choice
    await tester.tap(find.text('استشارة'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)), findsNWidgets(1));
    expect(find.text('اختر يومًا ووقتًا للحجز'), findsOneWidget);
    await tester.tap(find.text('كشف'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)).last);
    await tester.pumpAndSettle();

    // «لشخص آخر»: the name is required before the booking can go
    await tester.scrollUntilVisible(find.text('لشخص آخر'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('لشخص آخر'));
    await tester.pumpAndSettle();
    final book = find.widgetWithText(FilledButton, 'اطلب الحجز');
    await tester.ensureVisible(book);
    expect(tester.widget<FilledButton>(book).onPressed, isNull);
    await tester.scrollUntilVisible(find.widgetWithText(TextField, 'اسم المريض'), 200, scrollable: find.byType(Scrollable).first);
    await tester.enterText(find.widgetWithText(TextField, 'اسم المريض'), 'الحاج محمود');
    await tester.pump();
    expect(tester.widget<FilledButton>(book).onPressed, isNotNull);

    await tester.tap(book);
    await tester.pumpAndSettle();
    expect(api.booked, [2]);
    expect(api.attendees, ['الحاج محمود']);
  });

  testWidgets('a dental clinic patient names the service he came for, and it goes with the booking', (tester) async {
    final api = _FakeApi();
    final slots = [ClinicSlot(id: 1, startsAt: DateTime(2026, 10, 14, 17), durationMinutes: 30, visitKind: 'كشف', price: 300)];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clinicApiProvider.overrideWithValue(api),
          clinicSlotsBoardProvider(7).overrideWith((ref) async => ClinicSlotsResult(slots: slots)),
          specialtyServicesProvider(7).overrideWith(
            (ref) async => const [
              ServiceOfferingSection(kind: 'preventive', services: [ServiceOffering(id: 11, name: 'تنظيف الأسنان وإزالة الجير', price: 400)]),
              ServiceOfferingSection(kind: 'surgical', services: [ServiceOffering(id: 12, name: 'زراعة سن')]),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const ClinicSlotsScreen(clinicId: 7, clinicName: 'عيادة أسنان', hasServices: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الخدمات المطلوبة (اختياري)'), findsOneWidget);
    expect(find.text('تنظيف الأسنان وإزالة الجير · 400 ج'), findsOneWidget);
    expect(find.text('زراعة سن'), findsOneWidget);

    await tester.tap(find.text('تنظيف الأسنان وإزالة الجير · 400 ج'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('الوقت'), 200, scrollable: find.byType(Scrollable).first);
    final time = find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)).first;
    await tester.ensureVisible(time);
    await tester.pumpAndSettle();
    await tester.tap(time);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'اطلب الحجز'));
    await tester.pumpAndSettle();
    expect(api.services, [[11]]);
  });

  testWidgets('tapping the chosen service again clears it, and a clinic with no list shows no picker', (tester) async {
    final api = _FakeApi();
    final slots = [ClinicSlot(id: 1, startsAt: DateTime(2026, 10, 14, 17), durationMinutes: 30, visitKind: 'كشف', price: 300)];

    Widget app({required bool dental}) => ProviderScope(
      overrides: [
        clinicApiProvider.overrideWithValue(api),
        clinicSlotsBoardProvider(7).overrideWith((ref) async => ClinicSlotsResult(slots: slots)),
        specialtyServicesProvider(7).overrideWith(
          (ref) async => const [
            ServiceOfferingSection(kind: 'surgical', services: [ServiceOffering(id: 12, name: 'زراعة سن')]),
          ],
        ),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        home: ClinicSlotsScreen(clinicId: 7, clinicName: 'عيادة', hasServices: dental),
      ),
    );

    await tester.pumpWidget(app(dental: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('زراعة سن'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('زراعة سن'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('الوقت'), 200, scrollable: find.byType(Scrollable).first);
    final time = find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)).first;
    await tester.ensureVisible(time);
    await tester.pumpAndSettle();
    await tester.tap(time);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'اطلب الحجز'));
    await tester.pumpAndSettle();
    expect(api.services, [<int>[]], reason: 'cleared again, so nothing is sent');

    await tester.pumpWidget(app(dental: false));
    await tester.pumpAndSettle();
    expect(find.text('الخدمات المطلوبة (اختياري)'), findsNothing);
  });

  test('a slot price that arrives as a decimal string does not break the board', () {
    final slot = ClinicSlot.fromJson({'id': 1, 'starts_at': '2026-10-14T11:00:00+03:00', 'duration_minutes': 30, 'visit_kind': 'كشف', 'price': '400.00'});
    expect(slot.price, 400.0);

    expect(ClinicSlot.fromJson({'id': 2, 'duration_minutes': 30, 'price': 250}).price, 250.0);
    expect(ClinicSlot.fromJson({'id': 3, 'duration_minutes': 30}).price, isNull);
  });

  testWidgets('as the booking tab of the page the board holds the visit kind, the service under it, the day and the bar', (tester) async {
    final api = _FakeApi();
    final slots = [ClinicSlot(id: 1, startsAt: DateTime(2026, 10, 14, 17), durationMinutes: 30, visitKind: 'كشف', price: 300)];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clinicApiProvider.overrideWithValue(api),
          clinicSlotsBoardProvider(7).overrideWith((ref) async => ClinicSlotsResult(slots: slots)),
          specialtyServicesProvider(7).overrideWith(
            (ref) async => const [
              ServiceOfferingSection(kind: 'injectables', services: [ServiceOffering(id: 21, name: 'فيلر الشفاه', price: 3500)]),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ),
                ],
                body: const TabBarView(
                  children: [
                    ClinicBookingBoard(clinicId: 7, hasServices: true, embedded: true),
                    Center(child: Text('عن النشاط')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('نوع الزيارة'), findsOneWidget);
    expect(find.text('الخدمات المطلوبة (اختياري)'), findsOneWidget);
    expect(find.text('فيلر الشفاه · 3500 ج'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'اطلب الحجز'), findsOneWidget);
  });

  testWidgets('several services may be picked for one visit, and the bar names them all', (tester) async {
    final api = _FakeApi();
    final slots = [ClinicSlot(id: 1, startsAt: DateTime(2026, 10, 14, 17), durationMinutes: 30, visitKind: 'كشف', price: 300)];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clinicApiProvider.overrideWithValue(api),
          clinicSlotsBoardProvider(7).overrideWith((ref) async => ClinicSlotsResult(slots: slots)),
          specialtyServicesProvider(7).overrideWith(
            (ref) async => const [
              ServiceOfferingSection(kind: 'preventive', services: [ServiceOffering(id: 11, name: 'تنظيف الأسنان وإزالة الجير', price: 400)]),
              ServiceOfferingSection(kind: 'injectables', services: [ServiceOffering(id: 21, name: 'فيلر الشفاه', price: 3500)]),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const ClinicSlotsScreen(clinicId: 7, clinicName: 'عيادة', hasServices: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('تنظيف الأسنان وإزالة الجير · 400 ج'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('فيلر الشفاه · 3500 ج'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('الوقت'), 200, scrollable: find.byType(Scrollable).first);
    final time = find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)).first;
    await tester.ensureVisible(time);
    await tester.pumpAndSettle();
    await tester.tap(time);
    await tester.pumpAndSettle();

    expect(find.textContaining('تنظيف الأسنان وإزالة الجير، فيلر الشفاه'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'اطلب الحجز'));
    await tester.pumpAndSettle();
    expect(api.services, [[11, 21]]);
  });

  testWidgets('the day strip is the two weeks the doctor sits: closed days and full days show greyed, with the reason', (tester) async {
    final api = _FakeApi();
    final slots = [
      ClinicSlot(id: 1, startsAt: DateTime(2026, 10, 14, 17), durationMinutes: 30, visitKind: 'كشف', price: 300),
      ClinicSlot(id: 2, startsAt: DateTime(2026, 10, 17, 17), durationMinutes: 30, visitKind: 'كشف', price: 300),
    ];
    final days = [
      ClinicDay(date: DateTime(2026, 10, 14), slots: 1),
      ClinicDay(date: DateTime(2026, 10, 15), open: false), // Friday: shut by the weekly hours
      ClinicDay(date: DateTime(2026, 10, 16), slots: 0), // sits, but nothing left
      ClinicDay(date: DateTime(2026, 10, 17), slots: 1),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clinicApiProvider.overrideWithValue(api),
          clinicSlotsBoardProvider(7).overrideWith((ref) async => ClinicSlotsResult(slots: slots, days: days)),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const ClinicSlotsScreen(clinicId: 7, clinicName: 'عيادة د. سارة'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // all four days are on the strip — not only the two that have times
    expect(find.text('14'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);
    expect(find.text('مغلق'), findsOneWidget);
    expect(find.text('لا مواعيد'), findsOneWidget);

    // a day without times cannot be picked; the 17th can, and shows its own time
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)), findsNWidgets(1));

    await tester.tap(find.text('17'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)), findsNWidgets(1));
  });
}
