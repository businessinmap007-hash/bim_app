import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/offers_providers.dart';
import '../../data/models/commercial_offer.dart';
import 'offer_detail_screen.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(offersControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final state = ref.watch(offersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offersTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.offersSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (q) => ref.read(offersControllerProvider.notifier).setQuery(q),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: state.sort,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: 'boosted', child: Text(l10n.offerSortBoosted)),
                    DropdownMenuItem(value: 'latest', child: Text(l10n.offerSortLatest)),
                    DropdownMenuItem(value: 'lowest_price', child: Text(l10n.offerSortLowestPrice)),
                  ],
                  onChanged: (v) {
                    if (v != null) ref.read(offersControllerProvider.notifier).setSort(v);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(offersControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.offersEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(offersControllerProvider.notifier).load(),
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
                        final offer = state.items[index];
                        return _OfferTile(
                          offer: offer,
                          languageCode: languageCode,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => OfferDetailScreen(offerId: offer.id)),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final CommercialOffer offer;
  final String languageCode;
  final VoidCallback onTap;
  const _OfferTile({required this.offer, required this.languageCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final seller = offer.sellingBusiness;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: seller?.logoUrl != null ? NetworkImage(seller!.logoUrl!) : null,
          child: seller?.logoUrl == null ? const Icon(Icons.local_offer_outlined) : null,
        ),
        title: Text(offer.title(languageCode)),
        subtitle: Text(seller?.name ?? ''),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (offer.basePrice != null && offer.basePrice! > offer.finalPrice)
              Text(
                '${offer.basePrice} ${offer.currency}',
                style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12),
              ),
            Text(
              '${offer.finalPrice} ${offer.currency}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
