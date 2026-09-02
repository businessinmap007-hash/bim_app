import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/posts_controller.dart';
import '../../data/models/followed_account.dart';

/// GET/DELETE /follows — the accounts feeding MyPostsScreen's "Following"
/// tab, reached from that tab's app bar so the follow list can be reviewed
/// and pruned without going back to each business's own page.
class MyFollowsScreen extends ConsumerWidget {
  const MyFollowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myFollowsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myFollowsTitle)),
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
                    onPressed: () => ref.read(myFollowsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.myFollowsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myFollowsControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final account = state.items[index];
                  return _FollowedAccountTile(
                    account: account,
                    onUnfollow: () async {
                      try {
                        await ref.read(myFollowsControllerProvider.notifier).unfollow(account.id);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
                        }
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _FollowedAccountTile extends StatelessWidget {
  final FollowedAccount account;
  final VoidCallback onUnfollow;
  const _FollowedAccountTile({required this.account, required this.onUnfollow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final avatarUrl = account.logoUrl ?? account.imageUrl;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: account.id))),
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.storefront_outlined) : null,
        ),
        title: Text(account.name),
        trailing: TextButton(onPressed: onUnfollow, child: Text(l10n.businessUnfollow)),
      ),
    );
  }
}
