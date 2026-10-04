import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_button_styles.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/localized_name.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item.dart';
import '../screens/menu_item_edit_screen.dart';
import '../screens/menu_items_screen.dart';

/// «المنيو مختفية من صفحتي — لا أستطيع رؤية منتجاتي مع أنني أضفت منتجًا» — المالك، 2026-10-05. The owner's own
/// landing page had only «المتابَعون / منشوراتي»: the products were reachable only from إعدادات الخدمات. This
/// is the third tab, next to the posts: what the shop sells, newest as the merchant ordered it, a tap opens
/// the item to edit, and «قائمتي» opens the full management screen (sections, prices, adding).
class MyMenuTab extends ConsumerWidget {
  const MyMenuTab({super.key});

  Future<void> _openManage(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MenuItemsScreen()));
    ref.read(menuItemsControllerProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(menuItemsControllerProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.commonSomethingWentWrong),
            const SizedBox(height: 8),
            TextButton(onPressed: () => ref.read(menuItemsControllerProvider.notifier).load(), child: Text(l10n.commonRetry)),
          ],
        ),
      );
    }

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          ref.read(menuItemsControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(menuItemsControllerProvider.notifier).load(),
        child: ResponsiveCenter(
          maxWidth: 800,
          child: Builder(
            builder: (context) => CustomScrollView(
              key: const PageStorageKey('my_menu'),
              slivers: [
                SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton.tonalIcon(
                        style: AppButtonStyles.small,
                        onPressed: () => _openManage(context, ref),
                        icon: const Icon(Icons.restaurant_menu_outlined, size: 18),
                        label: Text(l10n.menuManagementTitle),
                      ),
                    ),
                  ),
                ),
                if (state.items.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(l10n.menuItemsEmpty)))
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.separated(
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _MyMenuItemTile(
                          item: state.items[index],
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MenuItemEditScreen(itemId: state.items[index].id)),
                            );
                            ref.read(menuItemsControllerProvider.notifier).load();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyMenuItemTile extends StatelessWidget {
  final BusinessMenuItem item;
  final VoidCallback onTap;
  const _MyMenuItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final title = localizedName(item.nameAr, item.nameEn, isEnglish);
    final image = item.images.isNotEmpty ? item.images.first.url : item.catalogProduct?.image;
    final hint = Theme.of(context).hintColor;
    final price = item.basePrice.toStringAsFixed(item.basePrice == item.basePrice.roundToDouble() ? 0 : 2);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: image != null ? NetworkImage(image) : null,
          child: image == null ? const Icon(Icons.inventory_2_outlined, size: 20) : null,
        ),
        title: Text(title, style: TextStyle(color: item.isActive ? null : hint)),
        subtitle: item.availableQuantity != null ? Text(l10n.menuItemsQuantityShort(item.availableQuantity!)) : null,
        trailing: Text(
          item.saleUnitLabel != null && item.saleUnitLabel!.isNotEmpty ? '$price / ${item.saleUnitLabel}' : price,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
