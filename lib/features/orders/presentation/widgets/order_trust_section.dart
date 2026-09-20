import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/placed_order.dart';

/// "I trust" checkboxes toward the other parties of an order (merchant,
/// driver, customer). [onToggle] performs the call and returns the saved
/// value. Hidden on list rows and orders with no other party yet.
class OrderTrustSection extends StatefulWidget {
  final PlacedOrder order;
  final Future<bool> Function(String party, bool trusted) onToggle;
  const OrderTrustSection({super.key, required this.order, required this.onToggle});

  @override
  State<OrderTrustSection> createState() => _OrderTrustSectionState();
}

class _OrderTrustSectionState extends State<OrderTrustSection> {
  late final Map<String, bool> _mine = {
    for (final e in (widget.order.trust ?? const {}).entries) e.key: e.value.trustedByMe,
  };
  final Set<String> _busy = {};

  Future<void> _toggle(String party, bool value) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy.add(party));
    try {
      final saved = await widget.onToggle(party, value);
      if (mounted) setState(() => _mine[party] = saved);
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? (e.firstErrorFor('phone') ?? e.message) : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(party));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trust = widget.order.trust;
    if (trust == null || trust.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    String label(String party) => switch (party) {
      'customer' => l10n.trustCustomer,
      'business' => l10n.trustBusiness,
      _ => l10n.trustDriver,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Text(l10n.trustSectionTitle, style: Theme.of(context).textTheme.titleSmall),
        for (final entry in trust.entries)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(label(entry.key)),
            subtitle: entry.value.trustsMe ? Text(l10n.trustsYouNote) : null,
            value: _mine[entry.key] ?? false,
            onChanged: _busy.contains(entry.key) ? null : (v) => _toggle(entry.key, v ?? false),
          ),
      ],
    );
  }
}
