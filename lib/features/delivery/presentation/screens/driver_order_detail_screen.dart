import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/data/models/placed_order.dart';
import '../../application/delivery_providers.dart';
import 'token_qr_screen.dart';
import 'token_scan_screen.dart';

/// Everything the driver needs for one delivery, in one place — the full
/// invoice, the customer's address/phone/location, and whichever of the two
/// handoff actions applies right now: scan the restaurant's pickup QR
/// (stage `assigned`), or show the customer the delivery QR (stage
/// `picked_up`). See DeliveryDispatchService.
class DriverOrderDetailScreen extends ConsumerStatefulWidget {
  final PlacedOrder order;
  const DriverOrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<DriverOrderDetailScreen> createState() => _DriverOrderDetailScreenState();
}

class _DriverOrderDetailScreenState extends ConsumerState<DriverOrderDetailScreen> {
  late String? _stage = widget.order.deliveryStage;
  bool _busy = false;

  Future<void> _scanPickup() async {
    final l10n = AppLocalizations.of(context)!;
    final token = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => TokenScanScreen(title: l10n.deliveryScanPickupTitle, hint: l10n.deliveryScanPickupHint),
      ),
    );
    if (token == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(deliveryApiProvider).confirmPickup(token);
      if (mounted) {
        setState(() => _stage = 'picked_up');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deliveryPickupConfirmed)));
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showDeliveryQr() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final token = await ref.read(deliveryApiProvider).issueDeliveryToken(widget.order.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TokenQrScreen(
            title: l10n.deliveryDeliveryQrTitle,
            subtitle: l10n.deliveryDeliveryQrHint,
            token: token,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openMap() async {
    final order = widget.order;
    if (order.deliveryLat == null || order.deliveryLng == null) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${order.deliveryLat},${order.deliveryLng}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(title: Text('${order.businessName ?? ''} · #${order.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.deliveryCustomerSection, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (order.customerName != null) Text(order.customerName!),
          if (order.customerPhone != null) Text(order.customerPhone!),
          if (order.address != null) Text(order.address!),
          if (order.deliveryLat != null && order.deliveryLng != null) ...[
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: _openMap,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(l10n.deliveryOpenInMaps),
            ),
          ],
          const Divider(height: 32),
          Text(l10n.businessOrdersItemsSection, style: Theme.of(context).textTheme.titleSmall),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text('${item.qty}×'),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name)),
                  Text(item.totalPrice.toStringAsFixed(0)),
                ],
              ),
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.businessOrdersTotal, style: Theme.of(context).textTheme.titleSmall),
              Text(order.finalTotal.toStringAsFixed(0), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 24),
          if (_stage == 'assigned')
            FilledButton.icon(
              onPressed: _busy ? null : _scanPickup,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.deliveryScanPickupTitle),
            )
          else if (_stage == 'picked_up')
            FilledButton.icon(
              onPressed: _busy ? null : _showDeliveryQr,
              icon: const Icon(Icons.qr_code_2),
              label: Text(l10n.deliveryShowDeliveryQr),
            )
          else
            Text(l10n.deliveryCompleted, style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}
