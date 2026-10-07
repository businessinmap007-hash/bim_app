import '../../../../shared/widgets/app_bar_tab_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_orders_providers.dart';
import '../../application/orders_providers.dart';
import '../../data/models/order_reports.dart';

/// Standalone analytics screen for a business's own orders -- separate from
/// the live "Incoming orders" queue (BusinessOrdersScreen), which stays a
/// day-to-day worklist. This is date-range aggregates + charts, nothing a
/// merchant needs to act on row by row.
class BusinessOrderReportsScreen extends ConsumerStatefulWidget {
  const BusinessOrderReportsScreen({super.key});

  @override
  ConsumerState<BusinessOrderReportsScreen> createState() => _BusinessOrderReportsScreenState();
}

class _BusinessOrderReportsScreenState extends ConsumerState<BusinessOrderReportsScreen> {
  int _rangeDays = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessOrderReportsControllerProvider);
    final reports = state.reports;

    // A business that sells on instalments gets the two views on one page; one
    // that is cash only keeps the single page it always had.
    if (reports != null && reports.hasInstallments) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.businessReportsTitle),
            bottom: AppBarTabBar(tabs: [Tab(text: l10n.businessReportsTabCash), Tab(text: l10n.businessReportsTabInstallments)]),
          ),
          body: TabBarView(
            children: [
              _cashView(l10n, state),
              RefreshIndicator(
                onRefresh: () => ref.read(businessOrderReportsControllerProvider.notifier).load(),
                child: _InstallmentsView(report: reports.installments!),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(appBar: AppBar(title: Text(l10n.businessReportsTitle)), body: _cashView(l10n, state));
  }

  Widget _cashView(AppLocalizations l10n, BusinessOrderReportsState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(businessOrderReportsControllerProvider.notifier).load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              for (final days in [7, 30, 90])
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(switch (days) {
                      7 => l10n.businessReportsRange7d,
                      90 => l10n.businessReportsRange90d,
                      _ => l10n.businessReportsRange30d,
                    }),
                    selected: _rangeDays == days,
                    onSelected: (_) {
                      setState(() => _rangeDays = days);
                      ref.read(businessOrderReportsControllerProvider.notifier).setRangeDays(days);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.isLoading && state.reports == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.reports == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.commonSomethingWentWrong),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => ref.read(businessOrderReportsControllerProvider.notifier).load(),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
            )
          else if (state.reports != null)
            _ReportsBody(
              reports: state.reports!,
              // With instalments on the side, THIS view counts only what was paid in one go.
              summary: state.reports!.cash?.summary ?? state.reports!.summary,
              daily: state.reports!.cash?.daily ?? state.reports!.daily,
              showFulfillment: !state.reports!.hasInstallments,
            ),
        ],
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  final OrderReports reports;
  final OrderReportsSummary summary;
  final List<OrderReportsDailyPoint> daily;
  final bool showFulfillment;
  const _ReportsBody({required this.reports, required this.summary, required this.daily, required this.showFulfillment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (summary.totalOrders == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text(l10n.businessReportsEmpty)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.extent(
          maxCrossAxisExtent: 240,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            _StatCard(label: l10n.businessReportsTotalOrders, value: '${summary.totalOrders}'),
            _StatCard(
              label: l10n.businessReportsTotalRevenue,
              value: summary.totalRevenue.toStringAsFixed(0),
              color: AppColors.accentGold,
            ),
            _StatCard(
              label: l10n.businessReportsCompleted,
              value: '${summary.completedOrders}',
              color: AppColors.success,
            ),
            _StatCard(
              label: l10n.businessReportsCancelled,
              value: '${summary.cancelledOrders}',
              color: AppColors.error,
            ),
            _StatCard(label: l10n.businessReportsPending, value: '${summary.pendingOrders}'),
            _StatCard(
              label: l10n.businessReportsAverageOrderValue,
              value: summary.averageOrderValue.toStringAsFixed(0),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l10n.businessReportsDailyOrdersChartTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(height: 160, child: _DailyBarChart(daily: daily, useRevenue: false)),
        const SizedBox(height: 24),
        Text(l10n.businessReportsDailyRevenueChartTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(height: 160, child: _DailyBarChart(daily: daily, useRevenue: true)),
        if (showFulfillment) ...[
          const SizedBox(height: 24),
          Text(l10n.businessReportsByFulfillmentType, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          _FulfillmentTypeBars(reports: reports),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  final List<OrderReportsDailyPoint> daily;
  final bool useRevenue;
  const _DailyBarChart({required this.daily, required this.useRevenue});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final values = daily.map((d) => useRevenue ? d.revenue : d.ordersCount.toDouble()).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    // A flat/empty range would otherwise divide the chart's y-axis by zero.
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    // Beyond ~14 bars a full date label per bar overlaps; thin them out
    // instead of shrinking text past legibility.
    final labelStride = (daily.length / 7).ceil().clamp(1, daily.length);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: [
          for (var i = 0; i < daily.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: AppColors.accentGold,
                  width: daily.length > 20 ? 4 : 10,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
        ],
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= daily.length || i % labelStride != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(DateFormat('d/M').format(daily[i].date), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${DateFormat('d/M').format(daily[group.x].date)}\n${useRevenue ? rod.toY.toStringAsFixed(0) : rod.toY.toInt()}',
              const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }
}

class _FulfillmentTypeBars extends StatelessWidget {
  final OrderReports reports;
  const _FulfillmentTypeBars({required this.reports});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = reports.deliveryCount + reports.pickupCount + reports.dineInCount;
    if (total == 0) return const SizedBox.shrink();

    final rows = [
      (l10n.cartFulfillmentDelivery, reports.deliveryCount),
      (l10n.cartFulfillmentPickup, reports.pickupCount),
      (l10n.cartFulfillmentDineIn, reports.dineInCount),
    ];

    return Column(
      children: [
        for (final (label, count) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(width: 70, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: count / total,
                      minHeight: 10,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation(AppColors.accentGold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 28, child: Text('$count', textAlign: TextAlign.end)),
              ],
            ),
          ),
      ],
    );
  }
}

/// «تقسيط»: what the business is owed, what it has collected, and the payments still to
/// collect by date — each one can be recorded as collected from the order it belongs to.
class _InstallmentsView extends ConsumerWidget {
  final InstallmentReport report;
  const _InstallmentsView({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.extent(
          maxCrossAxisExtent: 240,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            _StatCard(label: l10n.businessReportsInstOrders, value: '${report.ordersCount}'),
            _StatCard(
              label: l10n.businessReportsInstContractTotal,
              value: report.contractTotal.toStringAsFixed(0),
              color: AppColors.accentGold,
            ),
            _StatCard(
              label: l10n.businessReportsInstCollected,
              value: report.collected.toStringAsFixed(0),
              color: AppColors.success,
            ),
            _StatCard(label: l10n.businessReportsInstRemaining, value: report.remaining.toStringAsFixed(0)),
            if (report.overdue > 0)
              _StatCard(
                label: l10n.businessReportsInstOverdue,
                value: report.overdue.toStringAsFixed(0),
                color: AppColors.error,
              ),
          ],
        ),
        if (report.byMonth.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.businessReportsInstByMonth, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final m in report.byMonth)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat.yMMMM(locale).format(DateTime.parse('${m.month}-01')),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(l10n.businessReportsInstPayments(m.count), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 12),
                  Text(m.amount.toStringAsFixed(0), style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
        ],
        const SizedBox(height: 24),
        Text(l10n.businessReportsInstUpcoming, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (report.upcoming.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(l10n.businessReportsInstNone)),
          )
        else
          for (final d in report.upcoming)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  '${d.dueOn.toIso8601String().substring(0, 10)} · ${d.customer}',
                  style: d.overdue ? TextStyle(color: AppColors.error) : null,
                ),
                subtitle: Text(l10n.businessReportsInstLine(d.seq, d.count, d.orderId)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(d.amount.toStringAsFixed(0), style: Theme.of(context).textTheme.titleSmall),
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref.read(ordersApiProvider).collectInstallment(d.orderId, d.seq, paid: true);
                          await ref.read(businessOrderReportsControllerProvider.notifier).load();
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
                          }
                        }
                      },
                      child: Text(l10n.ordersInstallmentCollect),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
