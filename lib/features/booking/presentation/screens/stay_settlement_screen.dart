import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/time/clock_format.dart';
import '../../../../core/time/local_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../../disputes/presentation/screens/dispute_detail_screen.dart';
import '../../application/booking_providers.dart';
import '../../application/stay_settlement_providers.dart';
import '../../data/models/stay_settlement.dart';

/// «التسوية» of a non-refundable stay — the same screen for the guest and the hotel. What is frozen from each side (guarantee first,
/// wallet for the rest), both sides' «تمت التسوية», the payments the guest recorded with their proof (only the hotel confirms them),
/// and, three days after a cancellation, a judge. Nothing here ever unwinds by itself.
class StaySettlementScreen extends ConsumerStatefulWidget {
  final int bookingId;

  /// what the guest is offered to record as paid — the stay's price
  final double? suggestedAmount;

  const StaySettlementScreen({super.key, required this.bookingId, this.suggestedAmount});

  @override
  ConsumerState<StaySettlementScreen> createState() => _StaySettlementScreenState();
}

class _StaySettlementScreenState extends ConsumerState<StaySettlementScreen> {
  StaySettlement? _s;
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(bookingApiProvider).staySettlement(widget.bookingId);
      if (mounted) setState(() => (_s = s, _loaded = true));
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _run(Future<StaySettlement?> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final s = await action();
      ref.invalidate(openStaySettlementsProvider);
      if (mounted) setState(() => _s = s ?? _s);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _answer(StaySettlementPayment p, bool received) async {
    final l10n = AppLocalizations.of(context)!;
    String? note;
    if (!received) {
      note = await showDialog<String>(context: context, builder: (_) => const _NoteDialog());
      if (note == null) return;
    }
    await _run(() => ref.read(bookingApiProvider).answerStayPayment(widget.bookingId, p.id, received: received, note: note));
    if (mounted && received) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settlementPaymentConfirmed)));
  }

  Future<void> _recordPayment() async {
    final s = await showModalBottomSheet<StaySettlement?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecordPaymentSheet(bookingId: widget.bookingId, suggestedAmount: widget.suggestedAmount),
    );
    if (s != null && mounted) {
      ref.invalidate(openStaySettlementsProvider);
      setState(() => _s = s);
    }
  }

  /// «التسوية من محفظة التطبيق»: propose the whole held deposit, or less — the guest offers it, the hotel asks for it.
  Future<void> _offerWallet(StaySettlement s) async {
    final amount = await showDialog<double>(context: context, builder: (_) => _CollectDialog(max: s.collectable, guest: s.isClient));
    if (amount == null || !mounted) return;
    await _run(() => ref.read(bookingApiProvider).offerStayWallet(widget.bookingId, amount: amount));
  }

  Future<void> _arbitration() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settlementArbitrationTitle),
        content: Text(l10n.settlementArbitrationConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.settlementArbitrationAsk)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final disputeId = await ref.read(bookingApiProvider).requestStayArbitration(widget.bookingId);
      ref.invalidate(openStaySettlementsProvider);
      await _load();
      if (disputeId != null && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DisputeDetailScreen(disputeId: disputeId)));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final s = _s;

    String money(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
    String hold(({double guarantee, double wallet})? h) {
      if (h == null) return '—';
      final parts = [
        if (h.guarantee > 0) l10n.settlementFromGuarantee(money(h.guarantee)),
        if (h.wallet > 0) l10n.settlementFromWallet(money(h.wallet)),
      ];
      return parts.isEmpty ? '—' : parts.join(' + ');
    }

    String when(DateTime? d) => d == null ? l10n.settlementWaiting : '✓ ${LocalFormat.date(context).format(d.toLocal())} · ${ClockFormat.time(context, d.toLocal())}';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settlementTitle(widget.bookingId))),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : s == null
          ? Center(child: Text(l10n.settlementNone))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (s.isOpen)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
                    child: Text(l10n.settlementPlease, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onErrorContainer, fontWeight: FontWeight.w700)),
                  ),
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.settlementFrozen, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('${l10n.settlementClientHold(money(s.percent))}: ${hold(s.clientHold)}'),
                        Text('${l10n.settlementBusinessHold(money(s.percent))}: ${hold(s.businessHold)}'),
                        const SizedBox(height: 6),
                        Text(
                          switch (s.status) {
                            'secured' => l10n.settlementSecuredNote,
                            'settled' => switch (s.settledBy) {
                              'wallet_collection' => l10n.settlementCollectedNote(money(s.collected ?? 0)),
                              'stay_started' => l10n.settlementStayStartedNote,
                              _ => l10n.settlementSettledNote,
                            },
                            'arbitration' => l10n.settlementArbitrationNote,
                            _ => l10n.settlementOpenNote,
                          },
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                ),
                if (s.isOpen) ...[
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.settlementConfirmTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Row(children: [
                            Expanded(child: Text(l10n.settlementHotel)),
                            Text(when(s.businessConfirmedAt)),
                          ]),
                          // the staff member who confirmed for the hotel, by name
                          if (s.businessConfirmedAt != null && (s.businessConfirmedBy ?? '').isNotEmpty)
                            Text(l10n.settlementConfirmedBy(s.businessConfirmedBy!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                          Row(children: [Expanded(child: Text(l10n.settlementGuest)), Text(when(s.clientConfirmedAt))]),
                          const SizedBox(height: 10),
                          if (s.myConfirmedAt == null)
                            FilledButton(
                              onPressed: _busy ? null : () => _run(() => ref.read(bookingApiProvider).confirmStaySettlement(widget.bookingId)),
                              child: Text(l10n.settlementDone),
                            )
                          else
                            OutlinedButton(
                              onPressed: _busy ? null : () => _run(() => ref.read(bookingApiProvider).confirmStaySettlement(widget.bookingId, confirm: false)),
                              child: Text(l10n.settlementWithdraw),
                            ),
                          const SizedBox(height: 4),
                          Text(l10n.settlementBothNeeded, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.settlementPaymentsTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(l10n.settlementPaymentsNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                        for (final p in s.payments) _paymentTile(context, l10n, s, p, money),
                        if (s.isClient && (s.status == 'secured' || s.isOpen) && !s.hasWaitingPayment) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.receipt_long_outlined),
                            onPressed: _busy ? null : _recordPayment,
                            label: Text(l10n.settlementRecordPayment),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // «التسوية من محفظة التطبيق»: a faster way to settle — one side proposes, the other says yes
                if (s.isOpen && s.collectable > 0) ...[
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.settlementCollectTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(l10n.settlementCollectNote(money(s.collectable)), style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          if (s.walletOffer == null)
                            FilledButton.tonal(
                              onPressed: _busy ? null : () => _offerWallet(s),
                              child: Text(s.isClient ? l10n.settlementWalletOfferGuest : l10n.settlementWalletAskHotel),
                            )
                          else if (s.walletOffer!.by == s.mySide) ...[
                            Text(l10n.settlementWalletMine(money(s.walletOffer!.amount)), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            TextButton(
                              onPressed: _busy ? null : () => _run(() => ref.read(bookingApiProvider).withdrawStayWalletOffer(widget.bookingId)),
                              child: Text(l10n.settlementWalletWithdraw),
                            ),
                          ] else ...[
                            Text(
                              s.isClient ? l10n.settlementWalletHotelAsks(money(s.walletOffer!.amount)) : l10n.settlementWalletGuestOffers(money(s.walletOffer!.amount)),
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: _busy ? null : () => _run(() => ref.read(bookingApiProvider).answerStayWalletOffer(widget.bookingId, accept: true)),
                                  child: Text(l10n.settlementWalletAccept),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _busy ? null : () => _run(() => ref.read(bookingApiProvider).answerStayWalletOffer(widget.bookingId, accept: false)),
                                  child: Text(l10n.settlementWalletDecline),
                                ),
                              ),
                            ]),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (s.isOpen || s.status == 'arbitration') ...[
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.settlementNoAgreement, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(l10n.settlementArbitrationHow, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          if (s.status == 'arbitration' && s.disputeId != null)
                            FilledButton.tonal(
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DisputeDetailScreen(disputeId: s.disputeId!))),
                              child: Text(l10n.settlementOpenDispute),
                            )
                          else if (s.canRequestArbitration)
                            TextButton(onPressed: _busy ? null : _arbitration, child: Text(l10n.settlementArbitrationAsk))
                          else if (s.arbitrationFrom != null)
                            Text(
                              l10n.settlementArbitrationFrom(LocalFormat.date(context).format(s.arbitrationFrom!.toLocal())),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _paymentTile(BuildContext context, AppLocalizations l10n, StaySettlement s, StaySettlementPayment p, String Function(double) money) {
    final theme = Theme.of(context);
    final status = switch (p.status) {
      'received' => l10n.settlementPaymentReceived,
      'refused' => l10n.settlementPaymentRefused,
      _ => l10n.settlementPaymentWaiting,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.proofUrl != null)
            InkWell(
              onTap: () => FullScreenGallery.show(context, urls: [p.proofUrl!]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(p.proofUrl!, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(width: 56, height: 56, child: Icon(Icons.image_not_supported_outlined))),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${money(p.amount)} · ${p.method == 'transfer' ? l10n.settlementTransfer : l10n.settlementCash}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                if ((p.reference ?? '').isNotEmpty) Text(p.reference!, style: theme.textTheme.bodySmall),
                Text(status, style: theme.textTheme.bodySmall?.copyWith(color: p.status == 'refused' ? theme.colorScheme.error : theme.hintColor)),
                if ((p.answerNote ?? '').isNotEmpty) Text(p.answerNote!, style: theme.textTheme.bodySmall),
                // only the hotel — the payee — says it arrived
                if (!s.isClient && p.status == 'recorded')
                  Wrap(spacing: 8, children: [
                    FilledButton(onPressed: _busy ? null : () => _answer(p, true), child: Text(l10n.settlementArrived)),
                    OutlinedButton(onPressed: _busy ? null : () => _answer(p, false), child: Text(l10n.settlementNotArrived)),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectDialog extends StatefulWidget {
  final double max;

  /// the guest offers; the hotel asks
  final bool guest;
  const _CollectDialog({required this.max, required this.guest});

  @override
  State<_CollectDialog> createState() => _CollectDialogState();
}

class _CollectDialogState extends State<_CollectDialog> {
  late final _amount = TextEditingController(text: widget.max.toStringAsFixed(widget.max == widget.max.roundToDouble() ? 0 : 2));
  bool _all = true;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final max = widget.max.toStringAsFixed(widget.max == widget.max.roundToDouble() ? 0 : 2);

    return AlertDialog(
      title: Text(widget.guest ? l10n.settlementWalletOfferGuest : l10n.settlementWalletAskHotel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<bool>(
            groupValue: _all,
            onChanged: (v) => setState(() => _all = v ?? true),
            child: Column(children: [
              RadioListTile<bool>(contentPadding: EdgeInsets.zero, value: true, title: Text(l10n.settlementCollectAll(max))),
              RadioListTile<bool>(contentPadding: EdgeInsets.zero, value: false, title: Text(l10n.settlementCollectFine)),
            ]),
          ),
          if (!_all)
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.settlementCollectAmount(max), errorText: _error),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            if (_all) return Navigator.pop(context, widget.max);
            final v = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
            if (v == null || v <= 0 || v > widget.max) return setState(() => _error = l10n.settlementCollectAmount(max));
            Navigator.pop(context, v);
          },
          child: Text(widget.guest ? l10n.settlementWalletSendOffer : l10n.settlementWalletSendAsk),
        ),
      ],
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog();

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.settlementNotArrived),
      content: TextField(controller: _note, decoration: InputDecoration(labelText: l10n.settlementNotArrivedNote), maxLength: 500),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _note.text.trim()), child: Text(l10n.commonSave)),
      ],
    );
  }
}

/// «تسجيل دفعة خارج التطبيق»: the amount, how, the reference, the PROOF, and the guest's acknowledgement that paying outside the
/// app is on his own responsibility. Owns its controllers.
class _RecordPaymentSheet extends ConsumerStatefulWidget {
  final int bookingId;
  final double? suggestedAmount;
  const _RecordPaymentSheet({required this.bookingId, this.suggestedAmount});

  @override
  ConsumerState<_RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<_RecordPaymentSheet> {
  late final _amount = TextEditingController(text: widget.suggestedAmount == null ? '' : widget.suggestedAmount!.toStringAsFixed(0));
  final _reference = TextEditingController();
  String _method = 'transfer';
  String? _proof;
  bool _ack = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 2000, maxHeight: 2000);
    if (picked != null && mounted) setState(() => _proof = picked.path);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0 || _proof == null || !_ack) {
      setState(() => _error = l10n.settlementPaymentMissing);
      return;
    }
    setState(() => (_saving = true, _error = null));
    try {
      final s = await ref.read(bookingApiProvider).recordStayPayment(widget.bookingId, amount: amount, method: _method, reference: _reference.text.trim(), proofPath: _proof!);
      if (mounted) Navigator.of(context).pop(s);
    } catch (e) {
      if (mounted) setState(() => (_saving = false, _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settlementRecordPayment, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            // «الدفع خارج التطبيق على مسؤوليتك الشخصية، ويجب أن يكون لديك إثبات الدفع»
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
              child: Text(l10n.settlementOwnResponsibility, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer)),
            ),
            const SizedBox(height: 10),
            TextField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.settlementAmount)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ChoiceChip(label: Text(l10n.settlementTransfer), selected: _method == 'transfer', onSelected: (_) => setState(() => _method = 'transfer')),
              ChoiceChip(label: Text(l10n.settlementCash), selected: _method == 'cash', onSelected: (_) => setState(() => _method = 'cash')),
            ]),
            TextField(controller: _reference, decoration: InputDecoration(labelText: l10n.settlementReference)),
            const SizedBox(height: 10),
            Text(l10n.settlementProof, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Row(children: [
              if (_proof != null) const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 6),
              OutlinedButton.icon(icon: const Icon(Icons.photo_camera_outlined), onPressed: () => _pick(ImageSource.camera), label: Text(l10n.settlementProofCamera)),
              const SizedBox(width: 8),
              OutlinedButton.icon(icon: const Icon(Icons.photo_library_outlined), onPressed: () => _pick(ImageSource.gallery), label: Text(l10n.settlementProofGallery)),
            ]),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _ack,
              onChanged: (v) => setState(() => _ack = v ?? false),
              title: Text(l10n.settlementAcknowledge, style: theme.textTheme.bodySmall),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 8),
            FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.settlementRecordSend)),
          ],
        ),
      ),
    );
  }
}

/// «تسويات بانتظارك»: every open settlement of this account.
class MyStaySettlementsScreen extends ConsumerWidget {
  const MyStaySettlementsScreen({super.key});

  /// What the settlement waits for, from where the reader stands.
  static String _waiting(AppLocalizations l10n, StaySettlement s) {
    String money(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
    final offer = s.walletOffer;

    if (offer != null && offer.by != s.mySide) {
      return s.isClient ? l10n.settlementWalletHotelAsks(money(offer.amount)) : l10n.settlementWalletGuestOffers(money(offer.amount));
    }
    if (offer != null) return l10n.settlementWalletMine(money(offer.amount));
    if (s.theirConfirmedAt != null) return l10n.settlementTheyConfirmed;
    if (s.myConfirmedAt != null) return l10n.settlementIConfirmed;

    return l10n.settlementWaitingBoth;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rows = ref.watch(openStaySettlementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settlementsTitle)),
      body: rows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (list) => list.isEmpty
            ? Center(child: Text(l10n.settlementsEmpty))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final r in list)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.balance_outlined),
                        title: Text(l10n.settlementPlease),
                        subtitle: Text([
                          '${l10n.settlementTitle(r.bookingId)} · ${r.counterpart ?? ''}',
                          // a staff member settles on behalf of the hotel he works for
                          if ((r.forBusiness ?? '').isNotEmpty) l10n.settlementForBusiness(r.forBusiness!),
                          _waiting(l10n, r.settlement),
                        ].join('\n')),
                        isThreeLine: true,
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => StaySettlementScreen(bookingId: r.bookingId)));
                          ref.invalidate(openStaySettlementsProvider);
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
