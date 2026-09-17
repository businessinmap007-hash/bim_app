import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  double? _distanceKm;
  bool _calculatingDistance = false;

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

  Future<void> _calculateDistance() async {
    final order = widget.order;
    if (order.deliveryLat == null || order.deliveryLng == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _calculatingDistance = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.attendanceLocationRequired)));
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        order.deliveryLat!,
        order.deliveryLng!,
      );
      if (mounted) setState(() => _distanceKm = meters / 1000);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _calculatingDistance = false);
    }
  }

  Future<void> _sendEta() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<_EtaChoice>(
      context: context,
      builder: (context) => _EtaDialog(l10n: l10n),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(deliveryApiProvider)
          .notifyEta(widget.order.id, etaMinutes: result.minutes, etaAt: result.at);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deliveryEtaSent)));
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _openMap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(l10n.deliveryOpenInMaps),
                ),
                OutlinedButton.icon(
                  onPressed: _calculatingDistance ? null : _calculateDistance,
                  icon: _calculatingDistance
                      ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.social_distance_outlined, size: 18),
                  label: Text(
                    _distanceKm != null ? l10n.deliveryDistanceValue(_distanceKm!.toStringAsFixed(1)) : l10n.deliveryCalculateDistance,
                  ),
                ),
              ],
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
          if (_stage == 'assigned' || _stage == 'picked_up') ...[
            OutlinedButton.icon(
              onPressed: _busy ? null : _sendEta,
              icon: const Icon(Icons.schedule_send_outlined),
              label: Text(l10n.deliverySendEtaToCustomer),
            ),
            const SizedBox(height: 8),
          ],
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

class _EtaChoice {
  final int? minutes;
  final DateTime? at;
  const _EtaChoice.minutes(this.minutes) : at = null;
  const _EtaChoice.at(this.at) : minutes = null;
}

/// Lets the driver pick either "in N minutes" or a specific clock time —
/// never both, matching DeliveryDispatchService::notifyEta()'s own rule.
class _EtaDialog extends StatefulWidget {
  final AppLocalizations l10n;
  const _EtaDialog({required this.l10n});

  @override
  State<_EtaDialog> createState() => _EtaDialogState();
}

class _EtaDialogState extends State<_EtaDialog> {
  final _minutesController = TextEditingController();
  TimeOfDay? _pickedTime;

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _pickedTime = picked);
  }

  void _confirmMinutes() {
    final minutes = int.tryParse(_minutesController.text.trim());
    if (minutes == null || minutes <= 0) return;
    Navigator.of(context).pop(_EtaChoice.minutes(minutes));
  }

  void _confirmTime() {
    final time = _pickedTime;
    if (time == null) return;
    final now = DateTime.now();
    var at = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (at.isBefore(now)) at = at.add(const Duration(days: 1));
    Navigator.of(context).pop(_EtaChoice.at(at));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.deliveryEtaDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.deliveryEtaInMinutes),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _confirmMinutes, child: Text(l10n.commonOk)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.access_time),
            label: Text(_pickedTime == null ? l10n.deliveryEtaAtTime : _pickedTime!.format(context)),
          ),
          if (_pickedTime != null) ...[
            const SizedBox(height: 8),
            FilledButton(onPressed: _confirmTime, child: Text(l10n.commonOk)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
      ],
    );
  }
}
