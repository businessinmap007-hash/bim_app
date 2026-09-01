import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/data/models/menu_item_summary.dart';
import '../../application/cart_controller.dart';

/// Opens the picker for a menu item (variant + extras + qty) and adds it to
/// the cart on confirm. A plain item with no variants/extras skips straight
/// to a qty-only sheet — same widget, the variant/extras sections just don't
/// render when there's nothing to choose.
Future<void> showAddToCartSheet(BuildContext context, MenuItemSummary item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddToCartSheet(item: item),
  );
}

class _AddToCartSheet extends ConsumerStatefulWidget {
  final MenuItemSummary item;
  const _AddToCartSheet({required this.item});

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

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      await ref.read(cartControllerProvider.notifier).addItem(
        kind: 'menu',
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
              if (item.extras.isNotEmpty) ...[
                Text(l10n.cartExtrasChoose, style: Theme.of(context).textTheme.titleSmall),
                ...item.extras.map(
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
