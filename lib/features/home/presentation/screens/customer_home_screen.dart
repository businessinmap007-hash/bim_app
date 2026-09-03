import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/create_post_or_job_button.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../posts/presentation/screens/my_posts_screen.dart';

/// The customer's landing screen: their personal feed, the same "Following /
/// My Posts" tabs [BusinessHomeScreen] shows (minus the Jobs tab, which is a
/// business-only posting kind). Category browsing has its own primary
/// destination on the bottom nav (`AllCategoriesScreen`) — it isn't
/// duplicated here, so Home is the feed and Categories is where you go
/// looking for a business, matching the split every other social/marketplace
/// app makes between the two.
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.homeCustomerTitle),
          actions: const [CreatePostOrJobButton(), NotificationBellButton()],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.postsTabFollowing),
              Tab(text: l10n.postsTabMine),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(children: [FollowedFeedTab(), MyPostsTab()]),
      ),
    );
  }
}
