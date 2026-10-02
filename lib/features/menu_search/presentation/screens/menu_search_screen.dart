import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/menu_search_providers.dart';
import '../../data/models/menu_search.dart';
import '../open_search_item.dart';
import '../widgets/search_filter_sheet.dart';
import '../widgets/search_result_card.dart';
import 'menu_compare_screen.dart';

/// «ألاقي لاب توب بمواصفات محددة وأعرف المحلات اللي عندها المنتج ده وأقارن
/// الأسعار» — المالك، 2026-10-02. Pick a kind (cars, computers…), narrow it by
/// that kind's own fields, see every shop's unit with its price; «قارن
/// الأسعار» on a known product lists every shop that has the same one,
/// cheapest first. The kinds and their filters come from the admin's «أشكال
/// المنيو», never from the app.
class MenuSearchScreen extends ConsumerStatefulWidget {
  const MenuSearchScreen({super.key});

  @override
  ConsumerState<MenuSearchScreen> createState() => _MenuSearchScreenState();
}

class _MenuSearchScreenState extends ConsumerState<MenuSearchScreen> {
  final _scroll = ScrollController();
  final _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
        ref.read(menuSearchControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _openItem(SearchItem item) => openSearchItem(context, ref, item);

  void _compare(SearchItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MenuCompareScreen(productId: item.catalogProductId!, title: item.name)),
    );
  }

  Future<void> _openFilters(SearchKind kind, MenuSearchState state) async {
    final picked = await showSearchFilterSheet(
      context,
      fields: kind.fields,
      facets: state.facets,
      current: state.filters,
    );
    if (picked != null) ref.read(menuSearchControllerProvider.notifier).setFilters(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kindsAsync = ref.watch(searchKindsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuSearchTitle)),
      body: AsyncValueView<List<SearchKind>>(
        value: kindsAsync,
        onRetry: () => ref.invalidate(searchKindsProvider),
        builder: (context, kinds) {
          if (kinds.isEmpty) return Center(child: Text(l10n.menuSearchNoKinds));
          return _Body(
            kinds: kinds,
            scroll: _scroll,
            queryController: _queryController,
            onOpenItem: _openItem,
            onCompare: _compare,
            onOpenFilters: _openFilters,
          );
        },
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  final List<SearchKind> kinds;
  final ScrollController scroll;
  final TextEditingController queryController;
  final void Function(SearchItem) onOpenItem;
  final void Function(SearchItem) onCompare;
  final Future<void> Function(SearchKind, MenuSearchState) onOpenFilters;
  const _Body({
    required this.kinds,
    required this.scroll,
    required this.queryController,
    required this.onOpenItem,
    required this.onCompare,
    required this.onOpenFilters,
  });

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  @override
  void initState() {
    super.initState();
    // The first kind opens on its own — a search with no kind would be every
    // menu item of every shop, restaurants included.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(menuSearchControllerProvider.notifier);
      if (ref.read(menuSearchControllerProvider).kind == null) controller.setKind(widget.kinds.first.code);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(menuSearchControllerProvider);
    final controller = ref.read(menuSearchControllerProvider.notifier);
    final kind = widget.kinds.where((k) => k.code == state.kind).firstOrNull;

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            children: [
              for (final k in widget.kinds)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(k.name),
                    selected: k.code == state.kind,
                    onSelected: (_) => controller.setKind(k.code),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.queryController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.menuSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                  ),
                  onSubmitted: controller.setQuery,
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: !state.filters.isEmpty,
                label: Text('${state.filters.count}'),
                child: IconButton.filledTonal(
                  tooltip: l10n.menuSearchFilters,
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: kind == null || kind.fields.isEmpty ? null : () => widget.onOpenFilters(kind, state),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort_rounded),
                initialValue: state.sort,
                onSelected: controller.setSort,
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'price_asc', child: Text(l10n.menuSearchSortPriceAsc)),
                  PopupMenuItem(value: 'price_desc', child: Text(l10n.menuSearchSortPriceDesc)),
                  PopupMenuItem(value: 'newest', child: Text(l10n.menuSearchSortNewest)),
                ],
              ),
            ],
          ),
        ),
        if (!state.isLoading && !state.failed)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                l10n.menuSearchResults(state.total),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ),
          ),
        Expanded(
          child: state.isLoading && state.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.failed
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.commonSomethingWentWrong),
                      TextButton(onPressed: controller.load, child: Text(l10n.commonRetry)),
                    ],
                  ),
                )
              : state.items.isEmpty
              ? Center(child: Text(l10n.menuSearchEmpty))
              : ListView.separated(
                  controller: widget.scroll,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    if (i >= state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final item = state.items[i];
                    return SearchResultCard(
                      item: item,
                      onOpen: () => widget.onOpenItem(item),
                      onCompare: item.catalogProductId == null ? null : () => widget.onCompare(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
