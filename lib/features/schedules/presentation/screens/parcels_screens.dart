import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/handover/handover_code.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../contact_groups/application/contact_groups_providers.dart';
import '../../../disputes/presentation/widgets/dispute_reason_picker.dart';
import '../../application/schedules_providers.dart';
import '../../data/models/trip_parcel.dart';

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  TripParcel.requested => l10n.parcelStatusRequested,
  TripParcel.priced => l10n.parcelStatusPriced,
  TripParcel.accepted => l10n.parcelStatusAccepted,
  TripParcel.loaded => l10n.parcelStatusLoaded,
  TripParcel.delivered => l10n.parcelStatusDelivered,
  TripParcel.rejected => l10n.parcelStatusRejected,
  TripParcel.cancelled => l10n.parcelStatusCancelled,
  TripParcel.returned => l10n.parcelStatusReturned,
  _ => status,
};

String _money(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String _when(DateTime t) => t.toLocal().toString().substring(0, 16);

void _toast(BuildContext context, Object e) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
  );
}

/// Who pays the driver, in cash: the label that reads the same on both sides.
String _payerLabel(AppLocalizations l10n, TripParcel p) =>
    p.payer == 'sender' ? l10n.parcelPayerSender : l10n.parcelPayerReceiver;

/// The sender (an app account) describes a parcel to send with a trip leg. The receiver is a friend/family account
/// picked from the contact groups, or a name and a phone for someone with no account. The driver prices it next.
Future<void> showParcelRequestSheet(BuildContext context, {required int scheduleId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ParcelRequestSheet(scheduleId: scheduleId),
  );
}

class _ParcelRequestSheet extends ConsumerStatefulWidget {
  final int scheduleId;
  const _ParcelRequestSheet({required this.scheduleId});

  @override
  ConsumerState<_ParcelRequestSheet> createState() => _ParcelRequestSheetState();
}

class _ParcelRequestSheetState extends ConsumerState<_ParcelRequestSheet> {
  final _description = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  int? _receiverUserId;
  String? _receiverLabel;
  String _payer = 'receiver';
  bool _busy = false;

  @override
  void dispose() {
    _description.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    if (_description.text.trim().isEmpty) return;
    if (_receiverUserId == null && (_name.text.trim().isEmpty || _phone.text.trim().isEmpty)) {
      _toast(context, ApiException(message: l10n.parcelReceiverRequired));
      return;
    }

    setState(() => _busy = true);

    try {
      await ref.read(schedulesApiProvider).requestParcel(
        widget.scheduleId,
        description: _description.text.trim(),
        receiverUserId: _receiverUserId,
        receiverName: _receiverUserId == null ? _name.text.trim() : null,
        receiverPhone: _receiverUserId == null ? _phone.text.trim() : null,
        payer: _payer,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.parcelRequestSent)));
    } catch (e) {
      if (mounted) {
        _toast(context, e);
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final groups = ref.watch(contactGroupsControllerProvider).groups.where((g) => g.members.isNotEmpty).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.parcelRequestTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.parcelDescriptionLabel, helperText: l10n.parcelDescriptionHelp),
              ),
              const SizedBox(height: 14),
              Text(l10n.parcelReceiverTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              if (_receiverUserId != null) ...[
                const SizedBox(height: 6),
                InputChip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(_receiverLabel ?? '#$_receiverUserId'),
                  onDeleted: () => setState(() {
                    _receiverUserId = null;
                    _receiverLabel = null;
                  }),
                ),
              ] else ...[
                for (final group in groups) ...[
                  const SizedBox(height: 6),
                  Text(group.name, style: theme.textTheme.labelLarge),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final m in group.members)
                        ActionChip(
                          avatar: const Icon(Icons.person_outline, size: 18),
                          label: Text(m.name),
                          onPressed: () => setState(() {
                            _receiverUserId = m.userId;
                            _receiverLabel = m.name;
                          }),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(l10n.parcelReceiverNoAccount, style: theme.textTheme.bodySmall),
                TextField(controller: _name, decoration: InputDecoration(labelText: l10n.parcelReceiverName)),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.parcelReceiverPhone),
                ),
              ],
              const SizedBox(height: 14),
              // paid in cash to the driver — recorded only; the wallet is for fees, deposits and guarantees
              Text(l10n.parcelWhoPaysTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'sender', label: Text(l10n.parcelPayerSender)),
                  ButtonSegment(value: 'receiver', label: Text(l10n.parcelPayerReceiver)),
                ],
                selected: {_payer},
                onSelectionChanged: (v) => setState(() => _payer = v.first),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _busy ? null : _send, child: Text(l10n.parcelSendRequest)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «شحناتي»: what I send and what is sent to me — accept the driver's price, show the pickup QR, generate the delivery
/// code (the receiver with an account sees it as a QR too), and dispute it like any paid service.
class MyParcelsScreen extends ConsumerStatefulWidget {
  const MyParcelsScreen({super.key});

  @override
  ConsumerState<MyParcelsScreen> createState() => _MyParcelsScreenState();
}

class _MyParcelsScreenState extends ConsumerState<MyParcelsScreen> {
  List<TripParcel>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await ref.read(schedulesApiProvider).myParcels();
      if (mounted) setState(() => _items = page.items);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _run(Future<TripParcel> Function() action) async {
    try {
      await action();
      await _load();
    } catch (e) {
      if (mounted) _toast(context, e);
    }
  }

  Future<void> _dispute(TripParcel p) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    try {
      await ref.read(schedulesApiProvider).disputeParcel(p.id, reasonCode: result.reasonCode, reasonText: result.reasonText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.visitDepositDisputeOpened)));
      }
    } catch (e) {
      if (mounted) _toast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(schedulesApiProvider);
    final items = _items;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myParcelsTitle)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(child: Text(l10n.myParcelsEmpty))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = items[index];

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis)),
                              Text(_statusLabel(l10n, p.status), style: Theme.of(context).textTheme.labelMedium),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.parcelReceiverTitle}: ${p.receiverName ?? '—'}${p.receiverPhone != null ? ' · ${p.receiverPhone}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (p.price != null)
                            Text(
                              '${_money(p.price!)} ${p.currency}${p.seats > 0 ? ' · ${l10n.parcelTakesSeats(p.seats)}' : ''}'
                              ' · ${_payerLabel(l10n, p)}${p.isPaid ? ' ✓' : ''}',
                            ),
                          // approximate (the driver's word) vs the actual hour it was handed over
                          if (p.expectedArrivalAt != null)
                            Text(l10n.parcelExpectedArrival(_when(p.expectedArrivalAt!)), style: Theme.of(context).textTheme.bodySmall),
                          if (p.deliveredAt != null)
                            Text(l10n.parcelDeliveredAt(_when(p.deliveredAt!)), style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (p.status == TripParcel.priced)
                                FilledButton(
                                  onPressed: () => _run(() => api.acceptParcel(p.id)),
                                  child: Text(l10n.parcelAcceptPrice),
                                ),
                              if (p.handoverCode != null && p.handoverKind != null)
                                OutlinedButton(
                                  onPressed: () => _run(() => api.regenerateParcelCode(p.id)),
                                  child: Text(l10n.parcelRegenerateCode),
                                ),
                              if (p.isOpenForSender)
                                TextButton(onPressed: () => _run(() => api.cancelParcel(p.id)), child: Text(l10n.parcelCancel)),
                              if (p.canDispute)
                                TextButton(onPressed: () => _dispute(p), child: Text(l10n.disputeOpenTitle)),
                            ],
                          ),
                          // the ONE code: the QR the driver scans to TAKE the parcel, and — once it is on the car — the
                          // QR/code the receiver gives the driver to GET it (a receiver without the app is told the typed code)
                          if (p.handoverCode != null) ...[
                            const Divider(height: 24),
                            HandoverCodeCard(
                              key: ValueKey('${p.id}-${p.handoverKind}'),
                              code: p.handoverCode!,
                              caption: p.handoverKind == 'delivery' ? l10n.parcelCodeHint : l10n.parcelPickupCodeHint,
                              showQr: p.handoverKind == 'pickup' || p.receiverUserId != null,
                              hideCode: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// The driver's parcels: price (and say whether it takes a seat, and roughly when it arrives), take it from the sender
/// by QR/code, hand it over by QR/code, or refuse. The cash is only recorded.
class CarrierParcelsScreen extends ConsumerStatefulWidget {
  const CarrierParcelsScreen({super.key});

  @override
  ConsumerState<CarrierParcelsScreen> createState() => _CarrierParcelsScreenState();
}

class _CarrierParcelsScreenState extends ConsumerState<CarrierParcelsScreen> {
  List<TripParcel>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await ref.read(schedulesApiProvider).carrierParcels();
      if (mounted) setState(() => _items = page.items);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _run(Future<TripParcel> Function() action) async {
    try {
      await action();
      await _load();
    } catch (e) {
      if (mounted) _toast(context, e);
    }
  }

  Future<void> _price(TripParcel p) async {
    final result = await showDialog<({double price, int seats, DateTime? arrival})>(
      context: context,
      builder: (_) => _ParcelPriceDialog(parcel: p),
    );

    if (result == null) return;
    await _run(() => ref.read(schedulesApiProvider).priceParcel(p.id, price: result.price, seats: result.seats, expectedArrivalAt: result.arrival));
  }

  /// Asks for the code (scan or type); the server checks it first, and only a right code — when this is the moment the
  /// cash changes hands — comes back asking whether it was collected (a wrong code is never met with a question about money).
  Future<void> _handover(TripParcel p, {required bool pickup}) async {
    final l10n = AppLocalizations.of(context)!;

    final code = await askHandoverCode(
      context,
      title: pickup ? l10n.parcelPickupTitle : l10n.parcelDeliverTitle,
      hint: pickup ? l10n.parcelPickupHint : l10n.parcelDeliverCodeHelp,
    );
    if (code == null || !mounted) return;

    final api = ref.read(schedulesApiProvider);
    Future<TripParcel> send(bool? cash) => pickup ? api.loadParcel(p.id, code, cashCollected: cash) : api.deliverParcel(p.id, code, cashCollected: cash);

    bool? cash;
    try {
      await send(null);
    } on ApiException catch (e) {
      if (e.firstErrorFor('cash_collected') == null || !mounted) {
        if (mounted) _toast(context, e);
        return;
      }
      final collected = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.parcelCashTitle),
          content: Text(l10n.parcelCashBody(_money(p.price!), p.currency)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.parcelCashNotYet)),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.parcelCashCollected)),
          ],
        ),
      );
      if (collected == null) return;
      cash = collected;
    } catch (e) {
      if (mounted) _toast(context, e);
      return;
    }

    // no money changed hands at this handover: the first call already did it
    if (cash == null) {
      await _load();
      return;
    }
    await _run(() => send(cash));
  }

  Future<void> _dispute(TripParcel p) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDisputeReasonPicker(context, ref);
    if (result == null || !mounted) return;

    try {
      await ref.read(schedulesApiProvider).disputeParcel(p.id, reasonCode: result.reasonCode, reasonText: result.reasonText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.visitDepositDisputeOpened)));
      }
    } catch (e) {
      if (mounted) _toast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(schedulesApiProvider);
    final items = _items;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.carrierParcelsTitle)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(child: Text(l10n.carrierParcelsEmpty))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = items[index];

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(p.description, maxLines: 3, overflow: TextOverflow.ellipsis)),
                              Text(_statusLabel(l10n, p.status), style: Theme.of(context).textTheme.labelMedium),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${l10n.parcelSender}: ${p.senderName ?? '#${p.senderId}'}', style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            '${l10n.parcelReceiverTitle}: ${p.receiverName ?? '—'}${p.receiverPhone != null ? ' · ${p.receiverPhone}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (p.price != null)
                            Text(
                              '${_money(p.price!)} ${p.currency}${p.seats > 0 ? ' · ${l10n.parcelTakesSeats(p.seats)}' : ''}'
                              ' · ${_payerLabel(l10n, p)}${p.isPaid ? ' ✓' : ''}',
                            ),
                          if (p.expectedArrivalAt != null)
                            Text(l10n.parcelExpectedArrival(_when(p.expectedArrivalAt!)), style: Theme.of(context).textTheme.bodySmall),
                          if (p.deliveredAt != null)
                            Text(l10n.parcelDeliveredAt(_when(p.deliveredAt!)), style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (p.status == TripParcel.requested || p.status == TripParcel.priced)
                                FilledButton(onPressed: () => _price(p), child: Text(l10n.parcelSetPrice)),
                              if (p.status == TripParcel.accepted)
                                OutlinedButton(
                                  onPressed: () => _handover(p, pickup: true),
                                  child: Text(l10n.parcelLoadAction),
                                ),
                              if (p.status == TripParcel.loaded)
                                FilledButton(onPressed: () => _handover(p, pickup: false), child: Text(l10n.parcelDeliverAction)),
                              if (p.status == TripParcel.requested || p.status == TripParcel.priced)
                                TextButton(onPressed: () => _run(() => api.rejectParcel(p.id)), child: Text(l10n.tripReservationRejectAction)),
                              if (p.canDispute)
                                TextButton(onPressed: () => _dispute(p), child: Text(l10n.disputeOpenTitle)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// The driver's price (and whether it takes a seat, and roughly when it arrives). Owns its controllers so they outlive
/// the dialog's exit animation.
class _ParcelPriceDialog extends StatefulWidget {
  final TripParcel parcel;

  const _ParcelPriceDialog({required this.parcel});

  @override
  State<_ParcelPriceDialog> createState() => _ParcelPriceDialogState();
}

class _ParcelPriceDialogState extends State<_ParcelPriceDialog> {
  late final TextEditingController _price = TextEditingController(text: widget.parcel.price != null ? _money(widget.parcel.price!) : '');
  late final TextEditingController _seats = TextEditingController(text: '${widget.parcel.seats}');
  late DateTime? _arrival = widget.parcel.expectedArrivalAt;

  @override
  void dispose() {
    _price.dispose();
    _seats.dispose();
    super.dispose();
  }

  Future<void> _pickArrival() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _arrival ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_arrival ?? DateTime.now()));
    if (time == null || !mounted) return;
    setState(() => _arrival = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final arrival = _arrival;

    return AlertDialog(
      title: Text(l10n.parcelPriceTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.parcel.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.parcelPriceLabel),
            ),
            TextField(
              controller: _seats,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.parcelSeatsLabel, helperText: l10n.parcelSeatsHelp),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: Text(arrival == null ? l10n.parcelExpectedArrivalPick : l10n.parcelExpectedArrival(_when(arrival))),
              onPressed: _pickArrival,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(_price.text.trim().replaceAll(',', '.'));
            if (value == null) return;
            Navigator.pop(context, (price: value, seats: int.tryParse(_seats.text.trim()) ?? 0, arrival: _arrival));
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
