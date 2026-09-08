import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/menu_vocabulary.dart';
import 'market_catalog_screen.dart';
import 'menu_item_edit_screen.dart';
import 'menu_sections_screen.dart';

class MenuItemsScreen extends ConsumerStatefulWidget {
  const MenuItemsScreen({super.key});

  @override
  ConsumerState<MenuItemsScreen> createState() => _MenuItemsScreenState();
}

class _MenuItemsScreenState extends ConsumerState<MenuItemsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(menuItemsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final createdId = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const MenuItemEditScreen()),
    );
    if (createdId != null) {
      ref.read(menuItemsControllerProvider.notifier).load();
    }
  }

  Future<void> _openCreateForBranch(int branchOptionId) async {
    final createdId = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => MenuItemEditScreen(initialLineOptionId: branchOptionId)),
    );
    if (createdId != null) {
      ref.read(menuItemsControllerProvider.notifier).load();
    }
  }

  /// Grouping-by-branch is only worth it once this business has a real
  /// catalog vocabulary, and only on the unfiltered "all sections" view — a
  /// merchant who filtered to one hand-typed section is asking for a plain
  /// list of exactly that section's items, not a re-grouping of them.
  MenuVocabulary? _vocabularyForGrouping(MenuItemsState state) {
    if (state.sectionId != null) return null;
    return ref.watch(menuVocabularyProvider).maybeWhen(data: (v) => v.hasLines ? v : null, orElse: () => null);
  }

  bool _hasEmptyBranchesToShow(MenuItemsState state) {
    final vocabulary = _vocabularyForGrouping(state);
    return vocabulary != null && vocabulary.lines.any((g) => g.options.isNotEmpty);
  }

  Widget _buildList(BuildContext context, MenuItemsState state) {
    final vocabulary = _vocabularyForGrouping(state);
    if (vocabulary == null) {
      return ListView.separated(
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
          final item = state.items[index];
          return _ItemTile(
            item: item,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MenuItemEditScreen(itemId: item.id)),
              );
              ref.read(menuItemsControllerProvider.notifier).load();
            },
          );
        },
      );
    }

    // Every branch the vocabulary knows about, in order — even one with no
    // items yet, so "+ إضافة علامة تجارية" is always there to start it.
    final itemsByBranch = <int, List<BusinessMenuItem>>{};
    for (final item in state.items) {
      final id = item.lineOption?.id;
      if (id != null) (itemsByBranch[id] ??= []).add(item);
    }
    // Items with no line option at all (a hand-typed extra) still need a home.
    final unbranched = state.items.where((i) => i.lineOption == null).toList();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        for (final group in vocabulary.lines.where((g) => g.options.isNotEmpty)) ...[
          Text(group.groupName, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final branch in group.options) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(branch.nameAr, style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: () => _openCreateForBranch(branch.id),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(AppLocalizations.of(context)!.menuItemsAddBrandRow),
                  ),
                ],
              ),
            ),
            for (final item in itemsByBranch[branch.id] ?? const <BusinessMenuItem>[])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ItemTile(
                  item: item,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MenuItemEditScreen(itemId: item.id)),
                    );
                    ref.read(menuItemsControllerProvider.notifier).load();
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ],
        if (unbranched.isNotEmpty) ...[
          Text(AppLocalizations.of(context)!.menuItemsUnbranchedSection, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final item in unbranched)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ItemTile(
                item: item,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MenuItemEditScreen(itemId: item.id)),
                  );
                  ref.read(menuItemsControllerProvider.notifier).load();
                },
              ),
            ),
        ],
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(menuItemsControllerProvider);
    final sectionsState = ref.watch(menuSectionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuItemsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rtl_outlined),
            tooltip: l10n.marketCatalogTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MarketCatalogScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.menuSectionsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MenuSectionsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.menuItemAdd),
      ),
      body: Column(
        children: [
          const _DisplayModeToggle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.menuItemsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => ref.read(menuItemsControllerProvider.notifier).setQuery(_searchController.text),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => ref.read(menuItemsControllerProvider.notifier).setQuery(q),
            ),
          ),
          SizedBox(
            height: 44,
            child: MouseWheelHorizontalScroll(
              builder: (context, controller) => ListView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l10n.menuItemsAllSections),
                      selected: state.sectionId == null,
                      onSelected: (_) => ref.read(menuItemsControllerProvider.notifier).filterBySection(null),
                    ),
                  ),
                  for (final section in sectionsState.items)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(section.nameAr),
                        selected: state.sectionId == section.id,
                        onSelected: (_) => ref.read(menuItemsControllerProvider.notifier).filterBySection(section.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                          onPressed: () => ref.read(menuItemsControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty && !_hasEmptyBranchesToShow(state)
                ? Center(child: Text(l10n.menuItemsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(menuItemsControllerProvider.notifier).load(),
                    child: _buildList(context, state),
                  ),
          ),
        ],
      ),
    );
  }
}

/// "طريقة العرض للعميل: قائمة/شبكة" — only worth showing once this business
/// has a catalog vocabulary; a hand-typed restaurant menu has no grid mode
/// to offer.
class _DisplayModeToggle extends ConsumerWidget {
  const _DisplayModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLines = ref.watch(menuVocabularyProvider).maybeWhen(data: (v) => v.hasLines, orElse: () => false);
    if (!hasLines) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final modeAsync = ref.watch(menuDisplayModeControllerProvider);

    return modeAsync.maybeWhen(
      data: (mode) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            Text(l10n.menuItemsDisplayModeLabel, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'list', label: Text(l10n.menuItemsDisplayModeList), icon: const Icon(Icons.view_list_outlined)),
                ButtonSegment(value: 'grid', label: Text(l10n.menuItemsDisplayModeGrid), icon: const Icon(Icons.grid_view_outlined)),
              ],
              selected: {mode},
              onSelectionChanged: (selection) => ref.read(menuDisplayModeControllerProvider.notifier).setMode(selection.first),
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  final BusinessMenuItem item;
  final VoidCallback onTap;
  const _ItemTile({required this.item, required this.onTap});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuItemDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuItemsControllerProvider.notifier).delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: item.images.isNotEmpty ? NetworkImage(item.images.first.url) : null,
          child: item.images.isEmpty ? const Icon(Icons.fastfood_outlined) : null,
        ),
        title: Text(item.nameAr, style: TextStyle(color: item.isActive ? null : Theme.of(context).hintColor)),
        subtitle: item.availableQuantity != null
            ? Text(AppLocalizations.of(context)!.menuItemsQuantityShort(item.availableQuantity!))
            : (item.nameEn != null ? Text(item.nameEn!) : null),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.basePrice.toStringAsFixed(2)),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
