import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/albums/application/albums_controller.dart';
import 'package:bim_app/features/albums/data/models/album.dart';
import 'package:bim_app/features/business/data/models/business_profile.dart';
import 'package:bim_app/features/business/presentation/screens/business_info_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _host(BusinessProfile profile) => ProviderScope(
  overrides: [businessAlbumsProvider(profile.id).overrideWith((ref) async => <Album>[])],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: BusinessInfoBody(profile: profile)),
  ),
);

BusinessProfile _profile({Map<String, dynamic>? hours, bool openNow = true}) => BusinessProfile.fromJson({
  'id': 7,
  'name': 'صالون النجمة',
  'phone': '0100',
  'open_now': openNow,
  'working_hours': hours,
});

Map<String, dynamic> _day(int day, {bool? closed, String? open, String? close}) => {
  'day': day,
  'is_closed': closed,
  'open': open,
  'close': close,
};

void main() {
  testWidgets('the About tab shows the week the business wrote, closed days and unknown days apart', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = _profile(
      hours: {
        'timezone': 'Africa/Cairo',
        'days': [
          _day(0, closed: false, open: '10:00', close: '22:00'),
          _day(1, closed: false, open: '10:00', close: '22:00'),
          _day(2, closed: null),
          _day(3, closed: false, open: '12:00', close: '20:00'),
          _day(4, closed: false, open: '10:00', close: '22:00'),
          _day(5, closed: true),
          _day(6, closed: false, open: '09:00', close: '23:00'),
        ],
      },
    );

    await tester.pumpWidget(_host(profile));
    await tester.pumpAndSettle();

    expect(find.text('ساعات العمل'), findsOneWidget);
    expect(find.text('مفتوح الآن'), findsOneWidget);
    // a written day shows its window, in reading order
    expect(find.text('12:00 – 20:00'), findsOneWidget);
    expect(find.text('09:00 – 23:00'), findsOneWidget);
    // a closed day says so; a day never written is a dash, not «مغلق»
    expect(find.text('مغلق'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    // Saturday leads the week and Friday ends it
    final saturday = tester.getTopLeft(find.text('السبت')).dy;
    final friday = tester.getTopLeft(find.text('الجمعة')).dy;
    expect(saturday < friday, isTrue);
  });

  testWidgets('a business that wrote no hours has no hours card', (tester) async {
    await tester.pumpWidget(_host(_profile()));
    await tester.pumpAndSettle();

    expect(find.text('ساعات العمل'), findsNothing);
  });

  testWidgets('a closed business is labelled closed now', (tester) async {
    await tester.pumpWidget(
      _host(_profile(hours: {'timezone': 'Africa/Cairo', 'days': [_day(0, closed: true)]}, openNow: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('مغلق الآن'), findsOneWidget);
  });
}
