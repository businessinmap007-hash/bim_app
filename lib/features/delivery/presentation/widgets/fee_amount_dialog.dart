import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Asks the courier for the delivery fee of one out-of-city order. Returns the
/// amount, or null when cancelled / not a valid number.
Future<double?> askDeliveryFeeAmount(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  final text = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deliveryQuoteEnterAmountTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.deliveryQuoteAmountLabel),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(l10n.deliveryQuoteSend)),
      ],
    ),
  );

  final amount = text == null ? null : double.tryParse(text);
  return (amount == null || amount < 0) ? null : amount;
}
