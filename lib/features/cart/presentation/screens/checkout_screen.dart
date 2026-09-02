import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../addresses/presentation/widgets/address_pick_sheet.dart';
import '../../application/cart_controller.dart';
import '../../data/models/cart_models.dart';

/// Fulfillment type + address/notes + payment method, then places the
/// order (POST /cart/{business}/checkout). Payment is cash-only for now —
/// the backend already accepts a gateway `payment_method`, but wiring an
/// actual payment sheet is a separate module.
class CheckoutScreen extends ConsumerStatefulWidget {
  final Cart cart;
  const CheckoutScreen({super.key, required this.cart});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _fulfillmentType = 'delivery';
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  int? _selectedAddressId;
  bool _submitting = false;

  Future<void> _pickAddress() async {
    final result = await showAddressPickSheet(context);
    if (result == null || !mounted) return;
    setState(() {
      _selectedAddressId = result.addressId;
      _addressController.text = result.label;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ref.read(cartControllerProvider.notifier).checkout(
        widget.cart.business!.id,
        fulfillmentType: _fulfillmentType,
        addressId: _fulfillmentType == 'delivery' ? _selectedAddressId : null,
        address: _fulfillmentType == 'delivery' && _selectedAddressId == null
            ? _addressController.text.trim()
            : null,
        notes: _notesController.text.trim(),
        paymentMethod: 'cash',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartOrderPlaced)));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cartCheckoutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.cartFulfillmentType, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'delivery', label: Text(l10n.cartFulfillmentDelivery)),
              ButtonSegment(value: 'pickup', label: Text(l10n.cartFulfillmentPickup)),
              ButtonSegment(value: 'dine_in', label: Text(l10n.cartFulfillmentDineIn)),
            ],
            selected: {_fulfillmentType},
            onSelectionChanged: (value) => setState(() => _fulfillmentType = value.first),
          ),
          if (_fulfillmentType == 'delivery') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.cartAddressLabel,
                hintText: l10n.cartAddressHint,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on_outlined),
                  onPressed: _pickAddress,
                ),
              ),
              maxLines: 2,
              onChanged: (_) {
                if (_selectedAddressId != null) setState(() => _selectedAddressId = null);
              },
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: l10n.cartNotesLabel),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text(l10n.cartPaymentMethod, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(l10n.cartPaymentCash, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.cartFinalTotal, style: Theme.of(context).textTheme.titleMedium),
              Text(widget.cart.finalTotal.toStringAsFixed(0), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _placeOrder,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.cartPlaceOrder),
          ),
        ],
      ),
    );
  }
}
