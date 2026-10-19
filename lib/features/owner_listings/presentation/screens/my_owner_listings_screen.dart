import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/owner_listings_providers.dart';
import '../../data/owner_listings_api.dart';
import '../widgets/owner_listing_card.dart';
import '../widgets/owner_listing_photo.dart';
import 'owner_listing_chat_screen.dart';
import 'owner_listing_detail_screen.dart';
import 'owner_listing_form_screen.dart';

/// «إعلاناتي» and «محادثاتي» of the owner-listings market: what I posted (in any state) and the conversations I am in,
/// as a buyer or as a seller.
class MyOwnerListingsScreen extends ConsumerStatefulWidget {
  /// 0 = my listings, 1 = my conversations.
  final int initialTab;

  const MyOwnerListingsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<MyOwnerListingsScreen> createState() =>
      _MyOwnerListingsScreenState();
}

class _MyOwnerListingsScreenState extends ConsumerState<MyOwnerListingsScreen> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.olTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final posted = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const OwnerListingFormScreen()),
          );
          if (posted == true) ref.invalidate(myOwnerListingsProvider);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.olAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(l10n.olMine)),
                ButtonSegment(value: 1, label: Text(l10n.olMyChats)),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: _tab == 0 ? const _MyListings() : const _MyInquiries(),
          ),
        ],
      ),
    );
  }
}

class _MyListings extends ConsumerWidget {
  const _MyListings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mine = ref.watch(myOwnerListingsProvider);

    return AsyncValueView<List<OwnerListing>>(
      value: mine,
      onRetry: () => ref.invalidate(myOwnerListingsProvider),
      builder: (context, items) {
        if (items.isEmpty) return Center(child: Text(l10n.olMineEmpty));

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(myOwnerListingsProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final l = items[i];
              final status = switch (l.status) {
                'flagged' => l10n.olStatusFlagged,
                'done' => l10n.olStatusDone,
                'expired' => l10n.olStatusExpired,
                _ =>
                  l.imagesCount == 0
                      ? l10n.olNoPhotoHidden
                      : l10n.olStatusActive,
              };

              return OwnerListingCard(
                listing: l,
                footer: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OwnerListingDetailScreen(listingId: l.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MyInquiries extends ConsumerWidget {
  const _MyInquiries();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final inquiries = ref.watch(myOwnerInquiriesProvider);

    return AsyncValueView<List<OwnerInquiry>>(
      value: inquiries,
      onRetry: () => ref.invalidate(myOwnerInquiriesProvider),
      builder: (context, items) {
        if (items.isEmpty) return Center(child: Text(l10n.olChatsEmpty));

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(myOwnerInquiriesProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final q = items[i];
              final theme = Theme.of(context);

              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: OwnerListingPhoto(
                      path: q.listingCover,
                      width: 52,
                      height: 52,
                    ),
                  ),
                  title: Text(
                    q.listingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${q.isBuyer ? l10n.olIAmBuyer : l10n.olIAmSeller} · ${q.otherName}'
                    '${q.revealed ? ' · ${l10n.olNumbersSwapped}' : (q.requestedByOther ? ' · ${l10n.olAsksToSwap}' : '')}',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OwnerListingChatScreen(
                        inquiryId: q.id,
                        title: q.listingTitle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
