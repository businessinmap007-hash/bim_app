import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/clinic_management/application/business_clinic_providers.dart';
import 'package:bim_app/features/clinic_management/data/business_clinic_api.dart';
import 'package:bim_app/features/clinic_management/data/models/business_clinic_appointment.dart';
import 'package:bim_app/features/clinic_management/presentation/screens/clinic_management_screen.dart';
import 'package:bim_app/features/investigations/application/investigations_providers.dart';
import 'package:bim_app/features/patient_records/presentation/screens/patient_file_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _NoApi implements BusinessClinicApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Queue extends ClinicAppointmentsController {
  _Queue(List<BusinessClinicAppointment> items) : super(_NoApi()) {
    state = ClinicAppointmentsState(items: items);
  }

  @override
  Future<void> load() async {}
}

BusinessClinicAppointment _appt(int id, String status) => BusinessClinicAppointment(
  id: id,
  status: status,
  scheduledAt: DateTime(2026, 10, 14, 17),
  durationMinutes: 30,
  patientId: 40 + id,
  patientName: 'منى السيد',
  patientPhone: '01000000000',
);

void main() {
  testWidgets('«بدء الكشف» is offered on a confirmed visit only and opens the patient file', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clinicAppointmentsControllerProvider.overrideWith((ref) => _Queue([_appt(1, 'confirmed'), _appt(2, 'requested')])),
          issuedInvestigationOrdersProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ClinicManagementScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // two visits on the screen, but only the confirmed one can be started
    expect(find.text('بدء الكشف'), findsOneWidget);

    await tester.tap(find.text('بدء الكشف'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientFileScreen), findsOneWidget);
  });
}
