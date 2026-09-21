import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/network/api_exception.dart';
import 'package:bim_app/features/auth/application/auth_controller.dart';
import 'package:bim_app/features/auth/data/auth_api.dart';
import 'package:bim_app/features/auth/presentation/screens/change_password_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeAuthApi implements AuthApi {
  Map<String, String>? sent;
  ApiException? failWith;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (failWith != null) throw failWith!;
    sent = {'current': currentPassword, 'password': password, 'confirmation': passwordConfirmation};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<_FakeAuthApi> pump(WidgetTester tester) async {
    final api = _FakeAuthApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWithValue(api)],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ChangePasswordScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return api;
  }

  Future<void> fill(WidgetTester tester, String current, String password, String confirm) async {
    await tester.enterText(find.byType(TextField).at(0), current);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.enterText(find.byType(TextField).at(2), confirm);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('a mismatched confirmation is rejected before any request', (tester) async {
    final api = await pump(tester);
    await fill(tester, 'OldPass1', 'NewPass123', 'Different1');

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(api.sent, isNull);
  });

  testWidgets('a valid form sends all three fields', (tester) async {
    final api = await pump(tester);
    await fill(tester, 'OldPass1', 'NewPass123', 'NewPass123');

    expect(api.sent, {'current': 'OldPass1', 'password': 'NewPass123', 'confirmation': 'NewPass123'});
  });

  testWidgets('the server\'s wrong-current-password message is shown', (tester) async {
    final api = await pump(tester);
    api.failWith = const ApiException(
      message: 'The given data was invalid.',
      statusCode: 422,
      fieldErrors: {
        'current_password': ['Current password is wrong.'],
      },
    );
    await fill(tester, 'nope', 'NewPass123', 'NewPass123');

    expect(find.text('Current password is wrong.'), findsOneWidget);
  });
}
