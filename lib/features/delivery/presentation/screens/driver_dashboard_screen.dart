import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../orders/data/models/placed_order.dart';
import '../../application/delivery_providers.dart';
import 'driver_order_detail_screen.dart';

/// The driver's own home screen — on/off-duty switch plus their currently
/// in-progress deliveries. A user with no `delivery_drivers` row yet sees
/// only the "become a driver" card; registering is idempotent, so tapping it
/// again later (e.g. after a business links them by phone) just confirms
/// the same row rather than erroring.
class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  Future<void> _register() async {
    await ref.read(driverAvailabilityControllerProvider.notifier).register();
    ref.invalidate(myDeliveriesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availability = ref.watch(driverAvailabilityControllerProvider);
    // Fetching this for a user who isn't a registered driver at all 403s
    // (myActiveOrders() -> driverOrFail()) -- only watch it once we know
    // there's a driver row to ask about.
    final deliveriesAsync = availability.status != null ? ref.watch(myDeliveriesProvider) : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveryDashboardTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myDeliveriesProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (availability.status == null && availability.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (availability.status == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.deliveryBecomeDriverTitle, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(l10n.deliveryBecomeDriverHint, style: TextStyle(color: Theme.of(context).hintColor)),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: availability.isLoading ? null : _register,
                        child: availability.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.deliveryBecomeDriver),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: SwitchListTile(
                  title: Text(l10n.deliveryOnDutySwitch),
                  subtitle: Text(availability.status!.isActive ? l10n.deliveryDriverOnDuty : l10n.deliveryDriverOffDuty),
                  value: availability.status!.isActive,
                  onChanged: availability.isLoading
                      ? null
                      : (v) => ref.read(driverAvailabilityControllerProvider.notifier).setActive(v),
                ),
              ),
            if (deliveriesAsync != null) ...[
              const SizedBox(height: 16),
              Text(l10n.deliveryMyActiveOrders, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AsyncValueView<List<PlacedOrder>>(
                value: deliveriesAsync,
                onRetry: () => ref.invalidate(myDeliveriesProvider),
                builder: (context, orders) {
                  if (orders.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text(l10n.deliveryNoActiveOrders)),
                    );
                  }

                  return Column(
                    children: [
                      for (final order in orders)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              order.deliveryStage == 'picked_up' ? Icons.local_shipping_outlined : Icons.storefront_outlined,
                            ),
                            title: Text(order.businessName ?? '#${order.id}'),
                            subtitle: Text(order.address ?? ''),
                            trailing: Text(order.finalTotal.toStringAsFixed(0)),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => DriverOrderDetailScreen(order: order)),
                              );
                              ref.invalidate(myDeliveriesProvider);
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
