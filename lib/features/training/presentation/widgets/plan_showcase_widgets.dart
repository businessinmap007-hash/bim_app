import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../projects/data/models/project_showcase.dart';
import '../../../projects/presentation/widgets/project_agreement_widgets.dart';
import '../../application/showcase_providers.dart';
import '../../application/training_providers.dart';

String _msg(Object e, AppLocalizations l10n) => e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;

String _kindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'training' => l10n.showcaseKindTraining,
  'nutrition' => l10n.showcaseKindNutrition,
  _ => l10n.showcaseKindCombined,
};

/// «+٢٫٥» for a change, with the sign forced — shown left-to-right so the sign stays where it belongs in Arabic text.
Widget _signed(BuildContext context, double v, String unit, {bool lowerIsBetter = false}) {
  final good = lowerIsBetter ? v < 0 : v > 0;
  final text = '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} $unit';

  return Directionality(
    textDirection: TextDirection.ltr,
    child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: v == 0 ? null : (good ? AppColors.success : AppColors.error))),
  );
}

/// «موثَّق من العميل» for a plan: how long it ran, how many months the client confirmed, and how far each measure moved since
/// the first confirmed reading — changes only, no name, no weight, no photo.
class PlanResultsCard extends StatelessWidget {
  final PlanShowcasePost showcase;

  const PlanResultsCard({super.key, required this.showcase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total = showcase.totalChange;

    Widget row(String label, String key, String unit, {bool lowerIsBetter = false}) {
      final v = total[key];
      if (v == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [Expanded(child: Text(label)), _signed(context, v, unit, lowerIsBetter: lowerIsBetter)]),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.07),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 18, color: AppColors.success),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.showcaseVerifiedBadge, style: theme.textTheme.labelLarge?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700))),
              Text(_kindLabel(l10n, showcase.kind), style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (showcase.weeks != null) l10n.showcaseWeeks(showcase.weeks!),
              l10n.showcaseConfirmedMonths(showcase.confirmedMonths),
            ].join(' · '),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          if (total.isEmpty)
            Text(l10n.showcaseNoConfirmedYet, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))
          else ...[
            row(l10n.bodyReportWeight, 'weight_kg', 'kg', lowerIsBetter: true),
            row(l10n.bodyReportFat, 'fat_percent', '%', lowerIsBetter: true),
            row(l10n.bodyReportMuscle, 'muscle_mass_kg', 'kg'),
            row(l10n.bodyReportWater, 'water_percent', '%'),
          ],
          if (showcase.updatedOn != null) ...[
            const SizedBox(height: 6),
            Text(l10n.showcaseUpdatedOn(projectDate(context, showcase.updatedOn)), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
        ],
      ),
    );
  }
}

/// The trainer's side: ask the client to let the plan's results be shown (no photos, ever), see where it stands, take it down.
class TrainerPlanShowcaseCard extends ConsumerWidget {
  final int planId;
  final String planTitle;

  const TrainerPlanShowcaseCard({super.key, required this.planId, required this.planTitle});

  Future<void> _ask(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final title = TextEditingController();
    final note = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.showcaseAskTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.planShowcaseAskHint, style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 8),
              TextField(controller: title, decoration: InputDecoration(labelText: l10n.showcasePublicTitle)),
              TextField(controller: note, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: l10n.showcaseNote)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSubmit)),
        ],
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;

    try {
      final made = await ref.read(showcaseApiProvider).requestShowcase(planId, publicTitle: title.text.trim(), note: note.text.trim());
      ref.invalidate(planShowcaseProvider(planId));
      messenger.showSnackBar(SnackBar(content: Text(made?.isLive == true ? l10n.showcaseLiveGeneral : l10n.showcaseRequestSent)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_msg(e, l10n))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(planShowcaseProvider(planId));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (s) {
        if (s == null || s.canAsk) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s != null)
                Text(
                  s.status == 'declined' ? l10n.showcaseDeclined((s.decisionNote ?? '').isEmpty ? '—' : s.decisionNote!) : l10n.showcaseWithdrawn,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              OutlinedButton.icon(icon: const Icon(Icons.campaign_outlined), onPressed: () => _ask(context, ref), label: Text(l10n.planShowcaseAskAction)),
            ],
          );
        }

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.publicTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  s.isLive ? (s.viaGeneral ? l10n.showcaseLiveGeneral : l10n.showcaseLive) : l10n.showcaseWaiting,
                  style: TextStyle(color: s.isLive ? AppColors.success : AppColors.accentGold, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(showcaseApiProvider).trainerWithdraw(planId);
                    ref.invalidate(planShowcaseProvider(planId));
                  },
                  child: Text(s.isLive ? l10n.showcaseTakeDown : l10n.showcaseCancelRequest),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The client's side: the trainer asks to show the plan's results (anonymous changes, no photo) — he answers, and once live he
/// can take it down any time.
class ClientPlanShowcaseCard extends ConsumerWidget {
  final int planId;
  final ShowcaseRequest request;

  const ClientPlanShowcaseCard({super.key, required this.planId, required this.request});

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await action();
      ref.invalidate(trainingPlanDetailProvider(planId));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_msg(e, l10n))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(showcaseApiProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.isLive ? l10n.planShowcaseConsentLive : l10n.planShowcaseConsentTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(request.publicTitle, style: Theme.of(context).textTheme.bodyLarge),
            if ((request.note ?? '').isNotEmpty) Text(request.note!),
            const SizedBox(height: 4),
            Text(request.viaGeneral && request.isLive ? l10n.showcaseUnderGeneralConsent : l10n.planShowcaseConsentBody, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (request.isRequested) ...[
                  FilledButton(onPressed: () => _run(context, ref, () => api.decide(planId, approve: true)), child: Text(l10n.showcaseConsentAgree)),
                  OutlinedButton(
                    onPressed: () async {
                      final note = await askText(context, title: l10n.showcaseConsentDecline, hint: l10n.showcaseConsentDeclineHint, required: false);
                      if (note == null || !context.mounted) return;
                      await _run(context, ref, () => api.decide(planId, approve: false, note: note));
                    },
                    child: Text(l10n.showcaseConsentDecline),
                  ),
                ] else
                  OutlinedButton(onPressed: () => _run(context, ref, () => api.clientWithdraw(planId)), child: Text(l10n.showcaseTakeDown)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
