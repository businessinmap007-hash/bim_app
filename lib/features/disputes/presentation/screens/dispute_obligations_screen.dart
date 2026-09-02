import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/disputes_providers.dart';
import '../../data/models/dispute.dart';

/// What rulings across ALL my disputes decided I owe (or am owed), and the
/// "pay to unblock" action — settles from my own wallet balance only, never
/// a third-party transfer. See DisputeObligationController.
class DisputeObligationsScreen extends ConsumerStatefulWidget {
  const DisputeObligationsScreen({super.key});

  @override
  ConsumerState<DisputeObligationsScreen> createState() => _DisputeObligationsScreenState();
}

class _DisputeObligationsScreenState extends ConsumerState<DisputeObligationsScreen> {
  bool _settling = false;

  Future<void> _settle() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _settling = true);
    try {
      await ref.read(disputesApiProvider).settleObligations();
      ref.invalidate(disputeObligationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.disputeObligationSettled)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _settling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(disputeObligationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.disputeObligationsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(disputeObligationsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (summary) {
          if (summary.owedByMe.isEmpty && summary.owedToMe.isEmpty) {
            return Center(child: Text(l10n.disputeObligationsEmpty));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (summary.owedByMe.isNotEmpty) ...[
                Text(l10n.disputeOwedByMeTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final o in summary.owedByMe) ...[_ObligationTile(obligation: o), const SizedBox(height: 6)],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _settling ? null : _settle,
                  child: _settling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.disputeSettleObligations),
                ),
                const SizedBox(height: 20),
              ],
              if (summary.owedToMe.isNotEmpty) ...[
                Text(l10n.disputeOwedToMeTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final o in summary.owedToMe) ...[_ObligationTile(obligation: o), const SizedBox(height: 6)],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ObligationTile extends StatelessWidget {
  final DisputeObligation obligation;
  const _ObligationTile({required this.obligation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text('${obligation.amount}'),
        subtitle: Text('${obligation.type} · #${obligation.disputeId}'),
        trailing: Text(obligation.status),
      ),
    );
  }
}
