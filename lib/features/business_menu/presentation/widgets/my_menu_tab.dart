import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_button_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/localized_name.dart';
import '../../../../shared/widgets/cropped_network_image.dart';
import '../../../../shared/widgets/equal_height_grid.dart';
import '../../../../shared/widgets/view_mode_toggle.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/menu_item_image.dart';
import '../open_item_editor.dart';
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
    // The same list/grid choice «قائمتي» offers (it is also how customers see the menu).
    final mode = ref.watch(menuDisplayModeControllerProvider).valueOrNull;
    final isGrid = mode == 'grid';

    // The same page the management screen opens: «التسعير والتفاصيل» for a detailed item, the full form otherwise.
    Future<void> openItem(BusinessMenuItem item) => openMenuItemEditor(context, ref, item);

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilledButton.tonalIcon(
                          style: AppButtonStyles.small,
                          onPressed: () => _openManage(context, ref),
                          icon: const Icon(Icons.restaurant_menu_outlined, size: 18),
                          label: Text(l10n.menuManagementTitle),
                        ),
                        if (mode != null)
                          ViewModeToggle(
                            isGrid: isGrid,
                            listLabel: l10n.menuItemsDisplayModeList,
                            gridLabel: l10n.menuItemsDisplayModeGrid,
                            onChanged: (grid) =>
                                ref.read(menuDisplayModeControllerProvider.notifier).setMode(grid ? 'grid' : 'list'),
                          ),
                      ],
                    ),
                  ),
                ),
                if (state.items.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(l10n.menuItemsEmpty)))
                else if (isGrid)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          EqualHeightGrid(
                            columns: 2,
                            children: [for (final item in state.items) _MyMenuGridTile(item: item, onTap: () => openItem(item))],
                          ),
                          if (state.isLoadingMore)
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  )
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
                        final item = state.items[index];
                        return _MyMenuItemTile(item: item, onTap: () => openItem(item));
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
    final image = item.coverImage?.url ?? item.catalogProduct?.image;
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

/// [_MyMenuItemTile]'s counterpart for the grid view: the photo on top, then name and price.
class _MyMenuGridTile extends StatelessWidget {
  final BusinessMenuItem item;
  final VoidCallback onTap;
  const _MyMenuGridTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final image = item.coverImage?.url ?? item.catalogProduct?.image;
    final price = item.basePrice.toStringAsFixed(item.basePrice == item.basePrice.roundToDouble() ? 0 : 2);

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
                aspectRatio: 1.25,
                child: image != null
                    ? CroppedNetworkImage(url: image, crop: item.coverImage?.crop ?? PhotoCrop.whole, fit: item.images.isNotEmpty ? BoxFit.cover : BoxFit.contain)
                    : Container(
                        alignment: Alignment.center,
                        color: AppColors.photoPlaceholder(context),
                        child: const Icon(Icons.inventory_2_outlined, size: 36),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedName(item.nameAr, item.nameEn, isEnglish),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (item.availableQuantity != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.menuItemsQuantityShort(item.availableQuantity!),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      item.saleUnitLabel != null && item.saleUnitLabel!.isNotEmpty ? '$price / ${item.saleUnitLabel}' : price,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
