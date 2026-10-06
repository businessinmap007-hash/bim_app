import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/application/auth_controller.dart';
import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/settings/application/notification_preferences_controller.dart';
import 'package:bim_app/features/settings/data/notification_preferences_api.dart';
import 'package:bim_app/features/settings/presentation/screens/account_settings_screen.dart';
import 'package:bim_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';
import 'package:bim_app/shared/widgets/screen_frame.dart';

/// «إعدادات الحساب / إعدادات التطبيق» — the settings are two doors; the account's hub lists its sections in order,
/// and a business that has not said how it delivers is told, on every road to the page that fixes it.
class _FakeAuth extends StateNotifier<AuthState> implements AuthController {
  _FakeAuth(super.initial);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthUser _user({required String type, bool setupComplete = true}) => AuthUser(
  id: 5,
  name: 'Shop',
  email: 's@x.test',
  phone: '0100',
  type: type,
  setupComplete: setupComplete,
);

Widget _app(
  Widget home,
  AuthUser user, {
  List<Override> overrides = const [],
}) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith((ref) => _FakeAuth(AuthSignedIn(user))),
    ...overrides,
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
    home: home,
  ),
);

class _FakePrefsApi implements NotificationPreferencesApi {
  bool failSave = false;
  List<NotificationCategory> state = const [
    NotificationCategory(key: 'orders', label: 'الطلبات', enabled: true),
    NotificationCategory(key: 'messages', label: 'الرسائل', enabled: true),
  ];

  @override
  Future<List<NotificationCategory>> load() async => state;

  @override
  Future<List<NotificationCategory>> save(Map<String, bool> changes) async {
    if (failSave) throw Exception('offline');
    state = [
      for (final c in state)
        changes.containsKey(c.key) ? c.copyWith(enabled: changes[c.key]) : c,
    ];
    return state;
  }
}

void main() {
  testWidgets(
    'the settings page has two doors, and the account door carries the «required» mark for an incomplete business',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const SettingsScreen(),
          _user(type: 'business', setupComplete: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إعدادات الحساب'), findsOneWidget);
      expect(find.text('إعدادات التطبيق'), findsOneWidget);
      expect(find.text('مطلوب'), findsOneWidget);
    },
  );

  testWidgets('a complete account carries no mark', (tester) async {
    await tester.pumpWidget(
      _app(const SettingsScreen(), _user(type: 'business')),
    );
    await tester.pumpAndSettle();

    expect(find.text('مطلوب'), findsNothing);
  });

  testWidgets(
    'the account hub lists the business sections in order, with the mark on the business settings',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const AccountSettingsScreen(),
          _user(type: 'business', setupComplete: false),
        ),
      );
      await tester.pumpAndSettle();

      final titles = [
        'معلومات الحساب',
        'إعدادات البزنس',
        'إعدادات الخدمات',
        'إعدادات الموظفين',
        'العلامة المائية',
      ];
      final tops = [for (final t in titles) tester.getTopLeft(find.text(t)).dy];
      expect(
        tops,
        orderedEquals([...tops]..sort()),
        reason: 'top to bottom in the order the owner gave',
      );
      expect(find.text('مطلوب'), findsOneWidget);
    },
  );

  testWidgets('a customer sees no business sections', (tester) async {
    await tester.pumpWidget(
      _app(const AccountSettingsScreen(), _user(type: 'client')),
    );
    await tester.pumpAndSettle();

    expect(find.text('معلومات الحساب'), findsOneWidget);
    expect(find.text('إعدادات البزنس'), findsNothing);
    expect(find.text('إعدادات الخدمات'), findsNothing);
    expect(find.text('إعدادات الموظفين'), findsNothing);
  });

  test('the account payload says whether its setup is complete', () {
    final incomplete = AuthUser.fromJson({
      'id': 1,
      'name': 'x',
      'email': 'a@b.c',
      'phone': '1',
      'type': 'business',
      'setup': {
        'complete': false,
        'missing': ['fulfillment'],
      },
    });
    expect(incomplete.setupComplete, isFalse);
    expect(incomplete.setupMissing, ['fulfillment']);

    expect(
      AuthUser.fromJson({
        'id': 2,
        'name': 'c',
        'email': 'a@b.c',
        'phone': '1',
        'type': 'client',
      }).setupComplete,
      isTrue,
      reason: 'a customer, or an older server, has no setup to finish',
    );
  });

  test(
    'a notification switch shows at once, is saved, and is put back when the save fails',
    () async {
      final api = _FakePrefsApi();
      final container = ProviderContainer(
        overrides: [notificationPreferencesApiProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      container.listen(notificationPreferencesControllerProvider, (_, _) {});
      final controller = container.read(
        notificationPreferencesControllerProvider.notifier,
      );
      await Future<void>.delayed(Duration.zero);

      expect(await controller.set('messages', false), isTrue);
      expect(
        container
            .read(notificationPreferencesControllerProvider)
            .value!
            .firstWhere((c) => c.key == 'messages')
            .enabled,
        isFalse,
      );
      expect(
        api.state.firstWhere((c) => c.key == 'messages').enabled,
        isFalse,
        reason: 'saved on the server',
      );
      expect(
        container
            .read(notificationPreferencesControllerProvider)
            .value!
            .firstWhere((c) => c.key == 'orders')
            .enabled,
        isTrue,
      );

      api.failSave = true;
      expect(await controller.set('orders', false), isFalse);
      expect(
        container
            .read(notificationPreferencesControllerProvider)
            .value!
            .firstWhere((c) => c.key == 'orders')
            .enabled,
        isTrue,
        reason: 'back to what the server has',
      );
    },
  );

  testWidgets(
    'a screen is its own page alone and just a body (with its actions on a thin row) inside a tab',
    (tester) async {
      const body = Text('content');
      final action = IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ScreenFrame(
            embedded: false,
            title: 'Wallet',
            actions: [action],
            body: body,
          ),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenFrame(
              embedded: true,
              title: 'Wallet',
              actions: [action],
              body: body,
            ),
          ),
        ),
      );
      expect(
        find.byType(AppBar),
        findsNothing,
        reason: 'the tab page has the bar',
      );
      expect(find.text('Wallet'), findsNothing);
      expect(
        find.byIcon(Icons.refresh),
        findsOneWidget,
        reason: 'the action is still reachable',
      );
      expect(find.text('content'), findsOneWidget);
    },
  );
}
