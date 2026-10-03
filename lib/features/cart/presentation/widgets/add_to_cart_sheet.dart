import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/menu_item_summary.dart';
import '../../../offers/presentation/screens/offer_comparison_screen.dart';
import '../../application/cart_controller.dart';
import '../../application/shared_cart_providers.dart';
import '../screens/checkout_screen.dart';
import '../screens/tech_product_detail_screen.dart';
import 'cart_action_bar.dart';

/// Opens the picker for a menu item (variant + extras + qty) and adds it to
/// the cart on confirm. A plain item with no variants/extras skips straight
/// to a qty-only sheet — same widget, the variant/extras sections just don't
/// render when there's nothing to choose.
///
/// A catalog-linked item (one with a real spec table — see
/// [MenuItemSummary.specs]) opens the full-page [TechProductDetailScreen]
/// instead — a device model deserves a proper detail page (hero image, spec
/// table, condition badge), not a compact sheet. Both share the exact same
/// variant/extras/qty picker and cart submission underneath.
///
/// [sharedOrderId] routes the add through the group cart instead of the
/// caller's own solo cart — set when reached via SharedCartScreen's "add
/// items", which pushes BusinessDetailScreen carrying that id.
Future<void> showAddToCartSheet(BuildContext context, MenuItemSummary item, {int? sharedOrderId}) async {
  if (item.specs.isNotEmpty) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TechProductDetailScreen(item: item, sharedOrderId: sharedOrderId)),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddToCartSheet(item: item, sharedOrderId: sharedOrderId),
  );
}

class _AddToCartSheet extends ConsumerStatefulWidget {
  final MenuItemSummary item;
  final int? sharedOrderId;
  const _AddToCartSheet({required this.item, this.sharedOrderId});

  @override
  ConsumerState<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends ConsumerState<_AddToCartSheet> {
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

  /// The one selected extra in a single-select group, if any — read
  /// straight off [_extraIds] rather than kept as separate state, so there
  /// is exactly one source of truth for what is priced in.
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

      // Adding to cart only ever reserves a spot in line — nothing is
      // decremented from stock until checkout actually runs (see
      // CustomerCartService::placeOrder). "Buy now" skips straight to that
      // checkout instead of leaving this item to wait behind whatever else
      // is already in the cart.
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
    final item = widget.item;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.name, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              if (item.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              // A bundle isn't tracked by the offer-performance system a
              // single menu item is — nothing to compare against.
              if (item.kind != 'bundle')
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OfferComparisonScreen(
                          offerableType: 'menu_item',
                          offerableId: item.id,
                          itemTitle: item.name,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: Text(l10n.offerCompareButton),
                  ),
                ),
              if (item.specs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.menuCardSpecsTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                _SpecTable(specs: item.specs),
              ],
              const SizedBox(height: 16),
              if (item.variants.isNotEmpty) ...[
                Text(
                  item.variants.every((v) => v.type == 'payment') ? l10n.cartPaymentChoose : l10n.cartVariantChoose,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...item.variants.map(
                  (v) => RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    value: v.id,
                    groupValue: _variantId,
                    onChanged: (value) => setState(() => _variantId = value),
                    title: Text(v.name),
                    subtitle: v.installmentMonths != null && v.installmentMonths! > 1
                        ? Text(l10n.variantInstallmentNote(v.installmentMonths!, (v.price / v.installmentMonths!).round().toString()))
                        : null,
                    secondary: Text(v.price.toStringAsFixed(0)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Grouped extras first — each group is either a radio (one
              // pick, e.g. «المقاس») or a checkbox list (any number, e.g.
              // «الصوصات»), per the group's own selection_type. Extras with
              // no group render standalone, same as before groups existed.
              for (final group in item.extraGroups) ...[
                Text(group.name, style: Theme.of(context).textTheme.titleSmall),
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
                const SizedBox(height: 8),
              ],
              if (item.extras.any((e) => e.extraGroupId == null)) ...[
                Text(l10n.cartExtrasChoose, style: Theme.of(context).textTheme.titleSmall),
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
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              // The one bar every service draws — see CartActionBar.
              CartActionBar(
                total: _unitPrice * _qty,
                submitting: _submitting,
                sharedCart: widget.sharedOrderId != null,
                onAdd: () => _confirm(buyNow: false),
                onBuyNow: () => _confirm(buyNow: true),
                leading: CartQtyStepper(
                  qty: _qty,
                  onMinus: _qty > 1 ? () => setState(() => _qty--) : null,
                  onPlus: () => setState(() => _qty++),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The linked catalog master's spec table (processor, RAM…), label/value
/// rows same as [[three-catalog-shapes]]'s TechProductDetail canvas board —
/// only present when the merchant pointed this item at a real device model.
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: i == specs.length - 1
                  ? null
                  : BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(specs[i].name, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  ),
                  Text(
                    specs[i].value,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
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
