import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import 'common.dart';

/// «لوحة اليوم» — the stock value, what is below its reorder level or short today, open orders, this month's waste,
/// and the last moves from every computer and from the apps' orders.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final data = ref.watch(invDashboardProvider);

    return SuitePage(
      title: l10n.suiteNavDashboard,
      actions: [IconButton(onPressed: () => ref.invalidate(invDashboardProvider), icon: const Icon(Icons.refresh))],
      child: AsyncValueView<InvDashboard>(
        value: data,
        onRetry: () => ref.invalidate(invDashboardProvider),
        builder: (context, d) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // one height for the four, whatever each one's text
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SuiteStat(label: l10n.stkStockValue, value: '${InvLabels.money(d.summary.stockValue)} ${l10n.stkCurrency}', sub: l10n.suiteAtAverageCost),
                  ),
                  Expanded(
                    child: SuiteStat(label: l10n.stkBelowReorder, value: '${d.summary.belowReorder}', color: d.summary.belowReorder > 0 ? Tone.bad(context) : null),
                  ),
                  Expanded(
                    child: SuiteStat(label: l10n.suiteOpenOrders, value: '${d.summary.openPurchaseOrders}'),
                  ),
                  Expanded(
                    child: SuiteStat(label: l10n.suiteWasteMonth, value: '${InvLabels.money(d.summary.wasteThisMonth)} ${l10n.stkCurrency}', color: Tone.warn(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SuiteSection(
                    title: l10n.suiteNeedsAttention,
                    child: d.low.isEmpty
                        ? Text(l10n.suiteAllCovered)
                        : DataTable(
                            columns: [
                              DataColumn(label: Text(l10n.suiteItem)),
                              DataColumn(label: Text(l10n.suiteOnHand)),
                              DataColumn(label: Text(l10n.suiteDaysLeft)),
                              DataColumn(label: Text(l10n.stkCoversToday)),
                            ],
                            rows: [
                              for (final r in d.low)
                                DataRow(
                                  cells: [
                                    DataCell(Text(r.name)),
                                    DataCell(Text('${invNum(r.onHand)} ${r.baseUnit}')),
                                    DataCell(Text(r.daysLeft == null ? '—' : invNum(r.daysLeft!))),
                                    DataCell(
                                      Text(
                                        InvLabels.verdict(l10n, r.verdict),
                                        style: TextStyle(color: InvLabels.verdictColors(r.verdict).$2, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SuiteSection(
                    title: l10n.stkRecentMoves,
                    child: Column(
                      children: [
                        for (final m in d.recentMoves)
                          ListTile(
                            dense: true,
                            title: Text('${InvLabels.moveType(l10n, m.type)} — ${m.itemName ?? ''}'),
                            subtitle: Text(m.occurredAt == null ? '' : '${MaterialLocalizations.of(context).formatShortDate(m.occurredAt!)} ${TimeOfDay.fromDateTime(m.occurredAt!).format(context)}'),
                            trailing: Text(
                              '${m.qty > 0 ? '+' : ''}${invNum(m.qty)}',
                              style: TextStyle(fontWeight: FontWeight.w800, color: m.qty >= 0 ? Tone.good(context) : Tone.bad(context)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
