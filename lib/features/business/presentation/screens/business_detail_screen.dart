import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/post_share.dart';
import '../../../../shared/widgets/profile_cover_header.dart';
import '../../../../shared/widgets/sliver_tab_bar_delegate.dart';
import '../../../../shared/widgets/view_mode_toggle.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../cart/application/cart_controller.dart';
import '../../../cart/application/shared_cart_providers.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../cart/presentation/widgets/add_to_cart_sheet.dart';
import '../../../cart/presentation/widgets/share_cart_sheet.dart';
import '../../../clinic/presentation/screens/clinic_slots_screen.dart';
import '../../../comments/presentation/screens/comments_screen.dart';
import '../../../general_chat/application/general_chat_providers.dart';
import '../../../general_chat/presentation/screens/chat_thread_screen.dart';
import '../../../ratings/presentation/screens/reviews_screen.dart';
import '../../application/business_page_providers.dart';
import '../../data/models/business_profile.dart';
import '../../data/models/menu_item_summary.dart';
import '../../data/models/menu_section_group.dart';
import '../../data/models/offering_item.dart';
import 'business_info_screen.dart';
import '../widgets/business_rating_row.dart';
import '../widgets/fulfillment_selector_bar.dart';
import '../widgets/menu_item_grid_card.dart';
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
    // A business with something to sell leads with that, not its feed — a
    // greengrocer's menu is why a customer opened this page at all, and
    // Posts is worth a look, not the first thing to look at. A business
    // with no menu keeps Posts first, same as before.
    if (profile.sections.menu) {
      tabs.add(Tab(text: l10n.businessTabMenu));
      tabViews.add(_MenuTab(businessId: profile.id, fulfillment: profile.fulfillment, sharedOrderId: sharedOrderId));
    }
    if (profile.sections.posts) {
      tabs.add(Tab(text: l10n.businessTabPosts));
      tabViews.add(_PostsTab(businessId: profile.id));
    }
    if (profile.sections.services) {
      tabs.add(Tab(text: l10n.businessTabServices));
      tabViews.add(_ServicesTab(businessId: profile.id));
    }

    final header = Padding(
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
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: l10n.businessInfoTitle,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BusinessInfoScreen(businessId: profile.id)),
                ),
              ),
              _MessageButton(businessId: profile.id),
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
        ],
      ),
    );
    final cover = ProfileCoverHeader(
      coverImageUrl: profile.coverUrl,
      avatarImageUrl: profile.logoUrl,
      title: profile.name,
    );

    if (tabs.isEmpty) {
      return ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            cover,
            header,
            Expanded(
              child: Center(
                child: Text(
                  l10n.businessNoContentYet,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // NestedScrollView so the cover/avatar scroll away like any collapsing
    // profile header instead of permanently sitting above the tabs (the
    // same fix BusinessHomeScreen's own dashboard already got) — the tab
    // bar pins once it reaches the top, and whichever tab is open gets the
    // full screen once scrolled.
    return ResponsiveCenter(
      maxWidth: 800,
      child: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: Column(children: [cover, header])),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: SliverTabBarDelegate(TabBar(tabs: tabs)),
              ),
            ),
          ],
          body: TabBarView(children: tabViews),
        ),
      ),
    );
  }
}

/// Api\V2\ChatController::store — opens (or returns) the DM with this
/// business. Hidden on your own page; there is no "message yourself".
class _MessageButton extends ConsumerWidget {
  final int businessId;
  const _MessageButton({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final myId = authState is AuthSignedIn ? authState.user.id : null;
    if (myId == businessId) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.chat_bubble_outline),
      onPressed: () async {
        final l10n = AppLocalizations.of(context)!;
        try {
          final thread = await ref.read(generalChatApiProvider).startWith(businessId);
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatThreadScreen(threadId: thread.id, title: thread.displayTitle()),
              ),
            );
          }
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
          }
        }
      },
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

class _PostsTab extends ConsumerWidget {
  final int businessId;
  const _PostsTab({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessPostsControllerProvider(businessId));

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.commonSomethingWentWrong),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => ref.read(businessPostsControllerProvider(businessId).notifier).load(),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }
    if (state.items.isEmpty) return Center(child: Text(l10n.businessPostsEmpty));

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          ref.read(businessPostsControllerProvider(businessId).notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(businessPostsControllerProvider(businessId).notifier).load(),
        child: Builder(
          builder: (context) => CustomScrollView(
            key: const PageStorageKey('business_posts'),
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
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
                      onShare: () => sharePost(ref, post),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One branch's worth of items within a section — e.g. "ثلاجات" inside
/// "أنواع الأجهزة الكهربائية". `id == null` is the bucket for items with no
/// line option (a restaurant dish) — shown directly, no branch subheader.
class _BranchBucket {
  final int? id;
  final String name;
  final List<MenuItemSummary> items;
  _BranchBucket({required this.id, required this.name, required this.items});

  /// A branch with exactly one item named after itself (the common produce
  /// case — a "Potato" branch holding a single "Potato" item) would repeat
  /// the same name right above its own card; skip the heading then and let
  /// the card's own name carry it, but keep it for a branch that groups
  /// several differently-named items (e.g. several fridge models under one
  /// brand/size branch), where the heading is the only place that grouping
  /// is named at all.
  bool get headingIsRedundant => items.length == 1 && items.first.name.trim() == name.trim();
}

class _SectionData {
  final MenuSectionGroup group;
  final List<_BranchBucket> branches;
  _SectionData({required this.group, required this.branches});
}

List<_SectionData> _prepareSections(List<MenuSectionGroup> sections, bool isEnglish) {
  return sections.map((section) {
    final order = <int?>[];
    final byBranch = <int?, List<MenuItemSummary>>{};
    final names = <int?, String>{};

    for (final item in section.items) {
      final branch = item.lineOption;
      final key = branch?.id;
      if (!byBranch.containsKey(key)) {
        order.add(key);
        byBranch[key] = [];
        names[key] = branch?.displayName(isEnglish) ?? '';
      }
      byBranch[key]!.add(item);
    }

    return _SectionData(
      group: section,
      branches: order
          .map((key) => _BranchBucket(id: key, name: names[key]!, items: byBranch[key]!))
          .toList(),
    );
  }).toList();
}

/// Every item in one SECTION, packed two-per-row regardless of which branch
/// each came from — see the "grid mode drops branch headers" note where
/// this is built.
class _SectionGrid extends StatelessWidget {
  final List<MenuItemSummary> items;
  final ValueChanged<MenuItemSummary> onTap;
  const _SectionGrid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.62,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuItemGridCard(item: item, onTap: () => onTap(item));
      },
    );
  }
}

/// The exact height _MenuNavRows renders below — 44px for the section-chip
/// row, zero when there's only one section to (not) switch between.
double _menuNavHeight(List<_SectionData> sections) => sections.length > 1 ? 44 : 0;

class _MenuTab extends ConsumerStatefulWidget {
  final int businessId;
  final BusinessFulfillment fulfillment;
  final int? sharedOrderId;
  const _MenuTab({required this.businessId, required this.fulfillment, this.sharedOrderId});

  @override
  ConsumerState<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends ConsumerState<_MenuTab> {
  // null = "All" — every section renders, stacked, scrollable. Picking one
  // FILTERS the page down to just it instead of merely scrolling there, so
  // the rest of the catalog doesn't stay sitting below the section a
  // customer actually asked to see.
  int? _activeSectionIndex;

  /// Turns the caller's cart for this business into a shared one (idempotent
  /// — reuses the existing share token if it's already shared) and opens the
  /// one popup for every way to bring someone into it. Lives beside the
  /// fulfillment choice, before the customer has added anything, instead of
  /// only surfacing after they've built up a cart (ShareCartSheet's own doc
  /// comment has the full rationale).
  Future<void> _startShareCart(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final shared = await ref.read(sharedCartApiProvider).share(widget.businessId);
      if (context.mounted) {
        await showShareCartSheet(context, orderId: shared.orderId, shareToken: shared.shareToken);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final menuAsync = ref.watch(businessMenuProvider(widget.businessId));

    return AsyncValueView(
      value: menuAsync,
      onRetry: () => ref.invalidate(businessMenuProvider(widget.businessId)),
      builder: (context, page) {
        if (page.sections.isEmpty) return Center(child: Text(l10n.businessMenuEmpty));

        final sections = _prepareSections(page.sections, Localizations.localeOf(context).languageCode == 'en');
        if (_activeSectionIndex != null && _activeSectionIndex! >= sections.length) _activeSectionIndex = null;
        final visibleSections = _activeSectionIndex != null ? [sections[_activeSectionIndex!]] : sections;
        final displayModeOverride = ref.watch(customerMenuDisplayModeControllerProvider);
        final isGrid = (displayModeOverride ?? page.displayMode) == 'grid';

        return Builder(
          builder: (context) => CustomScrollView(
            key: const PageStorageKey('business_menu'),
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              // The one entry point for delivery/pickup/dine-in, right above
              // the products it applies to (product doc, "منيو ومطاعم"
              // section) — not in the shared page header, since it has
              // nothing to do with the Posts/Services tabs. The list/grid
              // toggle (a customer's own browsing preference — see the
              // merchant's identical "My Menu" screen) and the share
              // shortcut ride along here too, instead of each getting its
              // own row, since sharing is a decision made before ordering.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: FulfillmentSelectorBar(businessId: widget.businessId, fulfillment: widget.fulfillment)),
                      const SizedBox(width: 4),
                      ViewModeToggle(
                        isGrid: isGrid,
                        listLabel: l10n.menuItemsDisplayModeList,
                        gridLabel: l10n.menuItemsDisplayModeGrid,
                        onChanged: (grid) =>
                            ref.read(customerMenuDisplayModeControllerProvider.notifier).setMode(grid ? 'grid' : 'list'),
                      ),
                      if (widget.sharedOrderId == null) ...[
                        IconButton(
                          tooltip: l10n.cartShareCart,
                          icon: const Icon(Icons.group_add_outlined),
                          onPressed: () => _startShareCart(context, ref),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ),
              ),
              // A sticky nav is only worth the chrome once there is more than
              // one heading to filter between — a one-section restaurant
              // menu stays exactly as it was.
              if (_menuNavHeight(sections) > 0)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _MenuNavDelegate(
                    height: _menuNavHeight(sections),
                    child: _MenuNavRows(
                      sections: sections,
                      activeSectionIndex: _activeSectionIndex,
                      onSectionTap: (index) => setState(() => _activeSectionIndex = index),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in visibleSections)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(section.group.name, style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              // Grid mode packs every item in the SECTION into
                              // one flat, two-per-row grid — branch headers
                              // are dropped here (not per LIST mode below):
                              // keeping one branch's items in a grid of their
                              // own left a branch with a single item taking a
                              // whole row to itself, the exact "one product
                              // per row" this mode exists to avoid whenever a
                              // second card could sit right beside it.
                              if (isGrid)
                                _SectionGrid(
                                  items: section.branches.expand((b) => b.items).toList(),
                                  onTap: (item) => showAddToCartSheet(context, item, sharedOrderId: widget.sharedOrderId),
                                )
                              else
                                for (final branch in section.branches) ...[
                                  if (branch.id != null)
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: branch.headingIsRedundant ? 0 : 6),
                                      child: branch.headingIsRedundant
                                          ? const SizedBox.shrink()
                                          : Text(branch.name, style: Theme.of(context).textTheme.titleSmall),
                                    ),
                                  ...branch.items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: MenuItemTile(
                                        item: item,
                                        onTap: () => showAddToCartSheet(context, item, sharedOrderId: widget.sharedOrderId),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single chip row pinned above the menu — an "All" chip plus one per
/// section. Picking one FILTERS the page down to it instead of merely
/// scrolling there — see [_MenuTabState._activeSectionIndex]. No second
/// branch-chip row: the item cards themselves are the branch list once a
/// section is this short a scroll away.
class _MenuNavRows extends StatelessWidget {
  final List<_SectionData> sections;
  final int? activeSectionIndex;
  final ValueChanged<int?> onSectionTap;

  const _MenuNavRows({required this.sections, required this.activeSectionIndex, required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          scrollDirection: Axis.horizontal,
          itemCount: sections.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ChoiceChip(
                label: Text(l10n.menuItemsAllSections),
                selected: activeSectionIndex == null,
                onSelected: (_) => onSectionTap(null),
              );
            }
            final sectionIndex = index - 1;
            return ChoiceChip(
              label: Text(sections[sectionIndex].group.name),
              selected: sectionIndex == activeSectionIndex,
              onSelected: (_) => onSectionTap(sectionIndex),
            );
          },
        ),
      ),
    );
  }
}

class _MenuNavDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _MenuNavDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _MenuNavDelegate oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}

class _ServicesTab extends ConsumerWidget {
  final int businessId;
  const _ServicesTab({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final offeringsAsync = ref.watch(businessOfferingsProvider(businessId));

    Future<void> orderOffering(OfferingItem offering) async {
      // This tab's rows come from `OfferingDiscovery`, which only ever
      // returns two `source`s: 'menu' (a MenuItem) or 'price' (a raw
      // BusinessServicePrice — a booking add-on, or a schedules/training
      // rate). Retail listings never appear here at all — that's a separate
      // discovery path — so 'retail' as a cart kind was always wrong for
      // every row this tab shows.
      //
      // A 'price'-sourced, non-bookable row (schedules/training) has no cart
      // kind of its own yet — those services are requested through their own
      // dedicated screens, not a generic cart — so it's not orderable here.
      if (offering.source != 'menu') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsComingSoon)));
        return;
      }

      try {
        await ref.read(cartControllerProvider.notifier).addItem(kind: 'menu', offeringId: offering.id);
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

        return Builder(
          builder: (context) => CustomScrollView(
            key: const PageStorageKey('business_services'),
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: offerings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final offering = offerings[index];
                    return OfferingCard(
                      offering: offering,
                      onTap: offering.isBookable
                          ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookingScreen(businessId: businessId, offering: offering),
                              ),
                            )
                          : () => orderOffering(offering),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
