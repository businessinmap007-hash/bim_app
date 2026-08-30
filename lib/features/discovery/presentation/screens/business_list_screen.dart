import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/discovery_providers.dart';
import '../widgets/business_card.dart';

class BusinessListScreen extends ConsumerStatefulWidget {
  final int childId;
  final String title;

  const BusinessListScreen({
    super.key,
    required this.childId,
    required this.title,
  });

  @override
  ConsumerState<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends ConsumerState<BusinessListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(businessListControllerProvider(widget.childId).notifier)
          .loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(businessListControllerProvider(widget.childId).notifier)
          .search(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessListControllerProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.businessSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.commonSomethingWentWrong),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => ref
                                .read(
                                  businessListControllerProvider(
                                    widget.childId,
                                  ).notifier,
                                )
                                .load(),
                            child: Text(l10n.commonRetry),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.items.isEmpty) {
                    return Center(child: Text(l10n.businessListEmpty));
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(
                          businessListControllerProvider(
                            widget.childId,
                          ).notifier,
                        )
                        .load(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount:
                          state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final business = state.items[index];
                        return BusinessCard(
                          business: business,
                          // Business detail (menu/booking) is a later module —
                          // for now this list is the end of the discovery flow.
                          onTap: () {},
                        );
                      },
                    ),
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
