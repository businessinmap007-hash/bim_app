import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/application/auth_controller.dart';
import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/medical_file/data/medical_backup_crypto.dart';
import 'package:bim_app/features/medical_file/data/medical_file.dart';
import 'package:bim_app/features/medical_file/presentation/screens/prescription_shown_screen.dart';
import 'package:bim_app/features/prescriptions/application/pharmacy_prescriptions_providers.dart';
import 'package:bim_app/features/prescriptions/data/models/prescription.dart';
import 'package:bim_app/features/prescriptions/data/pharmacy_prescriptions_api.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «الروشتات على الهاتف» — what the pharmacist sees of a shown prescription, and that the phone's archive
/// travels in the encrypted backup.
class _FakePharmacyApi implements PharmacyPrescriptionsApi {
  PrescriptionCheck check;
  final dispensed = <int>[];
  _FakePharmacyApi(this.check);

  @override
  Future<PrescriptionCheck> verify(int id, Map<String, dynamic> content) async => check;

  @override
  Future<void> dispenseInPerson(int id, Map<String, dynamic> content) async {
    dispensed.add(id);
    check = const PrescriptionCheck(authentic: true, status: 'dispensed', canDispense: false, doctorName: 'Dr. Salma');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakePharmacyApi api, {required bool business}) {
  final user = AuthUser(
    id: 5,
    name: 'Pharmacy',
    nameEn: null,
    email: 'p@x.test',
    phone: '0100',
    type: business ? 'business' : 'client',
  );
  return ProviderScope(
    overrides: [
      pharmacyPrescriptionsApiProvider.overrideWithValue(api),
      authControllerProvider.overrideWith((ref) => _FakeAuth(ref, AuthSignedIn(user))),
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
      home: const PrescriptionShownScreen(
        sharedBy: 'Ali',
        payload: {
          'kind': 'prescription',
          'id': 7,
          'content': {
            'id': '7',
            'diagnosis': 'Flu',
            'items': [
              {'name': 'Paracetamol', 'dosage': '500mg', 'quantity': '2 boxes'},
            ],
          },
        },
      ),
    ),
  );
}

class _FakeAuth extends StateNotifier<AuthState> implements AuthController {
  _FakeAuth(Ref ref, super.initial);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a pharmacy sees a verified, undispensed prescription and can record the hand-over once', (tester) async {
    final api = _FakePharmacyApi(const PrescriptionCheck(authentic: true, status: 'issued', canDispense: true, doctorName: 'Dr. Salma'));
    await tester.pumpWidget(_app(api, business: true));
    await tester.pumpAndSettle();

    expect(find.text('Paracetamol'), findsOneWidget);
    expect(find.text('Verified — exactly what the doctor wrote'), findsOneWidget);
    expect(find.text('Not dispensed yet — it can be dispensed.'), findsOneWidget);

    await tester.tap(find.text('Record this prescription as dispensed'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Record this prescription as dispensed').last);
    await tester.pumpAndSettle();

    expect(api.dispensed, [7]);
    expect(find.text('Already dispensed — do not dispense it again.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Record this prescription as dispensed'), findsNothing, reason: 'no second hand-over');
  });

  testWidgets('a copy the server does not recognise is flagged and cannot be dispensed', (tester) async {
    final api = _FakePharmacyApi(const PrescriptionCheck(authentic: false));
    await tester.pumpWidget(_app(api, business: true));
    await tester.pumpAndSettle();

    expect(find.text('Not verified — it does not match what the doctor wrote. Do not dispense.'), findsOneWidget);
    expect(find.text('Record this prescription as dispensed'), findsNothing);
  });

  testWidgets('a client account sees the content, unverified, with no dispense button', (tester) async {
    final api = _FakePharmacyApi(const PrescriptionCheck(authentic: true, status: 'issued', canDispense: true));
    await tester.pumpWidget(_app(api, business: false));
    await tester.pumpAndSettle();

    expect(find.text('Paracetamol'), findsOneWidget);
    expect(find.textContaining('pharmacy accounts only'), findsOneWidget);
    expect(find.text('Record this prescription as dispensed'), findsNothing);
  });

  test('the phone archive travels in the encrypted backup, and an older backup still opens', () async {
    const file = MedicalFile(bloodType: 'A+');
    final raw = {
      'id': 7,
      'status': 'issued',
      'patient': {'id': 5, 'name': 'Ali'},
      'items': [
        {'id': 1, 'name': 'Paracetamol'},
      ],
    };

    final blob = await MedicalBackupCrypto.seal(file, 'a long passphrase', prescriptions: [raw]);
    final back = await MedicalBackupCrypto.open(blob, 'a long passphrase');
    expect(back.file.bloodType, 'A+');
    expect(back.prescriptions.single['id'], 7);
    expect(Prescription.fromJson(back.prescriptions.single).items.single.name, 'Paracetamol');
  });

  test('a prescription keeps the JSON the server sent, and its verifiable content', () {
    final p = Prescription.fromJson({
      'id': 9,
      'status': 'issued',
      'patient': {'id': 1, 'name': 'Ali'},
      'items': [],
      'verifiable': {
        'hash': 'abc',
        'content': {'id': '9', 'items': []},
      },
    });

    expect(p.raw['id'], 9);
    expect(p.verifiableContent!['id'], '9');
    expect(Prescription.fromJson({'id': 1, 'status': 'requested', 'patient': {'id': 1}}).verifiableContent, isNull);
  });
}
