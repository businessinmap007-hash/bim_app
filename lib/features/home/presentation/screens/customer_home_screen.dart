import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/cart_icon_button.dart';
import '../../../../shared/widgets/chat_icon_button.dart';
import '../../../../shared/widgets/create_post_button.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../../shared/widgets/sliver_tab_bar_delegate.dart';
import '../../../posts/presentation/screens/my_posts_screen.dart';

/// The customer's landing screen: their personal feed, the same "Following /
/// My Posts" tabs [BusinessHomeScreen] shows (minus the Jobs tab, which is a
/// business-only posting kind). Category browsing has its own primary
/// destination on the bottom nav (`AllCategoriesScreen`) — it isn't
/// duplicated here, so Home is the feed and Categories is where you go
/// looking for a business, matching the split every other social/marketplace
/// app makes between the two.
///
/// A [NestedScrollView] even though there's no header to scroll away here:
/// [FollowedFeedTab]/[MyPostsTab] are shared with [BusinessHomeScreen], which
/// DOES have one, and both rely on the same NestedScrollView-provided
/// overlap handle to size their pinned tab bar correctly.
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeCustomerTitle),
        actions: const [
          CreatePostButton(),
          ChatIconButton(),
          NotificationBellButton(),
          CartIconButton(),
        ],
      ),
      drawer: const AppDrawer(),
      body: const CustomerHomeBody(),
    );
  }
}

/// Just the feed content, with no [Scaffold]/[AppBar]/[AppDrawer] of its
/// own — reused as-is inside [CustomerHomeScreen] (mobile/tablet) and inside
/// the desktop 3-pane shell's center column (`HomeShell`), which supplies
/// its own shared top bar instead.
class CustomerHomeBody extends StatelessWidget {
  const CustomerHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegate(
                TabBar(
                  tabs: [
                    Tab(text: l10n.postsTabFollowing),
                    Tab(text: l10n.postsTabMine),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: const TabBarView(children: [FollowedFeedTab(), MyPostsTab()]),
      ),
    );
  }
}
