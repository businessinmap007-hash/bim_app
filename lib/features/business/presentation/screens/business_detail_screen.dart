import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/profile_cover_header.dart';
import '../../application/business_page_providers.dart';
import '../../data/models/business_profile.dart';
import '../widgets/business_rating_row.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/offering_card.dart';
import '../widgets/post_card.dart';

/// The public business page a search result opens into: profile header +
/// rating/open-now, then whichever of posts/menu/services this business
/// actually has (BusinessPageController decides — a business with no menu
/// gets no menu tab, not an empty one). The first full real screen in the
/// app, built to discover which shared widgets (rating row, post card,
/// priced-item card) later screens actually need, rather than guessing a
/// widget library ahead of any screen that uses it.
class BusinessDetailScreen extends ConsumerWidget {
  final int businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider(businessId));

    return Scaffold(
      appBar: AppBar(title: Text(profileAsync.valueOrNull?.name ?? '')),
      body: AsyncValueView(
        value: profileAsync,
        onRetry: () => ref.invalidate(businessProfileProvider(businessId)),
        builder: (context, profile) => _BusinessDetailBody(profile: profile),
      ),
    );
  }
}

class _BusinessDetailBody extends StatelessWidget {
  final BusinessProfile profile;

  const _BusinessDetailBody({required this.profile});

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
      tabViews.add(_MenuTab(businessId: profile.id));
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
                  BusinessRatingRow(rating: profile.rating, openNow: profile.openNow),
                  if (profile.about != null) ...[
                    const SizedBox(height: 10),
                    Text(profile.about!, style: Theme.of(context).textTheme.bodyMedium),
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
          return PostCard(post: state.items[index]);
        },
      ),
    );
  }
}

class _MenuTab extends ConsumerWidget {
  final int businessId;
  const _MenuTab({required this.businessId});

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
                      child: MenuItemTile(item: item),
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

    return AsyncValueView(
      value: offeringsAsync,
      onRetry: () => ref.invalidate(businessOfferingsProvider(businessId)),
      builder: (context, offerings) {
        if (offerings.isEmpty) return Center(child: Text(l10n.businessServicesEmpty));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: offerings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => OfferingCard(offering: offerings[index]),
        );
      },
    );
  }
}
