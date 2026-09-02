import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/ratings_providers.dart';
import '../../data/models/my_rating.dart';

/// GET/POST /ratings/me, /ratings/enable — the objective operation record,
/// subjective star average, and the fee-consent status a guarantee purchase
/// or an escrow deposit would otherwise open silently. This is the only
/// place a user can see that status or open it themselves without going
/// through either of those flows.
class MyRatingScreen extends ConsumerWidget {
  const MyRatingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myRatingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myRatingTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.read(myRatingControllerProvider.notifier).load(),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (myRating) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(l10n.myRatingObjectiveSection),
            const SizedBox(height: 8),
            _StatsCard(rating: myRating.rating, l10n: l10n),
            const SizedBox(height: 24),
            _SectionHeader(l10n.myRatingReviewsSection),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accentGold),
                        const SizedBox(width: 6),
                        Text(
                          myRating.rating.starsAverage.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Text(l10n.myRatingReviewCount(myRating.rating.reviewCount)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(l10n.myRatingConsentSection),
            const SizedBox(height: 8),
            _ConsentCard(myRating: myRating),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final RatingSummary rating;
  final AppLocalizations l10n;
  const _StatsCard({required this.rating, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(label: l10n.myRatingTotalOperations, value: '${rating.totalOperations}'),
            _StatRow(label: l10n.myRatingSuccessRate, value: _pct(rating.successRate)),
            _StatRow(label: l10n.myRatingCancelRate, value: _pct(rating.cancelRate)),
            _StatRow(label: l10n.myRatingDisputeRate, value: _pct(rating.disputeRate)),
            if (rating.disputedCount > 0) ...[
              _StatRow(label: l10n.myRatingFaultRate, value: _pct(rating.faultRate)),
              _StatRow(label: l10n.myRatingVindicationRate, value: _pct(rating.vindicationRate)),
            ],
          ],
        ),
      ),
    );
  }

  String _pct(double rate) => '${rate.toStringAsFixed(0)}%';
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ConsentCard extends ConsumerStatefulWidget {
  final MyRating myRating;
  const _ConsentCard({required this.myRating});

  @override
  ConsumerState<_ConsentCard> createState() => _ConsentCardState();
}

class _ConsentCardState extends ConsumerState<_ConsentCard> {
  bool _enabling = false;

  Future<void> _confirmAndEnable() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myRatingEnableConfirmTitle),
        content: Text(l10n.myRatingEnableConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.myRatingEnableConfirm)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _enabling = true);
    try {
      await ref.read(myRatingControllerProvider.notifier).enable();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.myRatingEnabledMessage)));
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _enabling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = widget.myRating.ratingEnabled;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  enabled ? Icons.check_circle_outline : Icons.lock_outline,
                  color: enabled ? AppColors.success : Theme.of(context).hintColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    enabled ? l10n.myRatingConsentEnabledLabel : l10n.myRatingConsentDisabledLabel,
                  ),
                ),
              ],
            ),
            if (!enabled) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: _enabling ? null : _confirmAndEnable,
                  child: _enabling
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.myRatingEnableButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall);
  }
}
