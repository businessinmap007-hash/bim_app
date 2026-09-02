import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item.dart';
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.menuItemsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => ref.read(menuItemsControllerProvider.notifier).setQuery(q),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
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
                : state.items.isEmpty
                ? Center(child: Text(l10n.menuItemsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(menuItemsControllerProvider.notifier).load(),
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
                    ),
                  ),
          ),
        ],
      ),
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
        subtitle: item.nameEn != null ? Text(item.nameEn!) : null,
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
