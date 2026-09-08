import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../wallet/presentation/widgets/wallet_pin_prompt.dart';
import '../../application/guarantee_providers.dart';
import '../../data/models/guarantee_level.dart';
import 'guarantee_transactions_screen.dart';

/// The caller's own buyer/seller-protection coverage — see
/// Api\V2\GuaranteeController. Activating locks money from the wallet as
/// collateral (never sent anywhere else); unlocking returns it. Ruling/usage
/// against the guarantee happens elsewhere (disputes) — this screen only
/// manages the coverage itself.
class GuaranteeScreen extends ConsumerStatefulWidget {
  const GuaranteeScreen({super.key});

  @override
  ConsumerState<GuaranteeScreen> createState() => _GuaranteeScreenState();
}

class _GuaranteeScreenState extends ConsumerState<GuaranteeScreen> {
  bool _busy = false;

  void _showError(Object e) {
    final l10n = AppLocalizations.of(context)!;
    final message = e is ApiException ? (e.firstErrorFor('pin') ?? e.message) : l10n.commonSomethingWentWrong;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _activate({int? levelId}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    await promptWalletPin(
      context,
      ref,
      action: (pin) async {
        final result = await ref.read(guaranteeApiProvider).activate(levelId: levelId, pin: pin);
        ref.invalidate(guaranteeMeProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.changed ? l10n.guaranteeActivated : l10n.guaranteeNoChange)),
          );
        }
      },
      onError: _showError,
    );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _unlock() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.guaranteeUnlockConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.guaranteeUnlock)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    await promptWalletPin(
      context,
      ref,
      action: (pin) async {
        await ref.read(guaranteeApiProvider).unlock(pin: pin);
        ref.invalidate(guaranteeMeProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.guaranteeUnlocked)));
        }
      },
      onError: _showError,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meAsync = ref.watch(guaranteeMeProvider);
    final levelsAsync = ref.watch(guaranteeLevelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.guaranteeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GuaranteeTransactionsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          meAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Column(
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(guaranteeMeProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
            data: (me) => _GuaranteeStatusCard(
              guarantee: me.guarantee,
              busy: _busy,
              onUnlock: _unlock,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.guaranteeLevelsTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : () => _activate(),
            child: Text(l10n.guaranteeAutoActivate),
          ),
          const SizedBox(height: 12),
          levelsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(l10n.commonSomethingWentWrong),
            data: (levels) => Column(
              children: [
                for (final level in levels) ...[
                  _LevelCard(
                    level: level,
                    currentLevelId: meAsync.valueOrNull?.guarantee?.purchasedLevel?.id,
                    busy: _busy,
                    onActivate: () => _activate(levelId: level.id),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuaranteeStatusCard extends StatelessWidget {
  final UserGuarantee? guarantee;
  final bool busy;
  final VoidCallback onUnlock;
  const _GuaranteeStatusCard({required this.guarantee, required this.busy, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final g = guarantee;

    if (g == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.guaranteeNoneYet),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(g.effectiveLevel?.displayName ?? g.status, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _stat(context, l10n.guaranteeLockedAmountLabel, '${g.lockedAmount}'),
                _stat(context, l10n.guaranteeCoverageLabel, '${g.currentCoverageAmount}'),
                _stat(context, l10n.guaranteeAvailableCoverageLabel, '${g.availableCoverageAmount}'),
                _stat(context, l10n.guaranteeUsedCoverageLabel, '${g.usedCoverageAmount}'),
                _stat(context, l10n.guaranteeTrustScoreLabel, '${g.trustScore}'),
                _stat(context, l10n.guaranteeCompletedOpsLabel, '${g.completedOperationsCount}'),
              ],
            ),
            if (g.lockedAmount > 0) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: busy ? null : onUnlock,
                child: Text(l10n.guaranteeUnlock),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GuaranteeLevel level;
  final int? currentLevelId;
  final bool busy;
  final VoidCallback onActivate;
  const _LevelCard({
    required this.level,
    required this.currentLevelId,
    required this.busy,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrent = currentLevelId == level.id;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(level.displayName, style: Theme.of(context).textTheme.titleSmall),
                ),
                if (isCurrent)
                  Chip(
                    label: Text(l10n.guaranteeCurrentLevelBadge),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${l10n.guaranteeRequiredLockedLabel}: ${level.requiredLockedAmount}'),
            Text('${l10n.guaranteeCoverageLabel}: ${level.activeCoverageAmount}'),
            if (!isCurrent) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: busy ? null : onActivate,
                child: Text(currentLevelId == null ? l10n.guaranteeActivate : l10n.guaranteeUpgrade),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
