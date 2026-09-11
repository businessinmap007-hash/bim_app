import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/business_groups/presentation/screens/business_groups_screen.dart';
import '../../features/contact_groups/presentation/screens/contact_groups_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/offers/presentation/screens/my_offer_follows_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/posts/presentation/screens/my_follows_screen.dart';
import '../../features/posts/presentation/screens/my_jobs_screen.dart';
import '../../features/profile/presentation/screens/my_profile_screen.dart';
import '../../features/settings/presentation/screens/services_settings_screen.dart';
import '../../l10n/app_localizations.dart';
import '../utils/localized_name.dart';

/// The app's account menu — reached via the AppBar's automatic hamburger
/// icon (Scaffold shows it whenever `drawer:` is set). Settings and logout
/// live here, not as loose AppBar icons or bottom-nav tabs: neither is a
/// "primary destination" the way Home is.
///
/// The header IS the entry to the account: cover + avatar (read-only preview
/// — actually editing them happens on [MyProfileScreen] itself, reached by
/// tapping anywhere on the header) with a small edit badge as the visual
/// hint. Below it, two sections: jobs/posts-adjacent follows, and the
/// business's own service-management screens (business accounts only) — a
/// customer's own activity/history ("My Services") moved to its own
/// bottom-nav tab, and posts management is Home's own tabs (see
/// [BusinessHomeScreen]/[CustomerHomeScreen]), so neither belongs in an
/// account-utility menu either.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(child: _AppDrawerContent());
  }
}

class _AppDrawerContent extends ConsumerWidget {
  const _AppDrawerContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthSignedIn ? authState.user : null;
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    void close() => Navigator.of(context).pop();

    void openAccount() {
      close();
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const MyProfileScreen()));
    }

    return SafeArea(
      child: Column(
        children: [
          InkWell(
            onTap: openAccount,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 96,
                  color: AppColors.primaryNavy,
                  child: user?.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: user!.coverUrl!,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 66),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentGold.withValues(
                                alpha: 0.15,
                              ),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              // logo first — the field every other resource
                              // (posts/comments/orders, the public business
                              // page) reads as "this account's photo" for a
                              // business; image is a client's own slot and
                              // the fallback for a business with no logo set.
                              child: (user?.logoUrl ?? user?.imageUrl) != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          (user!.logoUrl ?? user.imageUrl)!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: AppColors.primaryNavy,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (user != null)
                                    Text(
                                      localizedName(user.name, user.nameEn, isEnglish),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (user != null)
                                    Text(
                                      user.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Theme.of(context).hintColor,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryNavy,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SectionHeader(l10n.drawerSectionProfile),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l10n.settingsTitle),
                  onTap: () {
                    close();
                    context.push('/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: Text(l10n.contactGroupsTitle),
                  onTap: () {
                    close();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ContactGroupsScreen()),
                    );
                  },
                ),
                if (isBusiness)
                  ListTile(
                    leading: const Icon(Icons.groups_2_outlined),
                    title: Text(l10n.businessGroupsTitle),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BusinessGroupsScreen()),
                      );
                    },
                  ),

                _SectionHeader(l10n.drawerSectionJobsPosts),
                ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: Text(l10n.jobsTitle),
                  onTap: () {
                    close();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const JobsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: Text(l10n.myFollowsTitle),
                  onTap: () {
                    close();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyFollowsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(l10n.offersTitle),
                  onTap: () {
                    close();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OffersScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: Text(l10n.myOfferFollowsTitle),
                  onTap: () {
                    close();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyOfferFollowsScreen(),
                      ),
                    );
                  },
                ),

                if (isBusiness) ...[
                  _SectionHeader(l10n.settingsServicesSection),
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(l10n.settingsServicesSection),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ServicesSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_history_outlined),
                    title: Text(l10n.postsTabJobs),
                    onTap: () {
                      close();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyJobsScreen()),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.authLogout,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              close();
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
