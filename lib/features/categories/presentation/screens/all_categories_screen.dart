import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../discovery/application/discovery_providers.dart';
import '../../../discovery/presentation/widgets/business_card.dart';
import '../widgets/category_roots_grid.dart';

/// A bottom-nav destination for reaching categories directly regardless of
/// what the Home tab ends up showing later (a dashboard/feed, per the
/// roadmap) — today it's the identical root-category grid Home already has,
/// since Home has nothing else yet. Kept as the SAME [CategoryRootsGrid]
/// Home uses (not a second, differently-styled browser) after the first
/// version here — a separate expandable list — read as "the nice card grid
/// got replaced" rather than as a new, additional screen.
///
/// Cross-category business search lives inline at the top now (it used to
/// be its own bottom-nav tab) — the grid shows while the search field is
/// empty, search results replace it the moment there's a query, so this one
/// screen covers "browse" and "look for something specific" both.
class AllCategoriesScreen extends ConsumerStatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  ConsumerState<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends ConsumerState<AllCategoriesScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchControllerProvider.notifier).search(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(searchControllerProvider);
    final hasQuery = searchState.query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCategories)),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.businessSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchControllerProvider.notifier).search('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: hasQuery ? _SearchResults(state: searchState) : const CategoryRootsGrid(),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final SearchState state;
  const _SearchResults({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(l10n.commonSomethingWentWrong));
    }
    if (state.items.isEmpty) {
      return Center(child: Text(l10n.businessListEmpty));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final business = state.items[index];
        return BusinessCard(
          business: business,
          onTap: () => context.push('/business/${business.id}'),
        );
      },
    );
  }
}
