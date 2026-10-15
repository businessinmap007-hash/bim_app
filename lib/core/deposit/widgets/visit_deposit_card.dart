import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/disputes/presentation/widgets/dispute_reason_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../network/api_exception.dart';
import '../visit_deposit.dart';
import '../visit_deposit_providers.dart';
import 'invite_guarantor_sheet.dart';

/// «عربون الجدية» of one health visit, in plain words, with what each side may do about it.
///
/// One widget for every kind of visit and for both sides (the patient reads it, the business answers it):
///  • a deposit the terms ask but is not secured yet — what will be asked;
///  • frozen in the wallets — both shares, and that they go back after the visit;
///  • owed outside the platform — the business records «استلمت كاش / تحويلًا» or accepts without it;
///  • after a no-show — the business gives it back, or either side opens a dispute over it.
/// It never gates the visit and never stops an account; [onChanged] reloads the host after an answer.
class VisitDepositCard extends ConsumerStatefulWidget {
  final VisitDeposit deposit;
  final VisitKind kind;
  final int subjectId;

  /// true on the business's own screens (it answers); false on the patient's.
  final bool forBusiness;

  /// The visit is over without being done (a no-show): a held deposit may now be given back or disputed.
  final bool visitEnded;
  final Future<void> Function()? onChanged;

  const VisitDepositCard({
    super.key,
    required this.deposit,
    required this.kind,
    required this.subjectId,
    required this.forBusiness,
    this.visitEnded = false,
    this.onChanged,
  });

  @override
  ConsumerState<VisitDepositCard> createState() => _VisitDepositCardState();
}

class _VisitDepositCardState extends ConsumerState<VisitDepositCard> {
  bool _busy = false;

  VisitDeposit get _d => widget.deposit;

  String _money(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  String _text(AppLocalizations l10n) {
    final amount = _money(_d.amount);
    final counter = _money(_d.counterAmount);

    if (widget.kind == VisitKind.order && (_d.status == VisitDeposit.quoted || _d.status == VisitDeposit.held)) {
      return switch (_d.status) {
        VisitDeposit.quoted => widget.forBusiness ? l10n.orderDepositQuotedBusiness(amount) : l10n.orderDepositQuotedCustomer(amount),
        _ => l10n.orderDepositHeld(amount),
      };
    }

    // a trip reservation talks about a passenger and a trip, not a patient and a visit
    if (widget.kind == VisitKind.tripReservation && (_d.status == VisitDeposit.quoted || _d.status == VisitDeposit.held)) {
      return switch (_d.status) {
        VisitDeposit.quoted => widget.forBusiness ? l10n.tripDepositQuotedBusiness(amount) : l10n.tripDepositQuotedCustomer(amount),
        _ => l10n.tripDepositHeld(amount),
      };
    }

    return switch (_d.status) {
      VisitDeposit.quoted =>
        _d.isExternal
            ? (widget.forBusiness ? l10n.visitDepositQuotedExternalBusiness(amount) : l10n.visitDepositQuotedExternalPatient(amount))
            : (widget.forBusiness
                  ? (_d.counterAmount > 0
                        ? l10n.visitDepositQuotedWalletBusiness(amount, counter)
                        : l10n.visitDepositQuotedWalletBusinessNoCounter(amount))
                  : l10n.visitDepositQuotedWalletPatient(amount)),
      VisitDeposit.held => _d.counterAmount > 0 ? l10n.visitDepositHeld(amount, counter) : l10n.visitDepositHeldClientOnly(amount),
      VisitDeposit.pending =>
        widget.forBusiness ? l10n.visitDepositPendingBusiness(amount) : l10n.visitDepositPendingPatient(amount),
      VisitDeposit.received => _d.method == 'transfer' ? l10n.visitDepositReceivedTransfer : l10n.visitDepositReceivedCash,
      VisitDeposit.waived => l10n.visitDepositWaived,
      VisitDeposit.released => l10n.visitDepositReleased,
      VisitDeposit.refunded => l10n.visitDepositRefunded,
      VisitDeposit.disputed => l10n.visitDepositDisputed,
      VisitDeposit.resolved => l10n.visitDepositResolved,
      _ => '',
    };
  }

  Future<void> _run(Future<void> Function() step, String doneMessage) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await step();
      await widget.onChanged?.call();
      messenger.showSnackBar(SnackBar(content: Text(doneMessage)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openDispute() async {
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    await _run(
      () => ref
          .read(visitDepositApiProvider)
          .openDispute(widget.kind, widget.subjectId, reasonCode: result.reasonCode, reasonText: result.reasonText),
      l10n.visitDepositDisputeOpened,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_d.isHidden) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final api = ref.read(visitDepositApiProvider);
    final text = _text(l10n);
    if (text.isEmpty) return const SizedBox.shrink();

    final answersExternal = widget.forBusiness && _d.status == VisitDeposit.pending;
    final canGiveBack = widget.forBusiness && _d.status == VisitDeposit.held && widget.visitEnded;
    final canDispute = _d.status == VisitDeposit.held && widget.visitEnded && !_d.isExternal;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(l10n.visitDepositTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: theme.textTheme.bodyMedium),
          if (_d.status != VisitDeposit.quoted && _d.guaranteeAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.visitDepositFromGuarantee(_money(_d.guaranteeAmount)), style: theme.textTheme.bodySmall),
            ),
          if (_d.status != VisitDeposit.quoted && _d.businessGuaranteeAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(l10n.visitDepositBusinessFromGuarantee(_money(_d.businessGuaranteeAmount)), style: theme.textTheme.bodySmall),
            ),
          // short of the deposit? a friend with an active guarantee may stand for it until the operation ends
          if (!widget.forBusiness && _d.status == VisitDeposit.quoted && !_d.isExternal) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => showInviteGuarantorSheet(context, kind: widget.kind, subjectId: widget.subjectId),
              icon: const Icon(Icons.group_add_outlined),
              label: Text(l10n.guarantorInviteButton),
            ),
          ],
          if (answersExternal) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => api.confirmReceived(widget.kind, widget.subjectId, 'cash'),
                            l10n.externalDepositReceived,
                          ),
                    child: Text(l10n.externalDepositCash),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => api.confirmReceived(widget.kind, widget.subjectId, 'transfer'),
                            l10n.externalDepositReceived,
                          ),
                    child: Text(l10n.externalDepositTransfer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : () => _run(() => api.waive(widget.kind, widget.subjectId), l10n.externalDepositWaived),
                child: Text(l10n.externalDepositWaive),
              ),
            ),
          ],
          if (canGiveBack || canDispute) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canGiveBack)
                  FilledButton(
                    onPressed: _busy ? null : () => _run(() => api.giveBack(widget.kind, widget.subjectId), l10n.visitDepositGiveBackDone),
                    child: Text(l10n.visitDepositGiveBack),
                  ),
                if (canDispute)
                  OutlinedButton(onPressed: _busy ? null : _openDispute, child: Text(l10n.visitDepositDispute)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
