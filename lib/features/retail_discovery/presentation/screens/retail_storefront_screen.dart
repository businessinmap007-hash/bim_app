import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/produce_emoji.dart';
import '../../../../shared/utils/retail_quantity_format.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../cart/application/cart_controller.dart';
import '../../../cart/presentation/screens/checkout_screen.dart';
import '../../application/retail_discovery_providers.dart';
import '../../data/models/catalog_product_listing.dart';

/// One seller's whole retail shelf — what a [RetailListingCard] on the
/// Categories screen's "Retail" feed opens into. Shows every active listing
/// (not just the one tapped) plus the seller's own minimum order amount up
/// front, since that's a fact about the WHOLE cart, not one line in it — see
/// CustomerCartService::assertMeetsRetailMinimum().
class RetailStorefrontScreen extends ConsumerStatefulWidget {
  final int businessId;
  const RetailStorefrontScreen({super.key, required this.businessId});

  @override
  ConsumerState<RetailStorefrontScreen> createState() => _RetailStorefrontScreenState();
}

class _RetailStorefrontScreenState extends ConsumerState<RetailStorefrontScreen> {
  // Nothing chosen means every row, each with its own price and description.
  final Set<int> _conditions = {};
  final Set<int> _payments = {};

  int get businessId => widget.businessId;

  Widget _filterBar(AppLocalizations l10n, List<RetailStorefrontListing> all) {
    final conditions = {
      for (final l in all)
        if (l.condition != null) l.condition!.id: l.condition!.name,
    };
    final payments = {
      for (final l in all)
        if (l.payment != null) l.payment!.id: l.payment!.name,
    };
    if (conditions.isEmpty && payments.isEmpty) return const SizedBox.shrink();

    Widget chips(Map<int, String> options, Set<int> selected) => Wrap(
      spacing: 6,
      children: [
        for (final e in options.entries)
          FilterChip(
            label: Text(e.value),
            selected: selected.contains(e.key),
            onSelected: (on) => setState(() => on ? selected.add(e.key) : selected.remove(e.key)),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conditions.isNotEmpty) chips(conditions, _conditions),
          if (payments.isNotEmpty) chips(payments, _payments),
          if (_conditions.isNotEmpty || _payments.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                _conditions.clear();
                _payments.clear();
              }),
              child: Text(l10n.retailVariantFilterClear),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storefrontAsync = ref.watch(retailStorefrontProvider(businessId));

    return Scaffold(
      appBar: AppBar(
        title: storefrontAsync.maybeWhen(data: (s) => Text(s.businessName), orElse: () => const SizedBox.shrink()),
      ),
      body: AsyncValueView<RetailStorefront>(
        value: storefrontAsync,
        onRetry: () => ref.invalidate(retailStorefrontProvider(businessId)),
        builder: (context, storefront) {
          if (storefront.listings.isEmpty && storefront.variantGroups.isEmpty) {
            return Center(child: Text(l10n.retailStorefrontEmpty));
          }

          final listings = storefront.listings
              .where((l) => _conditions.isEmpty || (l.condition != null && _conditions.contains(l.condition!.id)))
              .where((l) => _payments.isEmpty || (l.payment != null && _payments.contains(l.payment!.id)))
              .toList();
          final filtering = _conditions.isNotEmpty || _payments.isNotEmpty;
          final groups = filtering ? const <RetailVariantGroupCard>[] : storefront.variantGroups;
          final groupCount = groups.length;
          final total = groupCount + listings.length;

          return Column(
            children: [
              _filterBar(l10n, storefront.listings),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: total,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index < groupCount) {
                      return _VariantGroupTile(group: groups[index]);
                    }
                    final listing = listings[index - groupCount];
                    return _StorefrontListingTile(listing: listing);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shared by a plain listing tile and a variant tile (once a variant is
/// picked, it is just a listing like any other) — quantity, then cart or
/// straight to checkout.
Future<void> _openQuantitySheet(BuildContext context, WidgetRef ref, RetailStorefrontListing listing) async {
  final result = await showModalBottomSheet<({int qty, bool buyNow, List<int> extras})>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _QuantitySheet(listing: listing),
  );
  if (result == null || !context.mounted) return;

  final l10n = AppLocalizations.of(context)!;
  try {
    final cart = await ref
        .read(cartControllerProvider.notifier)
        .addItem(kind: 'retail', offeringId: listing.listingId, qty: result.qty, extras: result.extras);
    if (!context.mounted) return;

    // Adding to cart only ever reserves a spot in line — checkout is what
    // actually takes the stock (CustomerCartService::placeOrder). "Buy
    // now" skips straight there instead of waiting behind the rest of
    // whatever else is already in the cart.
    if (result.buyNow) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(cart: cart)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartAddedToCart)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }
}

class _VariantGroupTile extends ConsumerWidget {
  final RetailVariantGroupCard group;
  const _VariantGroupTile({required this.group});

  Future<void> _pickVariant(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final chosen = await showModalBottomSheet<RetailVariantOptionCard>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.retailStorefrontChooseVariantTitle, style: TextStyle(color: Theme.of(sheetContext).hintColor)),
              const SizedBox(height: 12),
              for (final o in group.options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(o.label),
                  trailing: Text('${o.price.toStringAsFixed(0)} ${o.currency}'),
                  enabled: o.stock == null || o.stock! > 0,
                  onTap: () => Navigator.of(sheetContext).pop(o),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen == null || !context.mounted) return;
    await _openQuantitySheet(context, ref, chosen.toStorefrontListing(group.name, group.image));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => _pickVariant(context, ref),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: group.image != null
                ? CachedNetworkImage(imageUrl: group.image!, fit: BoxFit.cover)
                : Container(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                    alignment: Alignment.center,
                    child: Text(produceEmoji(group.name), style: const TextStyle(fontSize: 20)),
                  ),
          ),
        ),
        title: Text(group.name),
        subtitle: Text('${group.options.length} · ${group.priceFrom.toStringAsFixed(0)}+'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _StorefrontListingTile extends ConsumerWidget {
  final RetailStorefrontListing listing;
  const _StorefrontListingTile({required this.listing});

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
          onTap: outOfStock ? null : () => _openQuantitySheet(context, ref, listing),
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
              if (listing.condition != null || listing.payment != null)
                Text(
                  [listing.condition?.name, listing.payment?.name].whereType<String>().join(' · '),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              if (listing.specs.length > 1)
                Text(
                  listing.specs.skip(1).take(3).map((s) => s.value).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
                ),
              if (listing.description != null)
                Text(
                  listing.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
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
              ? Text(
                  l10n.businessOutOfStock,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.error),
                )
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
  String? _error;
  final Set<int> _picked = {};

  double get _unitPrice =>
      widget.listing.price +
      widget.listing.extras.where((e) => _picked.contains(e.id)).fold(0.0, (a, e) => a + e.price);

  void _toggleExtra(RetailExtra e) {
    setState(() {
      if (_picked.contains(e.id)) {
        _picked.remove(e.id);
        return;
      }
      if (e.isSingle && e.group != null) {
        _picked.removeAll(widget.listing.extras.where((x) => x.group == e.group).map((x) => x.id));
      }
      _picked.add(e.id);
    });
  }

  Widget _extrasSection(BuildContext context) {
    final theme = Theme.of(context);
    final groups = <String?, List<RetailExtra>>{};
    for (final e in widget.listing.extras) {
      groups.putIfAbsent(e.group, () => []).add(e);
    }

    Widget tile(RetailExtra e) {
      final on = _picked.contains(e.id);
      final single = e.isSingle && e.group != null;
      return InkWell(
        onTap: () => _toggleExtra(e),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                single
                    ? (on ? Icons.radio_button_checked : Icons.radio_button_unchecked)
                    : (on ? Icons.check_box : Icons.check_box_outline_blank),
                size: 22,
                color: on ? AppColors.accentGold : theme.hintColor,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(e.name)),
              Text('+${e.price.toStringAsFixed(0)}', style: TextStyle(color: theme.hintColor)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries) ...[
          if (entry.key != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(entry.key!, style: theme.textTheme.titleSmall),
            ),
          for (final e in entry.value) tile(e),
        ],
      ],
    );
  }

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
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  /// Runs on every keystroke, but only ever REWRITES the field when the
  /// typed value is out of range — a value still climbing toward a valid
  /// number (typing "2" on the way to "25") is left alone so the field
  /// never fights the user mid-type. The stray keyboard-not-opening bug
  /// this replaced came from a FocusNode blur listener rewriting the
  /// controller's text while focus was still resolving — plain onChanged
  /// has no such focus-lifecycle interaction.
  void _onTyped(String text) {
    final typed = int.tryParse(text.trim());
    if (typed == null) return;

    final max = _maxQty;
    final tooLow = typed < _minQty;
    final tooHigh = max != null && typed > max;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _qty = typed;
      _error = tooHigh
          ? l10n.retailStorefrontQtyOutOfRange(
              formatRetailQty(_minQty, widget.listing.unit),
              formatRetailQty(max, widget.listing.unit),
            )
          : (tooLow ? l10n.retailStorefrontQtyBelowMin(formatRetailQty(_minQty, widget.listing.unit)) : null);
    });
  }

  /// Clamps into range — called on submit and right before "Add to cart"
  /// so an out-of-range value never actually gets ordered, even though the
  /// field itself was left visible while the user was still typing.
  void _commitTypedQty() {
    final typed = int.tryParse(_qtyController.text.trim()) ?? _qty;
    final max = _maxQty;
    var clamped = typed < _minQty ? _minQty : typed;
    if (max != null && clamped > max) clamped = max;
    _setQty(clamped);
  }

  void _setQty(int value) {
    setState(() {
      _qty = value;
      _error = null;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.listing.productName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '${_unitPrice.toStringAsFixed(0)} ${widget.listing.currency}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accentGold),
              ),
              if (widget.listing.specs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < widget.listing.specs.length; i++)
                        Container(
                          color: i.isEven ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04) : null,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.listing.specs[i].name,
                                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                                ),
                              ),
                              Text(
                                widget.listing.specs[i].value,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
              if (widget.listing.extras.isNotEmpty) ...[const SizedBox(height: 8), _extrasSection(context)],
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
                        width: 72,
                        child: TextField(
                          controller: _qtyController,
                          keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: _onTyped,
                          onSubmitted: (_) => _commitTypedQty(),
                          onTapOutside: (_) => _commitTypedQty(),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _commitTypedQty();
                        Navigator.of(context).pop((qty: _qty, buyNow: false, extras: _picked.toList()));
                      },
                      child: Text(l10n.cartAdd),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        _commitTypedQty();
                        Navigator.of(context).pop((qty: _qty, buyNow: true, extras: _picked.toList()));
                      },
                      child: Text(
                        '${l10n.cartBuyNow} · ${(_unitPrice * _qty).toStringAsFixed(0)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
