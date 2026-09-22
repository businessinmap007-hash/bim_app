import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/placed_order.dart';

/// Who is bringing the order: name, vehicle and a one-tap call. Only shown once
/// a driver has been assigned to the delivery.
class OrderDriverCard extends StatelessWidget {
  final OrderDriver driver;
  const OrderDriverCard({super.key, required this.driver});

  Future<void> _call(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await launchUrl(Uri(scheme: 'tel', path: driver.phone));
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.delivery_dining_outlined),
        title: Text(driver.name),
        subtitle: Text(
          [l10n.orderDriverTitle, if (driver.vehicleLabel != null && driver.vehicleLabel!.isNotEmpty) driver.vehicleLabel!].join(' · '),
        ),
        trailing: driver.phone != null && driver.phone!.isNotEmpty
            ? IconButton(icon: const Icon(Icons.call_outlined), tooltip: l10n.orderDriverCall, onPressed: () => _call(context))
            : null,
      ),
    );
  }
}
