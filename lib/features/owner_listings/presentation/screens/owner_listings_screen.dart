import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/owner_listings_providers.dart';
import '../../data/owner_listings_api.dart';
import '../widgets/owner_listing_card.dart';
import 'my_owner_listings_screen.dart';
import 'owner_listing_detail_screen.dart';
import 'owner_listing_form_screen.dart';

/// «إعلانات من المالك»: what ordinary people list for sale, rent or swap — a car, a flat, any used thing — with no
/// business behind it. Browse by category and deal, search, open one, or add your own.
class OwnerListingsScreen extends ConsumerStatefulWidget {
  /// Opens on one category (the cars or the property root's entry); null = all.
  final String? initialCategory;

  const OwnerListingsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<OwnerListingsScreen> createState() =>
      _OwnerListingsScreenState();
}

class _OwnerListingsScreenState extends ConsumerState<OwnerListingsScreen> {
  final _search = TextEditingController();
  late String? _category = widget.initialCategory;
  String? _deal;
  String _term = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  OwnerBrowseQuery get _query =>
      OwnerBrowseQuery(category: _category, deal: _deal, query: _term);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories =
        ref.watch(ownerCategoriesProvider).valueOrNull ??
        const <OwnerCategory>[];
    final listings = ref.watch(ownerBrowseProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.olTitle),
        actions: [
          IconButton(
            tooltip: l10n.olMine,
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyOwnerListingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final posted = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) =>
                  OwnerListingFormScreen(initialCategory: _category),
            ),
          );
          if (posted == true) ref.invalidate(ownerBrowseProvider(_query));
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.olAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.olSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _term.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() => _term = '');
                        },
                      ),
              ),
              onSubmitted: (v) => setState(() => _term = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(
                  l10n.olAll,
                  _category == null,
                  () => setState(() => _category = null),
                ),
                for (final c in categories)
                  _chip(
                    c.name,
                    _category == c.key,
                    () => setState(() => _category = c.key),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(
                  l10n.olAll,
                  _deal == null,
                  () => setState(() => _deal = null),
                ),
                for (final d in const ['sale', 'rent', 'swap'])
                  _chip(
                    ownerDealLabel(l10n, d),
                    _deal == d,
                    () => setState(() => _deal = d),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView<List<OwnerListing>>(
              value: listings,
              onRetry: () => ref.invalidate(ownerBrowseProvider(_query)),
              builder: (context, items) {
                if (items.isEmpty) return Center(child: Text(l10n.olEmpty));

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.refresh(ownerBrowseProvider(_query).future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => OwnerListingCard(
                      listing: items[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              OwnerListingDetailScreen(listingId: items[i].id),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}
