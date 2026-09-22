import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/network/paginated.dart';
import 'package:bim_app/features/clinic/application/clinic_providers.dart';
import 'package:bim_app/features/clinic/data/clinic_api.dart';
import 'package:bim_app/features/clinic/data/models/clinic_appointment.dart';
import 'package:bim_app/features/clinic/presentation/screens/my_clinic_appointments_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeClinicApi implements ClinicApi {
  final List<ClinicAppointment> items;
  _FakeClinicApi(this.items);

  @override
  Future<Paginated<ClinicAppointment>> myAppointments({String? status, int page = 1}) async {
    return Paginated(items: items, currentPage: 1, lastPage: 1, total: items.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeClinicApi api) => ProviderScope(
  overrides: [clinicApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const MyClinicAppointmentsScreen(),
  ),
);

void main() {
  test('the prescription id parses off the appointment', () {
    final withRx = ClinicAppointment.fromJson({
      'id': 1,
      'status': 'completed',
      'duration_minutes': 20,
      'prescription_id': 9,
    });
    expect(withRx.prescriptionId, 9);
    expect(ClinicAppointment.fromJson({'id': 2, 'status': 'confirmed', 'duration_minutes': 20}).prescriptionId, isNull);
  });

  testWidgets('a completed visit with a prescription offers to view it; one without does not', (tester) async {
    final api = _FakeClinicApi([
      const ClinicAppointment(id: 1, status: 'completed', durationMinutes: 20, clinicName: 'Dr. Ali', prescriptionId: 9),
      const ClinicAppointment(id: 2, status: 'confirmed', durationMinutes: 20, clinicName: 'Dr. Sara'),
    ]);
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('View prescription'), findsOneWidget);
    // The still-confirmed visit has a cancel button, not a prescription link.
    expect(find.text('Cancel appointment'), findsOneWidget);
  });
}
