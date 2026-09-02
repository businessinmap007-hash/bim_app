import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/disputes_providers.dart';
import '../../data/models/dispute.dart';
import 'disputes_screen.dart' show disputeStatusLabel;
import 'dispute_room_screen.dart';
import 'dispute_settlement_payments_screen.dart';

class DisputeDetailScreen extends ConsumerStatefulWidget {
  final int disputeId;
  const DisputeDetailScreen({super.key, required this.disputeId});

  @override
  ConsumerState<DisputeDetailScreen> createState() => _DisputeDetailScreenState();
}

class _DisputeDetailScreenState extends ConsumerState<DisputeDetailScreen> {
  bool _busy = false;

  void _showError(Object e) {
    final l10n = AppLocalizations.of(context)!;
    final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _act(Future<void> Function() action, {String? successMessage}) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(disputeDetailProvider(widget.disputeId));
      if (mounted && successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _settleObligation() async {
    final l10n = AppLocalizations.of(context)!;
    await _act(
      () => ref.read(disputesApiProvider).settleObligations(),
      successMessage: l10n.disputeObligationSettled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(disputeDetailProvider(widget.disputeId));

    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(disputeDetailProvider(widget.disputeId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (detail) {
        final d = detail.dispute;
        return Scaffold(
          appBar: AppBar(
            title: Text(d.counterparty?.name ?? '#${d.id}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DisputeRoomScreen(disputeId: d.id)),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(disputeStatusLabel(d.status, l10n), style: Theme.of(context).textTheme.titleSmall),
                      Text(d.isOpener ? l10n.disputeRoleOpener : l10n.disputeRoleRespondent),
                      if (d.reasonText != null && d.reasonText!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(d.reasonText!),
                      ],
                      if (d.counterparty != null) ...[
                        const SizedBox(height: 6),
                        Text('${l10n.disputeCounterpartyLabel}: ${d.counterparty!.name ?? ''}'),
                      ],
                      if (d.resolutionType == 'split' && d.resolution != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'client ${d.resolution!.clientPercent}% · business ${d.resolution!.businessPercent}%',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.disputeCooperationTitle, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _CooperationRow(
                label: l10n.disputeCooperationClientLabel,
                at: d.cooperation.clientAt,
                l10n: l10n,
              ),
              _CooperationRow(
                label: l10n.disputeCooperationBusinessLabel,
                at: d.cooperation.businessAt,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              if (detail.myObligations.isNotEmpty) ...[
                Text(l10n.disputeMyObligationsTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final o in detail.myObligations)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text('${o.type} — ${o.amount}')),
                        Text(o.status),
                      ],
                    ),
                  ),
                if (detail.myObligations.any((o) => o.status == 'pending')) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : _settleObligation,
                    child: Text(l10n.disputeSettleObligations),
                  ),
                ],
                const SizedBox(height: 16),
              ],
              if (d.status == 'mutual_resolution') ...[
                Text(
                  d.settlement.complete
                      ? l10n.disputeSettlementCompleteLabel
                      : l10n.disputeSettlementWaitingLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (d.canAct)
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _act(
                              () => ref.read(disputesApiProvider).cooperate(d.id),
                              successMessage: l10n.disputeCooperated,
                            ),
                      child: Text(l10n.disputeCooperate),
                    ),
                  if (d.status == 'mutual_resolution')
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DisputeSettlementPaymentsScreen(
                            disputeId: d.id,
                            mySide: detail.mySide,
                          ),
                        ),
                      ),
                      child: Text(l10n.disputeSettlementPaymentsTitle),
                    ),
                  if (d.status == 'mutual_resolution')
                    if (!_myAgreed(d, detail.mySide))
                      FilledButton(
                        onPressed: _busy
                            ? null
                            : () => _act(
                                () => ref.read(disputesApiProvider).agreeSettlement(d.id),
                                successMessage: l10n.disputeSettlementAgreed,
                              ),
                        child: Text(l10n.disputeAgreeSettlement),
                      )
                    else
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _act(
                                () => ref.read(disputesApiProvider).withdrawSettlement(d.id),
                                successMessage: l10n.disputeSettlementWithdrawn,
                              ),
                        child: Text(l10n.disputeWithdrawSettlement),
                      ),
                  if (d.status == 'mutual_resolution')
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _act(
                              () => ref.read(disputesApiProvider).requestArbitration(d.id),
                              successMessage: l10n.disputeArbitrationRequested,
                            ),
                      child: Text(
                        '${l10n.disputeRequestArbitration} '
                        '(${l10n.disputeArbitrationFeeLabel}: ${detail.arbitration.fee})',
                      ),
                    ),
                  if (d.isSettled && d.purge.purgedAt == null)
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _act(
                              () => ref.read(disputesApiProvider).confirmClosurePurge(d.id),
                              successMessage: l10n.disputeClosurePurged,
                            ),
                      child: Text(l10n.disputeClosePurgeAction),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool _myAgreed(Dispute d, String? mySide) {
    if (mySide == 'client') return d.settlement.clientAgreedAt != null;
    if (mySide == 'business') return d.settlement.businessAgreedAt != null;
    return false;
  }
}

class _CooperationRow extends StatelessWidget {
  final String label;
  final DateTime? at;
  final AppLocalizations l10n;
  const _CooperationRow({required this.label, required this.at, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(at != null ? _formatDate(at!) : l10n.disputeCooperationPending),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
