import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/investigations_providers.dart';
import 'investigation_order_detail_screen.dart';
import 'investigation_orders_screen.dart' show InvestigationOrderCard;

/// The tests and exams a doctor ordered — all of them, or one patient's — with their results as they come in, so the
/// doctor reads them on their own device the moment the patient is in front of them.
class IssuedInvestigationsScreen extends ConsumerWidget {
  /// only this patient's orders (from an appointment); null = every order the doctor issued
  final int? patientId;
  final String? patientName;
  const IssuedInvestigationsScreen({super.key, this.patientId, this.patientName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(issuedInvestigationOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(patientName == null ? l10n.invIssuedTitle : l10n.invIssuedFor(patientName!))),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(issuedInvestigationOrdersProvider),
        builder: (context, all) {
          final orders = patientId == null ? all : all.where((o) => o.patient?.id == patientId).toList();
          if (orders.isEmpty) return Center(child: Text(l10n.invIssuedEmpty));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(issuedInvestigationOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => InvestigationOrderCard(
                order: orders[i],
                title: orders[i].patient?.name,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => InvestigationOrderDetailScreen(orderId: orders[i].id)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
