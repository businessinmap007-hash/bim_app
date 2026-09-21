import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bim_app/features/business/data/models/business_post.dart';
import 'package:bim_app/features/business/presentation/widgets/post_card.dart';
import 'package:bim_app/features/posts/application/posts_controller.dart';
import 'package:bim_app/features/posts/data/models/post_subject_options.dart';
import 'package:bim_app/features/posts/data/posts_api.dart';
import 'package:bim_app/features/posts/presentation/screens/create_post_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakePostsApi implements PostsApi {
  Map<String, Object?>? sent;

  @override
  Future<void> createPost({
    String? title,
    required String body,
    String? subjectType,
    int? subjectId,
    List<dynamic> images = const [],
  }) async {
    sent = {'title': title, 'body': body, 'subjectType': subjectType, 'subjectId': subjectId};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _options = [
  PostSubjectType(
    type: 'menu_item',
    label: 'Menu',
    groups: [
      PostSubjectGroup(
        label: 'Grills',
        items: [PostSubjectItem(id: 42, name: 'Mixed grill', price: 180)],
      ),
    ],
  ),
];

Widget _app(Widget home, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: const Locale('en'),
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

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a linked post can be published without a title', (tester) async {
    final api = _FakePostsApi();
    await tester.pumpWidget(
      _app(const CreatePostScreen(), [
        postsApiProvider.overrideWithValue(api),
        postSubjectOptionsProvider.overrideWith((ref) async => _options),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), 'Fresh today');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Link to one of your items (optional)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mixed grill'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Mixed grill'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(api.sent, {'title': '', 'body': 'Fresh today', 'subjectType': 'menu_item', 'subjectId': 42});
  });

  testWidgets('an unlinked post still needs a title', (tester) async {
    final api = _FakePostsApi();
    await tester.pumpWidget(
      _app(const CreatePostScreen(), [
        postsApiProvider.overrideWithValue(api),
        postSubjectOptionsProvider.overrideWith((ref) async => _options),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), 'No title');
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(api.sent, isNull);
  });

  testWidgets('no link button when the business has nothing to link', (tester) async {
    await tester.pumpWidget(
      _app(const CreatePostScreen(), [
        postsApiProvider.overrideWithValue(_FakePostsApi()),
        postSubjectOptionsProvider.overrideWith((ref) async => const <PostSubjectType>[]),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.link), findsNothing);
  });

  testWidgets('a linked post shows its item and taps through to the author', (tester) async {
    var opened = 0;
    const post = BusinessPost(
      id: 1,
      title: 'Mixed grill',
      body: 'Fresh today',
      images: [],
      likesCount: 0,
      dislikesCount: 0,
      commentsCount: 0,
      author: PostAuthor(id: 9, name: 'Grill House'),
      subject: PostSubject(type: 'menu_item', id: 42, name: 'Mixed grill'),
    );
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SingleChildScrollView(child: PostCard(post: post, onOpenAuthor: () => opened++)),
        ),
        const [],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ActionChip), findsOneWidget);
    await tester.tap(find.byType(ActionChip));
    expect(opened, 1);
  });
}
