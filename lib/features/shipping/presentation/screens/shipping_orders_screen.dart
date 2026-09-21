import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../orders/data/models/placed_order.dart';
import '../../application/shipping_providers.dart';

/// The shipping company's orders: it only has to set (or change) the
/// appointment and move the order to shipped / delivered.
class ShippingOrdersScreen extends ConsumerStatefulWidget {
  const ShippingOrdersScreen({super.key});

  @override
  ConsumerState<ShippingOrdersScreen> createState() => _ShippingOrdersScreenState();
}

class _ShippingOrdersScreenState extends ConsumerState<ShippingOrdersScreen> {
  int? _busyId;

  Future<void> _run(int orderId, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busyId = orderId);
    try {
      await action();
      ref.invalidate(shippingOrdersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)),
        );
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _pickAppointment(PlacedOrder order) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: order.shipping?.appointmentAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (time == null || !mounted) return;

    final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await _run(order.id, () => ref.read(shippingApiProvider).setAppointment(order.id, at));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(shippingOrdersProvider);
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_jm();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shippingOrdersTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(shippingOrdersProvider),
        child: AsyncValueView<List<PlacedOrder>>(
          value: async,
          onRetry: () => ref.invalidate(shippingOrdersProvider),
          builder: (context, orders) {
            if (orders.isEmpty) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.shippingOrdersEmpty)))]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = orders[index];
                final ship = order.shipping;
                final busy = _busyId == order.id;
                final status = switch (ship?.status) {
                  'awaiting_appointment' => l10n.shippingStatusAwaitingAppointment,
                  'scheduled' => l10n.shippingStatusScheduled(ship?.appointmentAt == null ? '' : fmt.format(ship!.appointmentAt!)),
                  'shipped' => l10n.shippingStatusShipped,
                  'delivered' => l10n.shippingStatusDelivered,
                  _ => l10n.shippingStatusAwaitingCompany,
                };

                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${order.id} · ${order.businessName ?? ''}', style: Theme.of(context).textTheme.titleSmall),
                        if (order.customerName != null) Text(order.customerName!),
                        if (order.address != null) Text(order.address!),
                        if (ship?.fee != null) Text(l10n.shippingFeeLine(ship!.fee!.toStringAsFixed(0))),
                        const SizedBox(height: 4),
                        Text(status, style: TextStyle(color: Theme.of(context).hintColor)),
                        const SizedBox(height: 8),
                        if (busy)
                          const Center(child: CircularProgressIndicator())
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (ship?.status == 'awaiting_appointment' || ship?.status == 'scheduled')
                                OutlinedButton(
                                  onPressed: () => _pickAppointment(order),
                                  child: Text(ship!.status == 'scheduled' ? l10n.shippingChangeAppointment : l10n.shippingSetAppointment),
                                ),
                              if (ship?.status == 'scheduled')
                                FilledButton(
                                  onPressed: () => _run(order.id, () => ref.read(shippingApiProvider).markShipped(order.id)),
                                  child: Text(l10n.shippingMarkShipped),
                                ),
                              if (ship?.status == 'shipped')
                                FilledButton(
                                  onPressed: () => _run(order.id, () => ref.read(shippingApiProvider).markDelivered(order.id)),
                                  child: Text(l10n.shippingMarkDelivered),
                                ),
                            ],
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
