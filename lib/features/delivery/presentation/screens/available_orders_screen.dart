import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/delivery_providers.dart';

/// "الطلبات المتاحة" - ready delivery orders a driver can take from the open
/// pool (DeliveryController::available / accept). Accepting hands the order
/// to this driver; from there it lives under "My active deliveries".
class AvailableOrdersScreen extends ConsumerStatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  ConsumerState<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends ConsumerState<AvailableOrdersScreen> {
  int? _acceptingId;

  Future<void> _accept(int orderId) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _acceptingId = orderId);
    try {
      await ref.read(deliveryApiProvider).acceptOrder(orderId);
      ref.invalidate(myDeliveriesProvider);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.deliveryOrderAccepted)));
    } catch (e) {
      // Someone else may have taken it first (409) - refresh the pool either way.
      ref.invalidate(availableDeliveryOrdersProvider);
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _acceptingId = null);
    }
  }

  String _num(dynamic v) {
    final d = (v as num?)?.toDouble() ?? 0;
    return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(availableDeliveryOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveryAvailableOrdersTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(availableDeliveryOrdersProvider),
        child: AsyncValueView<List<Map<String, dynamic>>>(
          value: async,
          onRetry: () => ref.invalidate(availableDeliveryOrdersProvider),
          builder: (context, orders) {
            if (orders.isEmpty) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text(l10n.deliveryAvailableOrdersEmpty, textAlign: TextAlign.center)),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = orders[index];
                final id = order['order_id'] as int;
                final business = (order['business'] as Map<String, dynamic>?)?['name'] as String?;
                final address = (order['address'] as String?) ?? '';
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${business ?? ''} · #$id', style: Theme.of(context).textTheme.titleSmall),
                        if (address.isNotEmpty) Text(address),
                        const SizedBox(height: 4),
                        Text(l10n.deliveryOrderTotalLine(_num(order['final_total']))),
                        Text(l10n.deliveryFeeLine(_num(order['delivery_fee']))),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _acceptingId != null ? null : () => _accept(id),
                            child: _acceptingId == id
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(l10n.deliveryAcceptOrder),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
