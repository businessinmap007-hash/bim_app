import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/menu_item_summary.dart';
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
///
/// Forced into [AppTheme.dark] like [TechPricingScreen] — see that file's
/// doc comment for why a detailed device's own catalog surfaces keep the
/// canvas's navy/gold identity regardless of the customer's own device
/// theme setting.
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
    return Theme(data: AppTheme.dark(), child: Builder(builder: _buildScaffold));
  }

  Widget _buildScaffold(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelStyle = const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white);
    final item = widget.item;
    final imageUrl = item.imageUrl ?? (item.imageUrls.isNotEmpty ? item.imageUrls.first : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuItemDetailTitle)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryNavyLight, AppColors.primaryNavy],
                ),
              ),
              child: imageUrl != null
                  ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.smartphone_outlined, size: 72, color: AppColors.accentGold),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      item.basePrice.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accentGold),
                    ),
                    if (item.condition != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          item.condition!.name,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.55)),
                  ),
                ],
                if (item.specs.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(l10n.menuCardSpecsTitle, style: labelStyle),
                  const SizedBox(height: 8),
                  _SpecTable(specs: item.specs),
                ],
                if (item.variants.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(l10n.cartVariantChoose, style: labelStyle),
                  const SizedBox(height: 4),
                  _OptionGroup(
                    multi: false,
                    rows: [
                      for (final v in item.variants)
                        _OptionRowData(
                          id: v.id,
                          label: v.name,
                          trailing: v.price.toStringAsFixed(0),
                          selected: v.id == _variantId,
                        ),
                    ],
                    onTap: (id) => setState(() => _variantId = id),
                  ),
                ],
                for (final group in item.extraGroups) ...[
                  const SizedBox(height: 16),
                  Text(group.name, style: labelStyle),
                  const SizedBox(height: 4),
                  _OptionGroup(
                    multi: !group.isSingle,
                    rows: [
                      for (final e in item.extras.where((e) => e.extraGroupId == group.id))
                        _OptionRowData(
                          id: e.id,
                          label: e.name,
                          trailing: '+${e.price.toStringAsFixed(0)}',
                          selected: group.isSingle ? e.id == _singleGroupValue(group.id) : _extraIds.contains(e.id),
                        ),
                    ],
                    onTap: (id) => group.isSingle
                        ? _pickSingle(group.id, id)
                        : setState(() => _extraIds.contains(id) ? _extraIds.remove(id) : _extraIds.add(id)),
                  ),
                ],
                if (item.extras.any((e) => e.extraGroupId == null)) ...[
                  const SizedBox(height: 16),
                  Text(l10n.cartExtrasChoose, style: labelStyle),
                  const SizedBox(height: 4),
                  _OptionGroup(
                    multi: true,
                    rows: [
                      for (final e in item.extras.where((e) => e.extraGroupId == null))
                        _OptionRowData(
                          id: e.id,
                          label: e.name,
                          trailing: '+${e.price.toStringAsFixed(0)}',
                          selected: _extraIds.contains(e.id),
                        ),
                    ],
                    onTap: (id) => setState(() => _extraIds.contains(id) ? _extraIds.remove(id) : _extraIds.add(id)),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.marketCatalogQuantity,
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                            icon: const Icon(Icons.remove, size: 18),
                            color: Colors.white,
                            disabledColor: Colors.white.withValues(alpha: 0.2),
                          ),
                          SizedBox(
                            width: 28,
                            child: Text(
                              '$_qty',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _qty++),
                            icon: const Icon(Icons.add, size: 18),
                            color: AppColors.accentGold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: _submitting
            ? const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold),
                ),
              )
            : widget.sharedOrderId != null
            ? SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _confirm(buyNow: false),
                  child: Text('${l10n.cartAdd} · ${(_unitPrice * _qty).toStringAsFixed(0)}'),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirm(buyNow: false),
                      child: Text(l10n.cartAdd),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => _confirm(buyNow: true),
                      child: Text('${l10n.cartBuyNow} · ${(_unitPrice * _qty).toStringAsFixed(0)}'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Same visual shape as `add_to_cart_sheet.dart`'s own private `_SpecTable`,
/// dark-styled to the canvas's own spec-row look.
class _SpecTable extends StatelessWidget {
  final List<MenuItemSpec> specs;
  const _SpecTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: i.isEven ? Colors.white.withValues(alpha: 0.03) : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      specs[i].name,
                      style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                  Text(
                    specs[i].value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionRowData {
  final int id;
  final String label;
  final String trailing;
  final bool selected;
  const _OptionRowData({required this.id, required this.label, required this.trailing, required this.selected});
}

/// A canvas-matching row group: a radio (single-select) or checkbox
/// (multi-select) mark that is hand-drawn rather than a Material
/// `RadioListTile`/`CheckboxListTile`, to match the Tech Catalog Setup
/// canvas exactly — unselected = a plain outlined ring/box, selected =
/// filled gold with a navy dot (radio) or a navy check (checkbox), never
/// the platform's own blue/teal check styling.
class _OptionGroup extends StatelessWidget {
  final bool multi;
  final List<_OptionRowData> rows;
  final ValueChanged<int> onTap;
  const _OptionGroup({required this.multi, required this.rows, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            InkWell(
              onTap: () => onTap(rows[i].id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: i == rows.length - 1
                      ? null
                      : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                ),
                child: Row(
                  children: [
                    _Mark(multi: multi, selected: rows[i].selected),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rows[i].label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    Text(
                      rows[i].trailing,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  final bool multi;
  final bool selected;
  const _Mark({required this.multi, required this.selected});

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    if (multi) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? AppColors.accentGold : Colors.transparent,
          border: Border.all(color: selected ? AppColors.accentGold : Colors.white.withValues(alpha: 0.35), width: 1.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: selected ? const Icon(Icons.check, size: 14, color: AppColors.primaryNavy) : null,
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? AppColors.accentGold : Colors.transparent,
        border: Border.all(color: selected ? AppColors.accentGold : Colors.white.withValues(alpha: 0.35), width: 1.5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.primaryNavy, shape: BoxShape.circle),
            )
          : null,
    );
  }
}
