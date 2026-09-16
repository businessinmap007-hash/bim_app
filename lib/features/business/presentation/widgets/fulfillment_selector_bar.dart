import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_page_providers.dart';
import '../../data/models/business_profile.dart';

/// The one entry point for delivery/pickup/dine-in — shown above the menu,
/// before the customer browses it, so it's picked once per visit instead of
/// being asked again at checkout (CheckoutScreen reads the same provider).
/// Only the methods this business actually ticked on its own "التسليم
/// والاستلام" options screen are shown (BusinessFulfillment, from
/// BusinessPageController::show); a business offering just one method never
/// has to be asked at all.
class FulfillmentSelectorBar extends ConsumerWidget {
  final int businessId;
  final BusinessFulfillment fulfillment;

  const FulfillmentSelectorBar({super.key, required this.businessId, required this.fulfillment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = fulfillment.selectionKeys;
    if (keys.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final selected = ref.watch(businessFulfillmentChoiceProvider(businessId)) ?? keys.first;

    // A single-method business has nothing to choose — settle it silently
    // instead of showing a one-chip row with no real decision in it.
    if (keys.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(businessFulfillmentChoiceProvider(businessId)) != keys.first) {
          ref.read(businessFulfillmentChoiceProvider(businessId).notifier).state = keys.first;
        }
      });
      return const SizedBox.shrink();
    }

    String labelFor(String key) {
      if (key == 'dine_in') return l10n.cartFulfillmentDineIn;

      final method = fulfillment.methods.where((m) => m.id.toString() == key).firstOrNull;

      return method?.label(locale) ?? key;
    }

    IconData iconFor(String key) => switch (fulfillment.typeOfSelection(key)) {
      'delivery' => Icons.delivery_dining_outlined,
      'pickup' => Icons.storefront_outlined,
      _ => Icons.restaurant_outlined,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.businessFulfillmentPrompt, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: keys
                .map(
                  (key) => ChoiceChip(
                    avatar: Icon(iconFor(key), size: 18),
                    label: Text(labelFor(key)),
                    selected: selected == key,
                    onSelected: (_) => ref.read(businessFulfillmentChoiceProvider(businessId).notifier).state = key,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
