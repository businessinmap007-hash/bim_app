import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/cart_controller.dart';
import '../../application/shared_cart_providers.dart';
import '../../data/models/cart_models.dart';
import 'checkout_screen.dart';
import 'qr_scan_screen.dart';
import 'shared_cart_screen.dart';

/// Every business the customer has a draft order with, one card per
/// business — checkout happens per business (a cart is one business's
/// order; see CartController on the backend), not across all of them at
/// once.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _joinSharedCart(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cartJoinSharedCart),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.cartJoinTokenHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.cartJoinAction),
          ),
        ],
      ),
    );
    if (token == null || token.isEmpty || !context.mounted) return;
    await _completeJoin(context, ref, token);
  }

  Future<void> _scanQrToJoin(BuildContext context, WidgetRef ref) async {
    final token = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (token == null || token.isEmpty || !context.mounted) return;
    await _completeJoin(context, ref, token);
  }

  Future<void> _completeJoin(BuildContext context, WidgetRef ref, String token) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final cart = await ref.read(sharedCartApiProvider).join(token);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SharedCartScreen(orderId: cart.id)),
        );
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
    final state = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartTitle),
        actions: [
          IconButton(
            tooltip: l10n.qrScanTitle,
            icon: const Icon(Icons.qr_code_scanner_outlined),
            onPressed: () => _scanQrToJoin(context, ref),
          ),
          IconButton(
            tooltip: l10n.cartJoinSharedCart,
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => _joinSharedCart(context, ref),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.carts.isEmpty
          ? Center(child: Text(l10n.cartEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(cartControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.carts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _BusinessCartCard(cart: state.carts[index]),
              ),
            ),
    );
  }
}

class _BusinessCartCard extends ConsumerWidget {
  final Cart cart;
  const _BusinessCartCard({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: cart.business?.logoUrl != null ? NetworkImage(cart.business!.logoUrl!) : null,
                  child: cart.business?.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(cart.business?.name ?? '', style: Theme.of(context).textTheme.titleSmall),
                ),
                Text(l10n.cartItemsCount(cart.itemsCount)),
              ],
            ),
            const Divider(height: 20),
            ...cart.items.map((item) => _CartItemRow(item: item)),
            const Divider(height: 20),
            _TotalsBlock(bill: cart.bill, deliveryFee: cart.deliveryFee, discount: cart.discount, finalTotal: cart.finalTotal),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckoutScreen(cart: cart)),
              ),
              child: Text(l10n.cartCheckout),
            ),
            if (cart.business != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final businessId = cart.business!.id;
                  // Captured before any await: reloading the cart list below
                  // rebuilds this very card with a fresh BuildContext, so a
                  // Navigator looked up afterward would belong to a disposed
                  // widget and silently no-op.
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final shared = await ref.read(sharedCartApiProvider).share(businessId);
                    unawaited(ref.read(cartControllerProvider.notifier).load());
                    navigator.push(
                      MaterialPageRoute(builder: (_) => SharedCartScreen(orderId: shared.orderId)),
                    );
                  } catch (_) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.commonSomethingWentWrong)),
                    );
                  }
                },
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.cartShareCart),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final optionParts = [
      if (item.sizeName != null) item.sizeName!,
      ...item.extraNames,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.bodyMedium),
                if (optionParts.isNotEmpty)
                  Text(optionParts.join(' · '), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: item.qty > 1
                ? () => ref.read(cartControllerProvider.notifier).updateItemQty(item.id, item.qty - 1)
                : () => ref.read(cartControllerProvider.notifier).removeItem(item.id),
            icon: const Icon(Icons.remove_circle_outline, size: 20),
          ),
          Text('${item.qty}'),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => ref.read(cartControllerProvider.notifier).updateItemQty(item.id, item.qty + 1),
            icon: const Icon(Icons.add_circle_outline, size: 20),
          ),
          SizedBox(
            width: 56,
            child: Text(item.totalPrice.toStringAsFixed(0), textAlign: TextAlign.end),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: l10n.cartRemove,
            onPressed: () => ref.read(cartControllerProvider.notifier).removeItem(item.id),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }
}

class _TotalsBlock extends StatelessWidget {
  final CartBill bill;
  final double deliveryFee;
  final double discount;
  final double finalTotal;

  const _TotalsBlock({required this.bill, required this.deliveryFee, required this.discount, required this.finalTotal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtotal = bill.menuSubtotal + bill.retailSubtotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalRow(label: l10n.cartSubtotal, value: subtotal),
        if (bill.serviceFee > 0 && !bill.serviceIncluded) _TotalRow(label: l10n.cartServiceFee, value: bill.serviceFee),
        if (bill.tax > 0 && !bill.taxIncluded) _TotalRow(label: l10n.cartTax, value: bill.tax),
        if (deliveryFee > 0) _TotalRow(label: l10n.cartDeliveryFee, value: deliveryFee),
        if (discount > 0) _TotalRow(label: l10n.cartDiscount, value: -discount),
        _TotalRow(label: l10n.cartFinalTotal, value: finalTotal, emphasize: true),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;
  const _TotalRow({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value.toStringAsFixed(0), style: style),
        ],
      ),
    );
  }
}
