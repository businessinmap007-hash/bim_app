import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/clinic/application/clinic_providers.dart';
import 'package:bim_app/features/clinic/data/clinic_api.dart';
import 'package:bim_app/features/clinic/data/models/clinic_appointment.dart';
import 'package:bim_app/features/clinic/data/models/clinic_slot.dart';
import 'package:bim_app/features/clinic/presentation/screens/clinic_slots_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeApi implements ClinicApi {
  final booked = <int>[];

  @override
  Future<ClinicAppointment> bookSlot(int slotId, {String? reason}) async {
    booked.add(slotId);
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

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(api.booked, [2]);
  });
}
