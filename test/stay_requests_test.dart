import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/stay_requests/application/stay_requests_providers.dart';
import 'package:bim_app/features/stay_requests/data/models/stay_request.dart';
import 'package:bim_app/features/stay_requests/data/stay_requests_api.dart';
import 'package:bim_app/features/stay_requests/presentation/screens/stay_requests_screen.dart';
import 'package:bim_app/features/stay_requests/presentation/widgets/stay_request_sheet.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «زر ابلاغ عن مشكلة بالغرفة وزر طلب خدمة … وتصل لشاشة البزنس برقم الغرفة والطلب» — المالك، 2026-10-07.
class _FakeApi implements StayRequestsApi {
  final created = <Map<String, String?>>[];
  final moved = <String>[];
  var open = const [
    StayRequest(id: 7, bookingId: 3, kind: 'issue', category: 'ac', title: 'تكييف', label: 'تكييف', note: 'التكييف متوقف', status: 'new', roomNumber: '305', guestName: 'منى'),
    StayRequest(id: 8, bookingId: 4, kind: 'service', title: 'قهوة', label: 'قهوة', status: 'in_progress', roomNumber: '210'),
  ];

  @override
  Future<StayRequestOptions> options(int bookingId) async => const StayRequestOptions(
    canRequest: true,
    issues: [StayChoice(value: 'ac', label: 'تكييف'), StayChoice(value: 'other', label: 'أخرى')],
    services: [StayChoice(value: 'قهوة', label: 'قهوة'), StayChoice(value: 'فطار', label: 'فطار')],
  );

  @override
  Future<StayRequest> create(int bookingId, {required String kind, String? category, String? title, String? note}) async {
    created.add({'kind': kind, 'category': category, 'title': title, 'note': note});

    return StayRequest(id: 99, bookingId: bookingId, kind: kind, title: title ?? 'تكييف', label: title ?? 'تكييف', status: 'new');
  }

  @override
  Future<StayRequestsPayload> forHotel({String status = 'open'}) async =>
      status == 'open' ? StayRequestsPayload(requests: open, openCount: open.length) : const StayRequestsPayload();

  @override
  Future<StayRequest> setStatus(int requestId, String status) async {
    moved.add('$requestId:$status');

    return StayRequest(id: requestId, bookingId: 3, kind: 'issue', title: 'تكييف', label: 'تكييف', status: status);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeApi api, Widget home) => ProviderScope(
  overrides: [stayRequestsApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: home,
  ),
);

void main() {
  test('a request reads its room number, kind and status', () {
    final r = StayRequest.fromJson({
      'id': 1, 'booking_id': 2, 'kind': 'issue', 'category': 'ac', 'title': 'تكييف', 'label': 'AC', 'status': 'new', 'room_number': '305', 'guest_name': 'منى',
    });

    expect(r.isIssue, isTrue);
    expect(r.isOpen, isTrue);
    expect(r.roomNumber, '305');
    expect(r.label, 'AC');
    expect(StayRequest.fromJson({'id': 2, 'kind': 'service', 'title': 'قهوة', 'status': 'done'}).isOpen, isFalse);
  });

  testWidgets('the guest reports a problem: picks the category and sends it', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(api, Scaffold(body: Builder(builder: (context) => TextButton(onPressed: () => showStayRequestSheet(context, bookingId: 3, kind: 'issue'), child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('ما المشكلة في الغرفة؟'), findsOneWidget);
    // nothing is sent until a category is chosen
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.tap(find.text('تكييف'));
    await tester.enterText(find.byType(TextField), 'متوقف');
    await tester.pump();
    await tester.tap(find.text('إرسال للفندق'));
    await tester.pumpAndSettle();

    expect(api.created.single, {'kind': 'issue', 'category': 'ac', 'title': null, 'note': 'متوقف'});
  });

  testWidgets("«other» cannot be sent without describing it", (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(api, Scaffold(body: Builder(builder: (context) => TextButton(onPressed: () => showStayRequestSheet(context, bookingId: 3, kind: 'issue'), child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('أخرى'));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'ريحة غريبة');
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
  });

  testWidgets('the guest orders a service from the hotel list', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(api, Scaffold(body: Builder(builder: (context) => TextButton(onPressed: () => showStayRequestSheet(context, bookingId: 3, kind: 'service'), child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('فطار'));
    await tester.pump();
    await tester.tap(find.text('إرسال للفندق'));
    await tester.pumpAndSettle();

    expect(api.created.single['kind'], 'service');
    expect(api.created.single['title'], 'فطار');
    expect(api.created.single['category'], isNull);
  });

  testWidgets('the hotel reads the room number first and works a request through', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(_app(api, const StayRequestsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('غرفة 305'), findsOneWidget);
    expect(find.text('التكييف متوقف'), findsOneWidget);
    expect(find.text('غرفة 210'), findsOneWidget);

    // a request the hotel has already started offers no "start" button again
    expect(find.text('ابدأ التنفيذ'), findsOneWidget);

    await tester.tap(find.text('ابدأ التنفيذ'));
    await tester.pumpAndSettle();
    expect(api.moved, ['7:in_progress']);
  });
}
