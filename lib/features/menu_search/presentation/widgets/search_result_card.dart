import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cropped_network_image.dart';
import '../../data/models/menu_search.dart';

/// One unit on sale at one shop: its photo, name, the kind's one-line summary,
/// the shop and the price — with «قارن الأسعار» when it is a known catalog
/// product, which lists every shop that has the same one.
class SearchResultCard extends StatelessWidget {
  final SearchItem item;
  final VoidCallback onOpen;
  final VoidCallback? onCompare;
  const SearchResultCard({super.key, required this.item, required this.onOpen, this.onCompare});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: item.imageUrl != null
                      ? CroppedNetworkImage(
                          url: item.imageUrl!,
                          crop: item.imageCrop,
                          errorWidget: (_, _, _) => const _Placeholder(),
                        )
                      : const _Placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                    if (item.summary != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.storefront_outlined, size: 14, color: theme.hintColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${NumberFormat.decimalPattern('en').format(item.price.round())} ${l10n.pharmacyCurrencyLabel}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentGold,
                          ),
                        ),
                        const Spacer(),
                        if (onCompare != null)
                          TextButton.icon(
                            onPressed: onCompare,
                            icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                            label: Text(l10n.menuSearchCompare),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.photoPlaceholder(context),
      alignment: Alignment.center,
      child: Icon(Icons.devices_other_outlined, color: Theme.of(context).hintColor),
    );
  }
}
