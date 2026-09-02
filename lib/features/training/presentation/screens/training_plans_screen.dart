import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/training_providers.dart';
import '../../data/models/training_plan.dart';
import 'training_plan_detail_screen.dart';

class TrainingPlansScreen extends ConsumerStatefulWidget {
  const TrainingPlansScreen({super.key});

  @override
  ConsumerState<TrainingPlansScreen> createState() => _TrainingPlansScreenState();
}

class _TrainingPlansScreenState extends ConsumerState<TrainingPlansScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(myTrainingPlansControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myTrainingPlansControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingPlansTitle)),
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
                    onPressed: () => ref.read(myTrainingPlansControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.trainingPlansEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myTrainingPlansControllerProvider.notifier).load(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final plan = state.items[index];
                  return _PlanTile(
                    plan: plan,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TrainingPlanDetailScreen(planId: plan.id)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final TrainingPlan plan;
  final VoidCallback onTap;
  const _PlanTile({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: plan.trainerLogoUrl != null ? NetworkImage(plan.trainerLogoUrl!) : null,
          child: plan.trainerLogoUrl == null ? const Icon(Icons.fitness_center_outlined) : null,
        ),
        title: Text(plan.title),
        subtitle: Text(
          '${plan.trainerName ?? ''}'
          '${plan.goal != null && plan.goal!.isNotEmpty ? ' · ${plan.goal}' : ''}\n'
          '${_statusLabel(plan.status, l10n)}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'active' => l10n.trainingStatusActive,
  'paused' => l10n.trainingStatusPaused,
  'completed' => l10n.trainingStatusCompleted,
  'cancelled' => l10n.trainingStatusCancelled,
  _ => status,
};
