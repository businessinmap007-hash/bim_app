import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/menu_search_providers.dart';
import '../../data/models/menu_search.dart';

/// Every shop that sells one exact product, cheapest first — «أعرف المحلات
/// اللي عندها المنتج ده وأقارن الأسعار بينهم».
class MenuCompareScreen extends ConsumerWidget {
  final int productId;
  final String title;
  const MenuCompareScreen({super.key, required this.productId, required this.title});

  static String _money(double v) => NumberFormat.decimalPattern('en').format(v.round());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuCompareTitle)),
      body: AsyncValueView<SearchPage>(
        value: ref.watch(productComparisonProvider(productId)),
        onRetry: () => ref.invalidate(productComparisonProvider(productId)),
        builder: (context, page) {
          final items = [...page.items]..sort((a, b) => a.price.compareTo(b.price));
          final cheapest = items.isEmpty ? 0.0 : items.first.price;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                l10n.menuCompareShops(page.total),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: items[i].shop.id)),
                      ),
                      leading: CircleAvatar(
                        backgroundImage: items[i].shop.logo != null ? CachedNetworkImageProvider(items[i].shop.logo!) : null,
                        child: items[i].shop.logo == null ? const Icon(Icons.storefront_outlined) : null,
                      ),
                      title: Text(items[i].shop.name),
                      subtitle: items[i].summary != null || items[i].specs.isNotEmpty
                          ? Text(
                              items[i].summary ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_money(items[i].price)} ${l10n.pharmacyCurrencyLabel}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: i == 0 ? AppColors.success : AppColors.accentGold,
                            ),
                          ),
                          if (i == 0)
                            Text(
                              l10n.menuCompareCheapest,
                              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.success),
                            )
                          else if (items[i].price > cheapest)
                            Text(
                              l10n.menuCompareMore(_money(items[i].price - cheapest)),
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
