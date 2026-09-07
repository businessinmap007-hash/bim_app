import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/menu_item_summary.dart';
import '../../../offers/presentation/screens/offer_comparison_screen.dart';
import '../../application/cart_controller.dart';
import '../../application/shared_cart_providers.dart';

/// Opens the picker for a menu item (variant + extras + qty) and adds it to
/// the cart on confirm. A plain item with no variants/extras skips straight
/// to a qty-only sheet — same widget, the variant/extras sections just don't
/// render when there's nothing to choose.
///
/// [sharedOrderId] routes the add through the group cart instead of the
/// caller's own solo cart — set when reached via SharedCartScreen's "add
/// items", which pushes BusinessDetailScreen carrying that id.
Future<void> showAddToCartSheet(BuildContext context, MenuItemSummary item, {int? sharedOrderId}) {
  return showModalBottomSheet<void>(
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

  Future<void> _confirm() async {
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
      } else {
        await ref.read(cartControllerProvider.notifier).addItem(
          kind: widget.item.kind,
          offeringId: widget.item.id,
          qty: _qty,
          sizeId: _variantId,
          extras: _extraIds.toList(),
        );
      }
      if (mounted) {
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
              const SizedBox(height: 16),
              if (item.variants.isNotEmpty) ...[
                Text(l10n.cartVariantChoose, style: Theme.of(context).textTheme.titleSmall),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('$_qty', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _qty++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _submitting ? null : _confirm,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('${l10n.cartAdd} · ${(_unitPrice * _qty).toStringAsFixed(0)}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
