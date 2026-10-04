import 'package:flutter/material.dart';

import '../../data/models/placed_order.dart';

/// «سمك 450 / الطهى مشوى 150» — a line's services as their own rows of the invoice, each with what it adds
/// for THAT weight. Nothing for a line without services.
class OrderLineServices extends StatelessWidget {
  final OrderLineItem item;
  final int decimals;
  const OrderLineServices({super.key, required this.item, this.decimals = 0});

  @override
  Widget build(BuildContext context) {
    if (item.services.isEmpty || item.isRemoved) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(color: theme.hintColor);

    return Column(
      children: [
        for (final s in item.services)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, top: 2),
            child: Row(
              children: [
                Expanded(child: Text(s.name, style: style)),
                Text(s.total.toStringAsFixed(decimals), style: style),
              ],
            ),
          ),
      ],
    );
  }
}
