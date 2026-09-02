import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/application/business_page_providers.dart';
import '../../application/offers_providers.dart';
import '../../data/models/offer_follow.dart';

class MyOfferFollowsScreen extends ConsumerStatefulWidget {
  const MyOfferFollowsScreen({super.key});

  @override
  ConsumerState<MyOfferFollowsScreen> createState() => _MyOfferFollowsScreenState();
}

class _MyOfferFollowsScreenState extends ConsumerState<MyOfferFollowsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(myOfferFollowsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _unfollow(OfferFollow follow) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(myOfferFollowsControllerProvider.notifier).unfollow(follow.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.offerUnfollowed)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myOfferFollowsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myOfferFollowsTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(myOfferFollowsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.myOfferFollowsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myOfferFollowsControllerProvider.notifier).load(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final follow = state.items[index];
                  return _FollowTile(follow: follow, onUnfollow: () => _unfollow(follow));
                },
              ),
            ),
    );
  }
}

class _FollowTile extends ConsumerWidget {
  final OfferFollow follow;
  final VoidCallback onUnfollow;
  const _FollowTile({required this.follow, required this.onUnfollow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (follow.followableType != 'business') {
      // Only business follows are created by this app's UI, but the list
      // reads whatever's on the account — render the type/id plainly for
      // any other kind rather than trying to resolve a name for it.
      return Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.notifications_none),
          title: Text('${follow.followableType} #${follow.followableId}'),
          trailing: TextButton(onPressed: onUnfollow, child: Text(l10n.offerUnfollowBusiness)),
        ),
      );
    }

    final profileAsync = ref.watch(businessProfileProvider(follow.followableId));

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: profileAsync.when(
          loading: () => const CircleAvatar(child: Icon(Icons.storefront_outlined)),
          error: (_, _) => const CircleAvatar(child: Icon(Icons.storefront_outlined)),
          data: (p) => CircleAvatar(
            backgroundImage: p.logoUrl != null ? NetworkImage(p.logoUrl!) : null,
            child: p.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
          ),
        ),
        title: profileAsync.when(
          loading: () => const Text(''),
          error: (_, _) => Text('#${follow.followableId}'),
          data: (p) => Text(p.name),
        ),
        trailing: TextButton(onPressed: onUnfollow, child: Text(l10n.offerUnfollowBusiness)),
      ),
    );
  }
}
