import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/menu_item_summary.dart';
import '../../../media/data/picked_media.dart';
import '../../../media/presentation/widgets/media_source_badge.dart';
import '../../application/cart_controller.dart';
import '../../application/shared_cart_providers.dart';
import 'checkout_screen.dart';

/// «تفاصيل المنتج» — the full-page counterpart of [showAddToCartSheet]'s
/// bottom sheet, for a catalog-linked item (one with a real spec table —
/// see [MenuItemSummary.specs]): hero image, price + condition badge, full
/// spec table, then the exact same variant/extras/qty picker and cart
/// submission the sheet already uses. Matches the Tech Catalog Setup
/// canvas's TechProductDetail board. See [[tech-spec-menu-implementation]].
///
/// The state/pricing/submit logic here intentionally mirrors
/// `_AddToCartSheet`'s own (same variant+extras+qty shape, same
/// `cartControllerProvider`/`sharedCartControllerProvider` calls) rather
/// than sharing a controller — small enough that duplicating it once was
/// safer than refactoring the already-verified sheet to fit a second,
/// differently-laid-out caller.
class TechProductDetailScreen extends ConsumerStatefulWidget {
  final MenuItemSummary item;
  final int? sharedOrderId;
  const TechProductDetailScreen({super.key, required this.item, this.sharedOrderId});

  @override
  ConsumerState<TechProductDetailScreen> createState() => _TechProductDetailScreenState();
}

class _TechProductDetailScreenState extends ConsumerState<TechProductDetailScreen> {
  int? _variantId;
  final Set<int> _extraIds = {};
  int _qty = 1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final variants = widget.item.variants;
    if (variants.isNotEmpty) {
      MenuItemVariant defaultVariant = variants.first;
      for (final v in variants) {
        if (v.isDefault) {
          defaultVariant = v;
          break;
        }
      }
      _variantId = defaultVariant.id;
    }
  }

  double get _unitPrice {
    var base = widget.item.basePrice;
    for (final v in widget.item.variants) {
      if (v.id == _variantId) {
        base = v.price;
        break;
      }
    }
    final extrasSum = widget.item.extras.where((e) => _extraIds.contains(e.id)).fold(0.0, (sum, e) => sum + e.price);
    return base + extrasSum;
  }

  int? _singleGroupValue(int groupId) {
    for (final e in widget.item.extras) {
      if (e.extraGroupId == groupId && _extraIds.contains(e.id)) return e.id;
    }
    return null;
  }

  void _pickSingle(int groupId, int extraId) {
    setState(() {
      for (final e in widget.item.extras) {
        if (e.extraGroupId == groupId) _extraIds.remove(e.id);
      }
      _extraIds.add(extraId);
    });
  }

  Future<void> _confirm({required bool buyNow}) async {
    setState(() => _submitting = true);
    try {
      final sharedOrderId = widget.sharedOrderId;
      if (sharedOrderId != null) {
        await ref.read(sharedCartControllerProvider(sharedOrderId).notifier).addItem(
          kind: widget.item.kind,
          offeringId: widget.item.id,
          qty: _qty,
          sizeId: _variantId,
          extras: _extraIds.toList(),
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartAddedToCart)));
        }
        return;
      }

      final cart = await ref.read(cartControllerProvider.notifier).addItem(
        kind: widget.item.kind,
        offeringId: widget.item.id,
        qty: _qty,
        sizeId: _variantId,
        extras: _extraIds.toList(),
      );
      if (!mounted) return;

      if (buyNow) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(cart: cart)));
      } else {
        final l10n = AppLocalizations.of(context)!;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartAddedToCart)));
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final item = widget.item;
    final imageUrl = item.imageUrl ?? (item.imageUrls.isNotEmpty ? item.imageUrls.first : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuItemDetailTitle)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryNavyLight, AppColors.primaryNavy],
                ),
              ),
              child: imageUrl != null
                  // A catalog photo (it carries a credit) is a product shot of
                  // any shape — shown whole rather than cropped.
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: item.imageCredit != null ? BoxFit.contain : BoxFit.cover,
                    )
                  // No open-licensed photo of this model exists yet — show
                  // what it is rather than a bare icon.
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.smartphone_outlined, size: 64, color: AppColors.accentGold),
                          if (item.brandName != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              item.brandName!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ),
                // A live camera shot of this very unit (required for a used
                // one) — the same badge albums carry.
                if (imageUrl != null && item.cameraImageUrls.contains(imageUrl))
                  const MediaSourceBadge(source: MediaSource.camera),
              ],
            ),
          ),
          // The open licence's condition: credit the photographer.
          if (imageUrl != null && item.imageCredit != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                item.imageCredit!,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleLarge),
                if (item.brandName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.brandName!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${NumberFormat.decimalPattern('en').format(item.basePrice.round())} ${l10n.pharmacyCurrencyLabel}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.condition != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          item.condition!.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(item.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                ],
                if (item.specs.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    l10n.menuCardSpecsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _SpecTable(specs: item.specs),
                ],
                if (item.variants.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(l10n.cartVariantChoose, style: theme.textTheme.titleSmall),
                  ...item.variants.map(
                    (v) => RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      value: v.id,
                      groupValue: _variantId,
                      onChanged: (value) => setState(() => _variantId = value),
                      title: Text(v.name),
                      secondary: Text(v.price.toStringAsFixed(0)),
                    ),
                  ),
                ],
                for (final group in item.extraGroups) ...[
                  const SizedBox(height: 12),
                  Text(group.name, style: theme.textTheme.titleSmall),
                  if (group.isSingle)
                    ...item.extras.where((e) => e.extraGroupId == group.id).map(
                      (e) => RadioListTile<int>(
                        contentPadding: EdgeInsets.zero,
                        value: e.id,
                        groupValue: _singleGroupValue(group.id),
                        onChanged: (value) => _pickSingle(group.id, e.id),
                        title: Text(e.name),
                        secondary: Text('+${e.price.toStringAsFixed(0)}'),
                      ),
                    )
                  else
                    ...item.extras.where((e) => e.extraGroupId == group.id).map(
                      (e) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _extraIds.contains(e.id),
                        onChanged: (checked) => setState(() {
                          if (checked ?? false) {
                            _extraIds.add(e.id);
                          } else {
                            _extraIds.remove(e.id);
                          }
                        }),
                        title: Text(e.name),
                        secondary: Text('+${e.price.toStringAsFixed(0)}'),
                      ),
                    ),
                ],
                if (item.extras.any((e) => e.extraGroupId == null)) ...[
                  const SizedBox(height: 12),
                  Text(l10n.cartExtrasChoose, style: theme.textTheme.titleSmall),
                  ...item.extras.where((e) => e.extraGroupId == null).map(
                    (e) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _extraIds.contains(e.id),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _extraIds.add(e.id);
                        } else {
                          _extraIds.remove(e.id);
                        }
                      }),
                      title: Text(e.name),
                      secondary: Text('+${e.price.toStringAsFixed(0)}'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      // «هل شكل الازرار كدا افضل» — المالك، 2026-10-01. Quantity and the
      // total on one line, then the two actions side by side at the same
      // height: «أضف للسلة» (outlined, cart icon) and «شراء الآن» in the
      // brand gold — the price is said once, in the total, not on a button.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _QtyStepper(
                  qty: _qty,
                  onMinus: _qty > 1 ? () => setState(() => _qty--) : null,
                  onPlus: () => setState(() => _qty++),
                ),
                const Spacer(),
                Text(l10n.techDetailTotal, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(width: 8),
                Text(
                  '${NumberFormat.decimalPattern('en').format((_unitPrice * _qty).round())} ${l10n.pharmacyCurrencyLabel}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_submitting)
              const SizedBox(height: 52, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Row(
                children: [
                  if (widget.sharedOrderId == null) ...[
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirm(buyNow: false),
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                          label: Text(l10n.cartAdd),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            side: BorderSide(color: theme.colorScheme.primary, width: 1.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () => _confirm(buyNow: widget.sharedOrderId == null),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryNavy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        child: Text(widget.sharedOrderId == null ? l10n.cartBuyNow : l10n.cartAdd),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Same visual shape as `add_to_cart_sheet.dart`'s own private `_SpecTable`.
class _SpecTable extends StatelessWidget {
  final List<MenuItemSpec> specs;
  const _SpecTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++)
            Container(
              // «كبر الفونت التفاصيل وخليه اوضح» — المالك، 2026-10-01: the
              // label reads in the body colour (not the faint hint grey) and
              // the value one size up and bold.
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: i == specs.length - 1
                  ? null
                  : BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      specs[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // «المعالج مكتوب على سطرين خليه على سطر واحد فقط» — a long
                  // value («MediaTek Dimensity 6300») shrinks to fit one line.
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          specs[i].value,
                          maxLines: 1,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// − 1 + in one rounded pill, for the bottom bar.
class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;
  const _QtyStepper({required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded, size: 20),
          ),
          SizedBox(
            width: 28,
            child: Text('$qty', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
