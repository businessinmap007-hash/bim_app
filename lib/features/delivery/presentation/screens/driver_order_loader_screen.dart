import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/delivery_providers.dart';
import 'driver_order_detail_screen.dart';

/// Where a driver's "order assigned to you" notification lands: finds that
/// order among the driver's active deliveries and shows it. (The driver's own
/// order screen needs the full order, which a notification only points to.)
class DriverOrderLoaderScreen extends ConsumerWidget {
  final int orderId;
  const DriverOrderLoaderScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myDeliveriesProvider);

    return async.maybeWhen(
      data: (orders) {
        final match = orders.where((o) => o.id == orderId);
        if (match.isNotEmpty) return DriverOrderDetailScreen(order: match.first);
        return Scaffold(
          appBar: AppBar(title: Text('#$orderId')),
          body: Center(child: Text(l10n.deliveryCompleted)),
        );
      },
      orElse: () => Scaffold(
        appBar: AppBar(title: Text('#$orderId')),
        body: AsyncValueView(
          value: async,
          onRetry: () => ref.invalidate(myDeliveriesProvider),
          builder: (context, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
