import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/profile_cover_header.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../cart/application/cart_controller.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../cart/presentation/widgets/add_to_cart_sheet.dart';
import '../../../clinic/presentation/screens/clinic_slots_screen.dart';
import '../../../comments/presentation/screens/comments_screen.dart';
import '../../../ratings/presentation/screens/reviews_screen.dart';
import '../../application/business_page_providers.dart';
import '../../data/models/business_profile.dart';
import '../../data/models/offering_item.dart';
import '../widgets/business_rating_row.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/offering_card.dart';
import '../widgets/post_card.dart';

/// The "الصحة"/Health root's category id — mirrors
/// BusinessCapability::HEALTH_ROOT_SLUG on the backend (resolved there by
/// slug, kept here as the id directly since there's no endpoint that hands
/// the app a category-by-slug lookup).
const kHealthRootCategoryId = 20;

/// The public business page a search result opens into: profile header +
/// rating/open-now, then whichever of posts/menu/services this business
/// actually has (BusinessPageController decides — a business with no menu
/// gets no menu tab, not an empty one). The first full real screen in the
/// app, built to discover which shared widgets (rating row, post card,
/// priced-item card) later screens actually need, rather than guessing a
/// widget library ahead of any screen that uses it.
class BusinessDetailScreen extends ConsumerWidget {
  final int businessId;

  /// Set only when reached from SharedCartScreen's "add items" — routes
  /// every add-to-cart on this visit into that group cart instead of the
  /// caller's own solo cart, and swaps the solo-cart badge for nothing (the
  /// solo cart isn't what's being built right now).
  final int? sharedOrderId;

  const BusinessDetailScreen({super.key, required this.businessId, this.sharedOrderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider(businessId));
    final itemsCount = ref.watch(cartControllerProvider.select((s) => s.itemsCount));

    return Scaffold(
      appBar: AppBar(
        title: Text(profileAsync.valueOrNull?.name ?? ''),
        actions: [
          if (sharedOrderId == null)
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
              icon: Badge(
                label: Text('$itemsCount'),
                isLabelVisible: itemsCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
        ],
      ),
      body: AsyncValueView(
        value: profileAsync,
        onRetry: () => ref.invalidate(businessProfileProvider(businessId)),
        builder: (context, profile) => _BusinessDetailBody(profile: profile, sharedOrderId: sharedOrderId),
      ),
    );
  }
}

class _BusinessDetailBody extends StatelessWidget {
  final BusinessProfile profile;
  final int? sharedOrderId;

  const _BusinessDetailBody({required this.profile, this.sharedOrderId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tabs = <Tab>[];
    final tabViews = <Widget>[];
    if (profile.sections.posts) {
      tabs.add(Tab(text: l10n.businessTabPosts));
      tabViews.add(_PostsTab(businessId: profile.id));
    }
    if (profile.sections.menu) {
      tabs.add(Tab(text: l10n.businessTabMenu));
      tabViews.add(_MenuTab(businessId: profile.id, sharedOrderId: sharedOrderId));
    }
    if (profile.sections.services) {
      tabs.add(Tab(text: l10n.businessTabServices));
      tabViews.add(_ServicesTab(businessId: profile.id));
    }

    return ResponsiveCenter(
      maxWidth: 800,
      child: DefaultTabController(
        length: tabs.length,
        child: Column(
          children: [
            ProfileCoverHeader(
              coverImageUrl: profile.coverUrl,
              avatarImageUrl: profile.logoUrl,
              title: profile.name,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReviewsScreen(
                                userId: profile.id,
                                name: profile.name,
                                summary: profile.rating,
                              ),
                            ),
                          ),
                          child: BusinessRatingRow(rating: profile.rating, openNow: profile.openNow),
                        ),
                      ),
                      _FollowButton(businessId: profile.id, isFollowing: profile.isFollowing),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.businessFollowersCount(profile.followersCount),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                  ),
                  if (profile.about != null) ...[
                    const SizedBox(height: 10),
                    Text(profile.about!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  // Health-root businesses only — the same "is this a
                  // clinic" heuristic BusinessCapability::standsUnderHealth()
                  // uses on the backend (category_id against the Health
                  // root). No per-business "offers clinic appointments" flag
                  // exists to check instead; an empty-slots screen for a
                  // health business that doesn't publish any is a harmless
                  // outcome, unlike showing this on an unrelated business.
                  if (profile.categoryId == kHealthRootCategoryId) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClinicSlotsScreen(clinicId: profile.id, clinicName: profile.name),
                        ),
                      ),
                      icon: const Icon(Icons.local_hospital_outlined),
                      label: Text(l10n.clinicBookAppointment),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (tabs.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    l10n.businessNoContentYet,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              )
            else ...[
              TabBar(tabs: tabs),
              Expanded(child: TabBarView(children: tabViews)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Toggling this is the write side of the personal feed: follow a business
/// here and its posts start showing up on the "متابَعون" tab of My Posts.
class _FollowButton extends ConsumerWidget {
  final int businessId;
  final bool isFollowing;

  const _FollowButton({required this.businessId, required this.isFollowing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> toggle() async {
      try {
        await ref.read(businessProfileProvider(businessId).notifier).toggleFollow();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
        }
      }
    }

    return isFollowing
        ? OutlinedButton(onPressed: toggle, child: Text(l10n.businessUnfollow))
        : FilledButton(onPressed: toggle, child: Text(l10n.businessFollow));
  }
}

class _PostsTab extends ConsumerStatefulWidget {
  final int businessId;
  const _PostsTab({required this.businessId});

  @override
  ConsumerState<_PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends ConsumerState<_PostsTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(businessPostsControllerProvider(widget.businessId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessPostsControllerProvider(widget.businessId));

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.commonSomethingWentWrong),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => ref.read(businessPostsControllerProvider(widget.businessId).notifier).load(),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }
    if (state.items.isEmpty) return Center(child: Text(l10n.businessPostsEmpty));

    return RefreshIndicator(
      onRefresh: () => ref.read(businessPostsControllerProvider(widget.businessId).notifier).load(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = state.items[index];
          return PostCard(
            post: post,
            onOpenComments: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CommentsScreen(postId: post.id)),
            ),
          );
        },
      ),
    );
  }
}

class _MenuTab extends ConsumerWidget {
  final int businessId;
  final int? sharedOrderId;
  const _MenuTab({required this.businessId, this.sharedOrderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final menuAsync = ref.watch(businessMenuProvider(businessId));

    return AsyncValueView(
      value: menuAsync,
      onRetry: () => ref.invalidate(businessMenuProvider(businessId)),
      builder: (context, sections) {
        if (sections.isEmpty) return Center(child: Text(l10n.businessMenuEmpty));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.name, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...section.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MenuItemTile(
                        item: item,
                        onTap: () => showAddToCartSheet(context, item, sharedOrderId: sharedOrderId),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ServicesTab extends ConsumerWidget {
  final int businessId;
  const _ServicesTab({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final offeringsAsync = ref.watch(businessOfferingsProvider(businessId));

    Future<void> orderRetail(OfferingItem offering) async {
      try {
        await ref.read(cartControllerProvider.notifier).addItem(kind: 'retail', offeringId: offering.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartAddedToCart)));
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
        }
      }
    }

    return AsyncValueView(
      value: offeringsAsync,
      onRetry: () => ref.invalidate(businessOfferingsProvider(businessId)),
      builder: (context, offerings) {
        if (offerings.isEmpty) return Center(child: Text(l10n.businessServicesEmpty));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: offerings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final offering = offerings[index];
            return OfferingCard(
              offering: offering,
              onTap: offering.isBookable
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BookingScreen(businessId: businessId, offering: offering)),
                    )
                  : () => orderRetail(offering),
            );
          },
        );
      },
    );
  }
}
