import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/application/auth_controller.dart';
import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/jobs/application/jobs_providers.dart';
import 'package:bim_app/features/jobs/data/models/job_title.dart';
import 'package:bim_app/features/posts/application/posts_controller.dart';
import 'package:bim_app/features/posts/data/posts_api.dart';
import 'package:bim_app/features/posts/presentation/screens/create_job_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakeAuth extends StateNotifier<AuthState> implements AuthController {
  _FakeAuth(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePostsApi implements PostsApi {
  Map<String, Object?>? sent;

  @override
  Future<void> createJob({
    required int categoryId,
    int? categoryChildId,
    int? jobTitleId,
    required String title,
    required String body,
    String? requirements,
    String? salary,
  }) async {
    sent = {'categoryId': categoryId, 'childId': categoryChildId, 'jobTitleId': jobTitleId, 'title': title};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const business = AuthUser(
    id: 1,
    name: 'Biz',
    email: 'b@example.com',
    phone: '0100',
    type: 'business',
    categoryId: 16,
    categoryChildId: 245,
  );

  Future<_FakePostsApi> pump(WidgetTester tester) async {
    final api = _FakePostsApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => _FakeAuth(const AuthSignedIn(business))),
          postsApiProvider.overrideWithValue(api),
          jobTitlesProvider.overrideWith(
            (ref, field) async => field == (16, 245)
                ? const [JobTitle(id: 15, name: 'طباخ'), JobTitle(id: 17, name: 'ويتر')]
                : const <JobTitle>[],
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: CreateJobScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return api;
  }

  testWidgets('picking a title fills the field and posts its id', (tester) async {
    final api = await pump(tester);

    expect(find.text('طباخ'), findsOneWidget);
    expect(find.text('ويتر'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'ويتر'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'ويتر'), findsOneWidget, reason: 'the pick fills the title field');

    await tester.enterText(find.byType(TextField).at(1), 'مطلوب ويتر');
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(api.sent, {'categoryId': 16, 'childId': 245, 'jobTitleId': 17, 'title': 'ويتر'});
  });

  testWidgets('"other" sends no title id, only the typed title', (tester) async {
    final api = await pump(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'طباخ'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, AppLocalizations.of(tester.element(find.byType(Scaffold)))!.jobsTitleOther));
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), 'طباخ مشويات');
    await tester.enterText(find.byType(TextField).at(1), 'وصف');
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(api.sent?['jobTitleId'], isNull);
    expect(api.sent?['title'], 'طباخ مشويات');
  });
}
