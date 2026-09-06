import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/cart_icon_button.dart';
import '../../../../shared/widgets/chat_icon_button.dart';
import '../../../../shared/widgets/create_post_button.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../../shared/widgets/profile_cover_header.dart';
import '../../../../shared/widgets/sliver_tab_bar_delegate.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../posts/presentation/screens/my_posts_screen.dart';

/// The business owner's landing screen: its own cover/logo, then its posts
/// activity right under it — followed accounts and my posts, so the
/// dashboard isn't just a name and an empty page. The AppBar's "+" creates a
/// post; managing job postings moved to its own drawer-reached screen
/// ([MyJobsScreen]) since it's checked far less often than either of these.
///
/// The cover/logo header used to sit in a fixed [Column] slot above the tab
/// content, permanently shrinking however much of the screen was left for
/// posts. It's a [NestedScrollView] now: the header scrolls away with the
/// rest of the page, the tab bar stays pinned once it reaches the top, and
/// the list underneath gets the full screen once scrolled — the collapsing
/// profile-header pattern every social app uses, not a coincidence.
class BusinessHomeScreen extends ConsumerWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(authControllerProvider);
    final name = state is AuthSignedIn
        ? (state.user.nameEn ?? state.user.name)
        : '';

    final business = state is AuthSignedIn ? state.user : null;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.homeBusinessTitle),
          actions: const [
            CreatePostButton(),
            ChatIconButton(),
            NotificationBellButton(),
            CartIconButton(),
          ],
        ),
        drawer: const AppDrawer(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: ProfileCoverHeader(
                coverImageUrl: business?.coverUrl,
                avatarImageUrl: business?.logoUrl,
                title: name,
              ),
            ),
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
          body: const TabBarView(
            children: [FollowedFeedTab(), MyPostsTab()],
          ),
        ),
      ),
    );
  }
}
