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
import 'menu_type_selection_screen.dart';

/// An item's own name is the best key for its emoji — "بطاطس" IS a potato
/// regardless of which vocabulary group it happens to sell under — falling
/// back to its line option's name for the (usual) case where the item was
/// created directly from that vocabulary branch and never got its own
/// English name typed in.
String _itemEmoji(BusinessMenuItem item) => produceEmoji(item.nameEn ?? item.lineOption?.nameEn);

class MenuItemsScreen extends ConsumerStatefulWidget {
  const MenuItemsScreen({super.key});

  @override
  ConsumerState<MenuItemsScreen> createState() => _MenuItemsScreenState();
}

class _MenuItemsScreenState extends ConsumerState<MenuItemsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  // Anchors for the sticky group/branch nav — rebuilt each time the
  // vocabulary's shape changes, reused across scroll-driven rebuilds so a
  // key already handed to a mounted widget doesn't change identity under it.
  final Map<int, GlobalKey> _groupKeys = {};
  final Map<int, GlobalKey> _branchKeys = {};
  int _activeGroupIndex = 0;

  GlobalKey _groupKey(int groupId) => _groupKeys.putIfAbsent(groupId, () => GlobalKey());
  GlobalKey _branchKey(int branchId) => _branchKeys.putIfAbsent(branchId, () => GlobalKey());

  void _jumpTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

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

  /// "أنواع الأجهزة الكهربائية" as a SECTION: tapping its heading opens the
  /// full checklist of every type in that section (not just the narrow set
  /// already ticked), so a merchant isn't stuck with whatever a handful of
  /// ticks looked like when the account was seeded.
  Future<void> _openTypeSelection(int groupId, String groupTitle) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MenuTypeSelectionScreen(groupId: groupId, groupTitle: groupTitle)),
    );
    if (changed == true) {
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

  /// A [_ItemTile] column, or — once the merchant picked "Grid" for
  /// customer display — the SAME items as [_ItemGridTile] cards, so this
  /// screen actually shows what that toggle does instead of only ever
  /// looking like a plain list regardless of which mode is selected.
  Widget _itemsFor(List<BusinessMenuItem> items, String displayMode) {
    if (displayMode == 'grid') {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.62,
        children: [
          for (final item in items)
            _ItemGridTile(
              item: item,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MenuItemEditScreen(itemId: item.id)),
                );
                ref.read(menuItemsControllerProvider.notifier).load();
              },
            ),
        ],
      );
    }

    return Column(
      children: [
        for (final item in items)
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
    );
  }

  Widget _buildList(BuildContext context, MenuItemsState state) {
    final vocabulary = _vocabularyForGrouping(state);
    final displayMode = ref.watch(menuDisplayModeControllerProvider).maybeWhen(data: (m) => m, orElse: () => 'list');
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

    final groups = vocabulary.lines.where((g) => g.options.isNotEmpty).toList();
    // "+ Add brand" only makes sense when this business actually HAS a
    // brand vocabulary (an appliance business: "ثلاجات" — توشيبا، فريش...).
    // A greengrocer's "فراولة" has no brand at all, and a business whose
    // branches themselves ARE the brand (no separate brand group exists)
    // needs no extra brand step either — both get the generic "Add item"
    // instead of a label promising a step that isn't there.
    final hasBrand = vocabulary.brandGroup != null;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      // A `ListView`'s `children:` list still builds through the Sliver
      // protocol — passing every child up front does NOT mount them all;
      // anything past the default ~250px cache extent stays unmounted with
      // a null `GlobalKey.currentContext` until scrolled near. That silently
      // broke jumping to a group far down a long catalog (e.g. "الفواكه"
      // sitting after "الخضروات"'s 45 branches): the chip's own state
      // updated, but `Scrollable.ensureVisible` had no context to jump to
      // and `_jumpTo`'s null-guard quietly did nothing. A generous fixed
      // extent keeps a business's whole catalog mounted — this screen is a
      // merchant's own low-traffic management view, not an infinite feed.
      cacheExtent: 10000,
      children: [
        for (final group in groups) ...[
          Row(
            key: _groupKey(group.groupId),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(group.groupName, style: Theme.of(context).textTheme.titleSmall),
              TextButton.icon(
                onPressed: () => _openTypeSelection(group.groupId, group.groupName),
                icon: const Icon(Icons.tune, size: 16),
                label: Text(AppLocalizations.of(context)!.menuItemsManageTypesAction),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final branch in group.options) ...[
            Padding(
              key: _branchKey(branch.id),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(branch.nameAr, style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: () => _openCreateForBranch(branch.id),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(hasBrand ? AppLocalizations.of(context)!.menuItemsAddBrandRow : AppLocalizations.of(context)!.menuItemAdd),
                  ),
                ],
              ),
            ),
            _itemsFor(itemsByBranch[branch.id] ?? const <BusinessMenuItem>[], displayMode),
            const SizedBox(height: 8),
          ],
        ],
        if (unbranched.isNotEmpty) ...[
          Text(AppLocalizations.of(context)!.menuItemsUnbranchedSection, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _itemsFor(unbranched, displayMode),
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
    // Once this business has a vocabulary, its "sections" ARE the
    // vocabulary's own line groups — shown right below by _GroupBranchNav,
    // always in sync with what's ticked. The hand-picked `menu_sections`
    // filter row below is for a business with NO vocabulary at all (a
    // hand-typed restaurant menu); showing BOTH for a vocabulary business
    // was two different, sometimes-disagreeing answers to "what are my
    // sections" (the real menu_sections table lags until an item is
    // actually priced under a group, per MenuSectionFromOptionGroup) —
    // and filtering into it silently dropped grid mode, since that path
    // never learned about displayMode at all.
    final hasLines = ref.watch(menuVocabularyProvider).maybeWhen(data: (v) => v.hasLines, orElse: () => false);

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
          if (!hasLines)
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
          _GroupBranchNav(
            vocabulary: _vocabularyForGrouping(state),
            activeGroupIndex: _activeGroupIndex,
            onGroupTap: (index, groupId) {
              setState(() => _activeGroupIndex = index);
              _jumpTo(_groupKey(groupId));
            },
            onBranchTap: (branchId) => _jumpTo(_branchKey(branchId)),
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

/// Two chip rows — vocabulary groups, then the tapped group's branches —
/// that jump the list to the tapped heading instead of filtering it away.
/// A long catalog (several groups, dozens of branches) is otherwise a
/// straight scroll with no way to skip ahead; the manual "All sections"
/// filter chips above this stay untouched for hand-typed sections, which
/// this grouping doesn't apply to in the first place.
class _GroupBranchNav extends StatelessWidget {
  final MenuVocabulary? vocabulary;
  final int activeGroupIndex;
  final void Function(int index, int groupId) onGroupTap;
  final ValueChanged<int> onBranchTap;

  const _GroupBranchNav({
    required this.vocabulary,
    required this.activeGroupIndex,
    required this.onGroupTap,
    required this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    final groups = vocabulary?.lines.where((g) => g.options.isNotEmpty).toList() ?? const [];
    if (groups.isEmpty) return const SizedBox.shrink();

    final activeIndex = activeGroupIndex < groups.length ? activeGroupIndex : 0;
    final active = groups[activeIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (groups.length > 1)
          SizedBox(
            height: 40,
            child: MouseWheelHorizontalScroll(
              builder: (context, controller) => ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: groups.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    label: Text(groups[index].groupName),
                    selected: index == activeIndex,
                    onSelected: (_) => onGroupTap(index, groups[index].groupId),
                  );
                },
              ),
            ),
          ),
        if (groups.length > 1) const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: active.options.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final branch = active.options[index];
                return ActionChip(
                  label: Text(branch.nameAr),
                  onPressed: () => onBranchTap(branch.id),
                );
              },
            ),
          ),
        ),
      ],
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
          child: item.images.isEmpty ? Text(_itemEmoji(item), style: const TextStyle(fontSize: 18)) : null,
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

/// [_ItemTile]'s counterpart for the "Grid" customer-display mode — a photo
/// card, two per row, same tap-to-edit and delete actions. Merchants kept
/// seeing a plain list here no matter which mode they picked, since this
/// screen never actually rendered the mode it was letting them choose.
class _ItemGridTile extends ConsumerWidget {
  final BusinessMenuItem item;
  final VoidCallback onTap;
  const _ItemGridTile({required this.item, required this.onTap});

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Opacity(
      opacity: item.isActive ? 1 : 0.5,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: item.images.isNotEmpty
                    ? Image.network(item.images.first.url, fit: BoxFit.cover)
                    : Container(
                        alignment: Alignment.center,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        child: Text(_itemEmoji(item), style: const TextStyle(fontSize: 36)),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nameAr, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                    if (item.availableQuantity != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.menuItemsQuantityShort(item.availableQuantity!),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.basePrice.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        InkWell(
                          onTap: () => _delete(context, ref),
                          child: Icon(Icons.delete_outline, size: 18, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
