import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/location/application/location_providers.dart';
import 'package:bim_app/features/location/data/models/location_models.dart';
import 'package:bim_app/features/schedules/application/schedules_providers.dart';
import 'package:bim_app/features/schedules/data/models/trip_schedule.dart';
import 'package:bim_app/features/schedules/data/schedules_api.dart';
import 'package:bim_app/features/schedules/presentation/screens/trip_search_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeSchedulesApi implements SchedulesApi {
  Map<String, int?>? asked;

  @override
  Future<List<VehicleTypeOption>> vehicleTypes({String? mode}) async => const [VehicleTypeOption(id: 10, name: 'Minibus')];

  @override
  Future<List<TripScheduleResult>> search({
    int? originGovernorateId,
    int? destinationGovernorateId,
    int? originCountryId,
    int? destinationCountryId,
    int? vehicleTypeId,
    DateTime? date,
  }) async {
    asked = {
      'og': originGovernorateId,
      'oc': originCountryId,
      'dc': destinationCountryId,
      'v': vehicleTypeId,
    };
    return [
      TripScheduleResult(
        schedule: TripSchedule.fromJson({
          'id': 1,
          'mode': 'passenger',
          'scope': 'international',
          'schedule_pattern': 'weekly',
          'business': {'name': 'Nile Bus'},
          'origin': {'country': 'Egypt'},
          'destination': {'country': 'Libya'},
          'departure_time': '08:00:00',
          'return_time': '18:30:00',
          'notes': 'Bring your passport',
        }),
        trust: const TripTrust(starsAverage: 0, reviewCount: 0, successRate: 0),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('an international search sends the country pair and vehicle type', (tester) async {
    final api = _FakeSchedulesApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          schedulesApiProvider.overrideWithValue(api),
          countriesProvider.overrideWith(
            (ref) async => const [
              LocationCountry(id: 1, nameAr: 'مصر', nameEn: 'Egypt'),
              LocationCountry(id: 18, nameAr: 'ليبيا', nameEn: 'Libya'),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const TripSearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.tap(find.text('Minibus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('From'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Egypt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('To'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Libya'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(api.asked, {'og': null, 'oc': 1, 'dc': 18, 'v': 10});
    expect(find.text('Nile Bus'), findsOneWidget);
    expect(find.textContaining('Egypt → Libya'), findsOneWidget);
    expect(find.text('08:00 · Return 18:30'), findsOneWidget);
    expect(find.text('Bring your passport'), findsOneWidget);
  });
}
