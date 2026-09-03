import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_training_providers.dart';
import '../../data/models/training_plan.dart';
import 'training_plan_manage_screen.dart';

/// Api\V2\TrainingPlanController::index — plans a trainer has already
/// assigned to clients. No "new plan" entry here: creating one needs a
/// client_id this app has no person-picker for (the same gap already
/// documented for TrainingTemplateController::apply) — a plan is created
/// elsewhere (admin, or a future picker) and managed here once it exists.
class MyTrainingClientsScreen extends ConsumerWidget {
  const MyTrainingClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myTrainingClientsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myTrainingClientsTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(myTrainingClientsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.trainingClientsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myTrainingClientsControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final plan = state.items[index];
                  return _PlanTile(plan: plan);
                },
              ),
            ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final TrainingPlan plan;
  const _PlanTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrainingPlanManageScreen(planId: plan.id)),
        ),
        title: Text(plan.clientName ?? '#${plan.clientId ?? plan.id}'),
        subtitle: Text(plan.title),
        trailing: Chip(
          label: Text(_statusLabel(l10n, plan.status)),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
    'active' => l10n.trainingPlanStatusActive,
    'paused' => l10n.trainingPlanStatusPaused,
    'completed' => l10n.trainingPlanStatusCompleted,
    'cancelled' => l10n.trainingPlanStatusCancelled,
    _ => status,
  };
}
