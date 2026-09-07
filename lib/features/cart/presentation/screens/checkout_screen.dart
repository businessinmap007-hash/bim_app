import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../addresses/presentation/widgets/address_pick_sheet.dart';
import '../../../business/application/business_page_providers.dart';
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
  // Null until the user overrides it here; the effective value (`build`'s
  // `selected`) falls back to the choice already made above the menu, so
  // there is nothing to reconcile between what the segmented button shows
  // and what _placeOrder actually submits.
  String? _fulfillmentTypeOverride;
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

  Future<void> _placeOrder(String fulfillmentType) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ref.read(cartControllerProvider.notifier).checkout(
        widget.cart.business!.id,
        fulfillmentType: fulfillmentType,
        addressId: fulfillmentType == 'delivery' ? _selectedAddressId : null,
        address: fulfillmentType == 'delivery' && _selectedAddressId == null
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

    // The business page already filtered this to what the business actually
    // offers (BusinessPageController::show → BusinessFulfillment) — reusing
    // that same cached profile here keeps checkout from ever offering a
    // method (e.g. dine-in with no table) the business never advertised.
    // Falls back to all three only if the profile somehow isn't cached yet.
    final businessId = widget.cart.business?.id;
    final available =
        (businessId != null ? ref.watch(businessProfileProvider(businessId)).valueOrNull?.fulfillment.available : null) ??
        const ['delivery', 'pickup', 'dine_in'];
    // Preference order: the user's own tap here > the choice already made
    // above the menu > whatever the business offers first — always clamped
    // to what this business actually supports.
    final preferred =
        _fulfillmentTypeOverride ?? (businessId != null ? ref.watch(businessFulfillmentChoiceProvider(businessId)) : null);
    final selected = (preferred != null && available.contains(preferred)) ? preferred : available.first;

    String labelFor(String method) => switch (method) {
      'delivery' => l10n.cartFulfillmentDelivery,
      'pickup' => l10n.cartFulfillmentPickup,
      _ => l10n.cartFulfillmentDineIn,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cartCheckoutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.cartFulfillmentType, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: available.map((m) => ButtonSegment(value: m, label: Text(labelFor(m)))).toList(),
            selected: {selected},
            onSelectionChanged: (value) => setState(() => _fulfillmentTypeOverride = value.first),
          ),
          if (selected == 'delivery') ...[
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
            onPressed: _submitting ? null : () => _placeOrder(selected),
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.cartPlaceOrder),
          ),
        ],
      ),
    );
  }
}
