import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/handover/handover_code.dart';
import 'package:bim_app/features/schedules/data/models/trip_parcel.dart';
import 'package:bim_app/l10n/app_localizations.dart';

void main() {
  testWidgets('a typed code comes back trimmed from the handover core, the same value a scanned QR would give', (tester) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result = await askHandoverCode(context, title: 'Take it', hint: 'hint'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  2954gh ');
    await tester.tap(find.text('Confirm the typed code'));
    await tester.pumpAndSettle();

    expect(result, '2954gh');
  });

  test('a parcel says who pays and whether the cash was collected, and when it may be disputed', () {
    final p = TripParcel.fromJson({
      'id': 1,
      'status': 'accepted',
      'description': 'box',
      'sender': {'id': 1},
      'receiver': <String, dynamic>{},
      'payer': 'sender',
      'paid_at': '2026-10-15T10:00:00+03:00',
      'handover_code': '1234ab',
      'handover_kind': 'pickup',
      'expected_arrival_at': '2026-10-15T18:00:00+03:00',
    });

    expect(p.payer, 'sender');
    expect(p.isPaid, isTrue);
    expect(p.handoverCode, '1234ab');
    expect(p.handoverKind, 'pickup');
    expect(p.expectedArrivalAt, isNotNull);
    expect(p.canDispute, isTrue);
    expect(TripParcel.fromJson({'id': 2, 'status': 'requested', 'description': 'x', 'sender': {'id': 1}, 'receiver': <String, dynamic>{}}).canDispute, isFalse);
  });
}
