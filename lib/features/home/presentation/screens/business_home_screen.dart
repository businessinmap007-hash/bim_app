import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/create_post_or_job_button.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../../shared/widgets/profile_cover_header.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../posts/presentation/screens/my_posts_screen.dart';

/// The business owner's landing screen: its own cover/logo, then its posts
/// activity right under it — followed accounts / my posts / my jobs — so the
/// dashboard isn't just a name and an empty page. `+` in the AppBar creates a
/// post or job directly; there is no separate "My Posts" screen any more.
/// Orders, bookings and the financial statement still land module by module
/// per the roadmap's priority order.
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.homeBusinessTitle),
          actions: const [CreatePostOrJobButton(), NotificationBellButton()],
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            ProfileCoverHeader(
              coverImageUrl: business?.coverUrl,
              avatarImageUrl: business?.logoUrl,
              title: name,
            ),
            TabBar(
              tabs: [
                Tab(text: l10n.postsTabFollowing),
                Tab(text: l10n.postsTabMine),
                Tab(text: l10n.postsTabJobs),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [FollowedFeedTab(), MyPostsTab(), MyJobsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
