import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/shared_cart_providers.dart';
import '../../data/models/shared_cart.dart';

/// The group cart: a host's cart shared by token, friends join and each adds
/// their own lines. Cash on arrival — each participant's own total is shown,
/// but there is no per-participant payment step here.
class SharedCartScreen extends ConsumerWidget {
  final int orderId;
  const SharedCartScreen({super.key, required this.orderId});

  Future<void> _addItems(BuildContext context, SharedCart cart) async {
    if (cart.businessId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BusinessDetailScreen(businessId: cart.businessId!, sharedOrderId: orderId),
      ),
    );
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(sharedCartControllerProvider(orderId).notifier).checkout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartOrderPlaced)));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.sharedCartLeaveConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.sharedCartLeave)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(sharedCartControllerProvider(orderId).notifier).leave();
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _cancelCart(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.sharedCartCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.sharedCartCancelCart)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(sharedCartControllerProvider(orderId).notifier).cancel();
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sharedCartControllerProvider(orderId));
    final cart = state.cart;

    return Scaffold(
      appBar: AppBar(
        title: Text(cart?.businessName ?? l10n.sharedCartTitle),
        actions: [
          if (cart?.shareToken != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: cart!.shareToken!));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartShareCopied)));
                }
              },
            ),
        ],
      ),
      body: state.isLoading && cart == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && cart == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(sharedCartControllerProvider(orderId).notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : cart == null
          ? const SizedBox.shrink()
          : RefreshIndicator(
              onRefresh: () => ref.read(sharedCartControllerProvider(orderId).notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l10n.sharedCartParticipants, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final p in cart.participants) _ParticipantRow(participant: p),
                  const SizedBox(height: 20),
                  if (cart.items.isNotEmpty) ...[
                    Divider(color: Theme.of(context).dividerColor),
                    const SizedBox(height: 8),
                    for (final item in cart.items) _SharedItemRow(item: item),
                    const SizedBox(height: 8),
                  ],
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.cartFinalTotal, style: Theme.of(context).textTheme.titleMedium),
                      Text(cart.grandTotal.toStringAsFixed(0), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _addItems(context, cart),
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    label: Text(l10n.sharedCartAddItems),
                  ),
                  const SizedBox(height: 12),
                  if (cart.viewerIsHost) ...[
                    FilledButton(
                      onPressed: () => _checkout(context, ref),
                      child: Text(l10n.cartPlaceOrder),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _cancelCart(context, ref),
                      style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                      child: Text(l10n.sharedCartCancelCart),
                    ),
                  ] else
                    OutlinedButton(
                      onPressed: () => _leave(context, ref),
                      style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                      child: Text(l10n.sharedCartLeave),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  final SharedCartParticipant participant;
  const _ParticipantRow({required this.participant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(participant.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (participant.isHost) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.sharedCartHostBadge,
                      style: const TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(participant.total.toStringAsFixed(0)),
        ],
      ),
    );
  }
}

class _SharedItemRow extends StatelessWidget {
  final SharedCartItem item;
  const _SharedItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.qty}× ${item.name}'),
                Text(
                  item.addedByName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          Text(item.totalPrice.toStringAsFixed(0)),
        ],
      ),
    );
  }
}
