import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../application/discovery_providers.dart';
import '../widgets/business_card.dart';

/// Cross-category business search — a bottom-nav destination, unlike
/// [BusinessListScreen] which is always entered already scoped to one
/// specialty. Backed by SearchApi (GET /search/offers), the one discovery
/// endpoint that takes a free-text query with no child_id.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchControllerProvider.notifier).search(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSearch)),
      drawer: const AppDrawer(),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.businessSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.query.trim().isEmpty) {
                    return Center(child: Text(l10n.searchEmptyHint));
                  }
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
