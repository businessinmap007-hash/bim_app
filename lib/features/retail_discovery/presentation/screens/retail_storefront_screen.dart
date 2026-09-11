import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/produce_emoji.dart';
import '../../../../shared/utils/retail_quantity_format.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../cart/application/cart_controller.dart';
import '../../application/retail_discovery_providers.dart';
import '../../data/models/catalog_product_listing.dart';

/// One seller's whole retail shelf — what a [RetailListingCard] on the
/// Categories screen's "Retail" feed opens into. Shows every active listing
/// (not just the one tapped) plus the seller's own minimum order amount up
/// front, since that's a fact about the WHOLE cart, not one line in it — see
/// CustomerCartService::assertMeetsRetailMinimum().
class RetailStorefrontScreen extends ConsumerWidget {
  final int businessId;
  const RetailStorefrontScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final storefrontAsync = ref.watch(retailStorefrontProvider(businessId));

    return Scaffold(
      appBar: AppBar(
        title: storefrontAsync.maybeWhen(
          data: (s) => Text(s.businessName),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
      body: AsyncValueView<RetailStorefront>(
        value: storefrontAsync,
        onRetry: () => ref.invalidate(retailStorefrontProvider(businessId)),
        builder: (context, storefront) {
          if (storefront.listings.isEmpty) {
            return Center(child: Text(l10n.retailStorefrontEmpty));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: storefront.listings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final listing = storefront.listings[index];
              return _StorefrontListingTile(listing: listing);
            },
          );
        },
      ),
    );
  }
}

class _StorefrontListingTile extends ConsumerWidget {
  final RetailStorefrontListing listing;
  const _StorefrontListingTile({required this.listing});

  Future<void> _openQuantitySheet(BuildContext context, WidgetRef ref) async {
    final qty = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuantitySheet(listing: listing),
    );
    if (qty == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(cartControllerProvider.notifier).addItem(kind: 'retail', offeringId: listing.listingId, qty: qty);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartAddedToCart)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final outOfStock = listing.stock != null && listing.stock! <= 0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: outOfStock ? 0.6 : 1,
        child: ListTile(
          onTap: outOfStock ? null : () => _openQuantitySheet(context, ref),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: listing.productImage != null
                  ? CachedNetworkImage(imageUrl: listing.productImage!, fit: BoxFit.cover)
                  : Container(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: Text(produceEmoji(listing.productNameEn), style: const TextStyle(fontSize: 20)),
                    ),
            ),
          ),
          title: Text(listing.productName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                listing.minOrderQty != null
                    ? '${listing.price.toStringAsFixed(0)} ${listing.currency} · ${l10n.retailStorefrontMinQtyLabel(formatRetailQty(listing.minOrderQty!, listing.unit))}'
                    : '${listing.price.toStringAsFixed(0)} ${listing.currency}',
              ),
              if (!outOfStock && listing.stock != null)
                Text(
                  l10n.retailListingAvailableQtyBadge(formatRetailQty(listing.stock!, listing.unit)),
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
                ),
            ],
          ),
          trailing: outOfStock
              ? Text(l10n.businessOutOfStock, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.error))
              : CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.accentGold.withValues(alpha: 0.15),
                  child: const Icon(Icons.add, size: 18, color: AppColors.accentGold),
                ),
        ),
      ),
    );
  }
}

/// A plain quantity stepper — a retail listing has no variants/extras the
/// way a menu item does, so there's nothing else to pick here.
class _QuantitySheet extends StatefulWidget {
  final RetailStorefrontListing listing;
  const _QuantitySheet({required this.listing});

  @override
  State<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends State<_QuantitySheet> {
  late int _qty = widget.listing.minOrderQty ?? 1;
  late final _qtyController = TextEditingController(text: '$_qty');
  final _qtyFocusNode = FocusNode();
  String? _error;

  int get _minQty => widget.listing.minOrderQty ?? 1;

  /// Whichever of stock and the listing's own max-order cap is tighter —
  /// either, both, or neither may be set. Null means no ceiling at all.
  int? get _maxQty {
    final stock = widget.listing.stock;
    final cap = widget.listing.maxOrderQty;
    if (stock == null) return cap;
    if (cap == null) return stock;
    return stock < cap ? stock : cap;
  }

  @override
  void initState() {
    super.initState();
    // Clamp on blur rather than on every keystroke — rewriting the field
    // mid-type would stop a user typing "25" the moment they'd typed "2"
    // and the minimum happened to be above that.
    _qtyFocusNode.addListener(() {
      if (!_qtyFocusNode.hasFocus) _commitTypedQty();
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  void _commitTypedQty() => _setQty(int.tryParse(_qtyController.text.trim()) ?? _qty);

  void _setQty(int value) {
    final max = _maxQty;
    var clamped = value < _minQty ? _minQty : value;
    if (max != null && clamped > max) clamped = max;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _qty = clamped;
      _error = value != clamped
          ? (max != null
              ? l10n.retailStorefrontQtyOutOfRange(formatRetailQty(_minQty, widget.listing.unit), formatRetailQty(max, widget.listing.unit))
              : l10n.retailStorefrontQtyBelowMin(formatRetailQty(_minQty, widget.listing.unit)))
          : null;
    });
    _qtyController.text = '$_qty';
    _qtyController.selection = TextSelection.collapsed(offset: _qtyController.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxQty = _maxQty;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.listing.productName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${widget.listing.price.toStringAsFixed(0)} ${widget.listing.currency}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accentGold),
            ),
            if (widget.listing.minOrderQty != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.retailStorefrontMinQtyLabel(formatRetailQty(widget.listing.minOrderQty!, widget.listing.unit)),
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
              ),
            ],
            if (widget.listing.maxOrderQty != null) ...[
              const SizedBox(height: 2),
              Text(
                l10n.retailStorefrontMaxQtyLabel(formatRetailQty(widget.listing.maxOrderQty!, widget.listing.unit)),
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.retailStorefrontQuantityLabel),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _qty > _minQty ? () => _setQty(_qty - 1) : null,
                    ),
                    SizedBox(
                      width: 64,
                      child: TextField(
                        controller: _qtyController,
                        focusNode: _qtyFocusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                        onSubmitted: (_) => _commitTypedQty(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: (maxQty == null || _qty < maxQty) ? () => _setQty(_qty + 1) : null,
                    ),
                  ],
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  _commitTypedQty();
                  Navigator.of(context).pop(_qty);
                },
                child: Text(l10n.cartAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
