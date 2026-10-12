import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/clinic/application/clinic_providers.dart';
import 'package:bim_app/features/clinic/data/clinic_api.dart';
import 'package:bim_app/features/clinic/data/models/clinic_appointment.dart';
import 'package:bim_app/features/clinic/data/models/clinic_slot.dart';
import 'package:bim_app/features/clinic/presentation/screens/clinic_slots_screen.dart';
import 'package:bim_app/features/dental/application/dental_providers.dart';
import 'package:bim_app/features/dental/data/models/dental_service.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeApi implements ClinicApi {
  final booked = <int>[];
  final attendees = <String?>[];
  final services = <int?>[];

  @override
  Future<ClinicAppointment> bookSlot(int slotId, {String? reason, int? dentalServiceId, String? forName, String? forPhone}) async {
    booked.add(slotId);
    attendees.add(forName);
    services.add(dentalServiceId);
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
          clinicSlotsProvider(7).overrideWith((ref) async => slots),
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
          clinicSlotsProvider(7).overrideWith((ref) async => slots),
          dentalServicesProvider(7).overrideWith(
            (ref) async => const [
              DentalOfferingSection(kind: 'preventive', services: [DentalOffering(id: 11, name: 'تنظيف الأسنان وإزالة الجير', price: 400)]),
              DentalOfferingSection(kind: 'surgical', services: [DentalOffering(id: 12, name: 'زراعة سن')]),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const ClinicSlotsScreen(clinicId: 7, clinicName: 'عيادة أسنان', hasDentalServices: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الخدمة المطلوبة (اختياري)'), findsOneWidget);
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
    expect(api.services, [11]);
  });

  testWidgets('tapping the chosen service again clears it, and a clinic with no list shows no picker', (tester) async {
    final api = _FakeApi();
    final slots = [ClinicSlot(id: 1, startsAt: DateTime(2026, 10, 14, 17), durationMinutes: 30, visitKind: 'كشف', price: 300)];

    Widget app({required bool dental}) => ProviderScope(
      overrides: [
        clinicApiProvider.overrideWithValue(api),
        clinicSlotsProvider(7).overrideWith((ref) async => slots),
        dentalServicesProvider(7).overrideWith(
          (ref) async => const [
            DentalOfferingSection(kind: 'surgical', services: [DentalOffering(id: 12, name: 'زراعة سن')]),
          ],
        ),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        home: ClinicSlotsScreen(clinicId: 7, clinicName: 'عيادة', hasDentalServices: dental),
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
    expect(api.services, [null], reason: 'cleared again, so nothing is sent');

    await tester.pumpWidget(app(dental: false));
    await tester.pumpAndSettle();
    expect(find.text('الخدمة المطلوبة (اختياري)'), findsNothing);
  });
}
