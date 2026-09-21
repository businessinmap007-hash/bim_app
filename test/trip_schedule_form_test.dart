import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/location/application/location_providers.dart';
import 'package:bim_app/features/location/data/models/location_models.dart';
import 'package:bim_app/features/schedules/application/schedules_providers.dart';
import 'package:bim_app/features/schedules/data/models/trip_schedule.dart';
import 'package:bim_app/features/schedules/data/schedules_api.dart';
import 'package:bim_app/features/schedules/presentation/screens/my_trip_schedules_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeSchedulesApi implements SchedulesApi {
  final vehicleModes = <String?>[];
  Map<String, dynamic>? created;

  @override
  Future<List<VehicleTypeOption>> vehicleTypes({String? mode}) async {
    vehicleModes.add(mode);
    return mode == 'freight'
        ? const [VehicleTypeOption(id: 20, name: 'Refrigerated truck', mode: 'freight')]
        : const [VehicleTypeOption(id: 10, name: 'Minibus', mode: 'passenger')];
  }

  @override
  Future<TripSchedule> createTripSchedule(Map<String, dynamic> payload) async {
    created = payload;
    return TripSchedule.fromJson({'id': 1, 'mode': payload['mode'], 'schedule_pattern': 'weekly'});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeSchedulesApi api) => ProviderScope(
  overrides: [
    schedulesApiProvider.overrideWithValue(api),
    countriesProvider.overrideWith(
      (ref) async => const [
        LocationCountry(id: 1, nameAr: 'مصر', nameEn: 'Egypt'),
        LocationCountry(id: 2, nameAr: 'ليبيا', nameEn: 'Libya'),
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
    home: const TripScheduleFormScreen(),
  ),
);

void main() {
  testWidgets('the vehicle picker follows the trip mode and is sent with the leg', (tester) async {
    final api = _FakeSchedulesApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('Minibus'), findsOneWidget);
    expect(find.text('Refrigerated truck'), findsNothing);

    await tester.tap(find.text('Freight'));
    await tester.pumpAndSettle();
    expect(api.vehicleModes, containsAllInOrder(['passenger', 'freight']));
    expect(find.text('Refrigerated truck'), findsOneWidget);
    expect(find.text('Minibus'), findsNothing);
  });

  testWidgets('an international leg is published with a country pair', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FakeSchedulesApi();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Minibus'));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.text('From'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Egypt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('To'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Libya'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(TextField, 'Return time'));
    await tester.enterText(find.widgetWithText(TextField, 'Return time'), '18:00');
    await tester.ensureVisible(find.widgetWithText(TextField, 'Notes'));
    await tester.enterText(find.widgetWithText(TextField, 'Notes'), 'No pets');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(api.created, isNotNull);
    expect(api.created!['scope'], 'international');
    expect(api.created!['origin_country_id'], 1);
    expect(api.created!['destination_country_id'], 2);
    expect(api.created!['vehicle_type_id'], 10);
    expect(api.created!['return_time'], '18:00');
    expect(api.created!['notes'], 'No pets');
    expect(api.created!.containsKey('origin_governorate_id'), isFalse);
  });

  test('an international leg shows its countries as the route', () {
    final s = TripSchedule.fromJson({
      'id': 1,
      'mode': 'freight',
      'scope': 'international',
      'schedule_pattern': 'weekly',
      'origin': {'country': 'مصر', 'governorate': null},
      'destination': {'country': 'ليبيا', 'governorate': null},
    });
    expect(s.isInternational, isTrue);
    expect(s.routeLabel, 'مصر → ليبيا');
  });
}
