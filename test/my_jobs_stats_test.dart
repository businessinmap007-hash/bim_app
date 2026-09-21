import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/jobs/application/jobs_providers.dart';
import 'package:bim_app/features/jobs/data/jobs_api.dart';
import 'package:bim_app/features/jobs/data/models/job_stats.dart';
import 'package:bim_app/features/posts/application/posts_controller.dart';
import 'package:bim_app/features/posts/data/models/job_post.dart';
import 'package:bim_app/features/posts/data/posts_api.dart';
import 'package:bim_app/features/posts/presentation/screens/my_jobs_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _FakePostsApi implements PostsApi {
  @override
  Future<JobsPage> mineJobs({int page = 1, int perPage = 20}) async =>
      const JobsPage(items: [JobPost(id: 1, title: 'طباخ', applicantsCount: 4)], hasMore: false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeJobsApi implements JobsApi {
  @override
  Future<JobStats> myStats() async =>
      const JobStats(jobsPosted: 7, jobsOpen: 3, applicantsTotal: 21, approvedTotal: 2);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('My Jobs shows the business counters above its list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postsApiProvider.overrideWithValue(_FakePostsApi()),
          jobsApiProvider.overrideWithValue(_FakeJobsApi()),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MyJobsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final (label, value) in [('Jobs posted', '7'), ('Open now', '3'), ('Applicants', '21'), ('Accepted', '2')]) {
      expect(find.text(label), findsOneWidget);
      expect(find.text(value), findsOneWidget);
    }
    expect(find.text('طباخ'), findsOneWidget, reason: 'the list is still there');
  });
}
