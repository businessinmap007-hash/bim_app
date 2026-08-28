import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// A focused smoke test on the account-type picker, independent of the auth
/// bootstrap (which talks to flutter_secure_storage's platform channel — not
/// available under `flutter test` without additional mocking). Exercising
/// that full boot sequence belongs in an integration_test, not here.
void main() {
  testWidgets('Account type screen renders both account choices', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AccountTypeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BIM'), findsOneWidget);
    expect(find.text('عميل'), findsOneWidget);
    expect(find.text('صاحب نشاط تجاري'), findsOneWidget);
  });
}
