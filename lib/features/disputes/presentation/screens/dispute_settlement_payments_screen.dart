import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/disputes_providers.dart';
import '../../data/models/dispute_settlement.dart';

/// "A payment settled off the platform" — the app never moves this money,
/// it only records propose → accept → the RECEIVER's confirmation, which is
/// the statement that actually ends the dispute (see DisputeController's
/// settlementPayments doc comment).
class DisputeSettlementPaymentsScreen extends ConsumerStatefulWidget {
  final int disputeId;
  final String? mySide;
  const DisputeSettlementPaymentsScreen({super.key, required this.disputeId, this.mySide});

  @override
  ConsumerState<DisputeSettlementPaymentsScreen> createState() => _DisputeSettlementPaymentsScreenState();
}

class _DisputeSettlementPaymentsScreenState extends ConsumerState<DisputeSettlementPaymentsScreen> {
  final _amountController = TextEditingController();
  final _methodController = TextEditingController();
  final _noteController = TextEditingController();
  String _payerSide = 'client';
  bool _busy = false;

  @override
  void dispose() {
    _amountController.dispose();
    _methodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    final l10n = AppLocalizations.of(context)!;
    final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _propose() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(disputesApiProvider).proposeSettlementPayment(
        widget.disputeId,
        payerSide: _payerSide,
        amount: amount,
        method: _methodController.text.trim(),
        note: _noteController.text.trim(),
      );
      _amountController.clear();
      _methodController.clear();
      _noteController.clear();
      ref.invalidate(settlementPaymentsProvider(widget.disputeId));
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _act(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(settlementPaymentsProvider(widget.disputeId));
      ref.invalidate(disputeDetailProvider(widget.disputeId));
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(settlementPaymentsProvider(widget.disputeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.disputeSettlementPaymentsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(settlementPaymentsProvider(widget.disputeId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (page) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (page.current != null) ...[
              _ProposalCard(
                proposal: page.current!,
                mySide: widget.mySide,
                busy: _busy,
                onAccept: () => _act(
                  () => ref
                      .read(disputesApiProvider)
                      .acceptSettlementPayment(widget.disputeId, page.current!.id),
                ),
                onReject: () => _act(
                  () => ref
                      .read(disputesApiProvider)
                      .rejectSettlementPayment(widget.disputeId, page.current!.id),
                ),
                onConfirmReceived: () => _act(
                  () => ref
                      .read(disputesApiProvider)
                      .confirmSettlementReceived(widget.disputeId, page.current!.id),
                ),
                onWithdraw: () => _act(
                  () => ref
                      .read(disputesApiProvider)
                      .withdrawSettlementPayment(widget.disputeId, page.current!.id),
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.disputeProposePayment, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'client', label: Text(l10n.disputePayerClient)),
                          ButtonSegment(value: 'business', label: Text(l10n.disputePayerBusiness)),
                        ],
                        selected: {_payerSide},
                        onSelectionChanged: (s) => setState(() => _payerSide = s.first),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(hintText: l10n.disputeAmountHint),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _methodController,
                        decoration: InputDecoration(hintText: l10n.disputeMethodHint),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(hintText: l10n.disputeNoteHint),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _busy ? null : _propose,
                        child: Text(l10n.disputePropose),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (page.history.isNotEmpty) ...[
              Text(l10n.disputeHistoryTitle, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final p in page.history) ...[
                _ProposalCard(proposal: p, mySide: widget.mySide, busy: true, readOnly: true),
                const SizedBox(height: 8),
              ],
            ] else if (page.current == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text(l10n.disputeNoSettlementPayments)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final DisputeSettlementProposal proposal;
  final String? mySide;
  final bool busy;
  final bool readOnly;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onConfirmReceived;
  final VoidCallback? onWithdraw;

  const _ProposalCard({
    required this.proposal,
    this.mySide,
    required this.busy,
    this.readOnly = false,
    this.onAccept,
    this.onReject,
    this.onConfirmReceived,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${proposal.amount}', style: Theme.of(context).textTheme.titleMedium),
            Text('${proposal.payerSide} -> ${proposal.payeeSide} · ${proposal.status}'),
            if (proposal.method != null && proposal.method!.isNotEmpty) Text(proposal.method!),
            if (proposal.note != null && proposal.note!.isNotEmpty) Text(proposal.note!),
            if (!readOnly && proposal.isPending) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (!proposal.proposedByMe) ...[
                    FilledButton(onPressed: busy ? null : onAccept, child: Text(l10n.disputeAccept)),
                    OutlinedButton(onPressed: busy ? null : onReject, child: Text(l10n.disputeReject)),
                  ],
                  if (proposal.proposedByMe)
                    OutlinedButton(onPressed: busy ? null : onWithdraw, child: Text(l10n.disputeWithdraw)),
                ],
              ),
            ],
            if (!readOnly && proposal.status == 'accepted' && mySide == proposal.payeeSide) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: busy ? null : onConfirmReceived,
                child: Text(l10n.disputeConfirmReceived),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
