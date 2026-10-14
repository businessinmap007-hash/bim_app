import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/hospital/data/models/hospital_procedure.dart';
import 'package:bim_app/features/hospital/presentation/widgets/procedure_widgets.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Map<String, dynamic> _json({String status = 'advised', Map<String, dynamic>? physician}) => {
  'id': 7,
  'status': status,
  'kind': 'ophthalmology',
  'name': 'عملية مياه بيضاء',
  'price': 8000,
  'source': 'physician',
  'physician': physician,
  'hospital': {'id': 1, 'name': 'مستشفى الشفاء'},
};

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: child),
);

void main() {
  group('a physician’s procedure decision', () {
    test('is parsed as advised, with who decided it, and can be declined', () {
      final r = ProcedureRequestItem.fromJson(_json(physician: {'id': 5, 'name': 'محمد فهيم', 'title': 'استشاري جراحة عيون'}));

      expect(r.isAdvised, isTrue);
      expect(r.physicianLine, 'محمد فهيم — استشاري جراحة عيون');
      expect(r.canCancel, isTrue);
    });

    test('a request the patient made himself has no physician', () {
      final r = ProcedureRequestItem.fromJson(_json(status: 'requested'));

      expect(r.isAdvised, isFalse);
      expect(r.physicianLine, isNull);
    });

    testWidgets('the card says it is the physician’s decision awaiting the patient', (tester) async {
      final r = ProcedureRequestItem.fromJson(_json(physician: {'id': 5, 'name': 'محمد فهيم', 'title': 'استشاري جراحة عيون'}));

      await tester.pumpWidget(_host(ProcedureRequestCard(request: r)));

      expect(find.text('قرار الطبيب بانتظار ردّك'), findsOneWidget);
      expect(find.text('قرار الطبيب: محمد فهيم — استشاري جراحة عيون'), findsOneWidget);
    });
  });
}
