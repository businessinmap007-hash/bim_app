import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/investigations_providers.dart';
import '../../data/models/investigation.dart';
import '../widgets/investigation_widgets.dart';
import 'investigation_order_detail_screen.dart';

/// «طلبات الفحوصات» — the caller's investigation orders as a patient: what the doctor ordered, where it was sent, and
/// the results when they are in.
class InvestigationOrdersScreen extends ConsumerWidget {
  const InvestigationOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myInvestigationOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invTitle)),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(myInvestigationOrdersProvider),
        builder: (context, orders) {
          if (orders.isEmpty) return Center(child: Text(l10n.invMyOrdersEmpty));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myInvestigationOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => InvestigationOrderCard(
                order: orders[i],
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => InvestigationOrderDetailScreen(orderId: orders[i].id)),
                  );
                  ref.invalidate(myInvestigationOrdersProvider);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One order in a list: who asked for it, when, what is in it, and where it stands.
class InvestigationOrderCard extends StatelessWidget {
  final InvestigationOrder order;
  final VoidCallback onTap;

  /// shown instead of the doctor — a centre sees the patient
  final String? title;

  const InvestigationOrderCard({super.key, required this.order, required this.onTap, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final names = order.items.map((i) => i.name).toList();
    final shown = names.take(3).join('، ');
    final more = names.length > 3 ? ' +${names.length - 3}' : '';
    final heading = title ?? (order.doctor != null ? l10n.invFromDoctor(order.doctor!.name) : l10n.invOwnRequest);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(heading, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                  InvestigationStatusPill(status: order.status),
                ],
              ),
              if (order.issuedAt != null)
                Text(formatInvestigationDate(context, order.issuedAt!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 8),
              Text('$shown$more', style: theme.textTheme.bodyMedium),
              if (order.total != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (order.center != null) Expanded(child: Text(order.center!.name, style: theme.textTheme.bodySmall)),
                    Text(
                      '${formatInvestigationMoney(order.total!)} ${l10n.invCurrency}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
