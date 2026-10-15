import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../contact_groups/application/contact_groups_providers.dart';
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
  _ => status,
};

String _money(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

void _toast(BuildContext context, Object e) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
  );
}

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

/// «شحناتي»: what I send and what is sent to me — accept the driver's price, generate the delivery code, and (as the
/// receiver with an account) read it as a QR.
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
                          if (p.price != null) Text('${_money(p.price!)} ${p.currency}${p.seats > 0 ? ' · ${l10n.parcelTakesSeats(p.seats)}' : ''}'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (p.status == TripParcel.priced)
                                FilledButton(
                                  onPressed: () => _run(() => api.acceptParcel(p.id)),
                                  child: Text(l10n.parcelAcceptPrice),
                                ),
                              if (p.isOpenForSender)
                                OutlinedButton(
                                  onPressed: () => _run(() => api.generateParcelCode(p.id)),
                                  child: Text(p.hasCode ? l10n.parcelRegenerateCode : l10n.parcelGenerateCode),
                                ),
                              if (p.isOpenForSender)
                                TextButton(
                                  onPressed: () => _run(() => api.cancelParcel(p.id)),
                                  child: Text(l10n.parcelCancel),
                                ),
                            ],
                          ),
                          if (p.deliveryCode != null) ...[
                            const SizedBox(height: 10),
                            Text(l10n.parcelCodeHint, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    p.deliveryCode!,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 4, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_outlined),
                                  onPressed: () => Clipboard.setData(ClipboardData(text: p.deliveryCode!)),
                                ),
                              ],
                            ),
                            // a receiver who has an account shows this to the driver instead of saying it
                            if (p.receiverUserId != null)
                              Center(
                                child: QrImageView(data: p.deliveryCode!, size: 160, backgroundColor: Colors.white),
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

/// The driver's parcels: price (and say whether it takes a seat), load, hand over against the code, or refuse.
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
    final l10n = AppLocalizations.of(context)!;
    final price = TextEditingController(text: p.price != null ? _money(p.price!) : '');
    final seats = TextEditingController(text: '${p.seats}');

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.parcelPriceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(p.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            TextField(
              controller: price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.parcelPriceLabel),
            ),
            TextField(
              controller: seats,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.parcelSeatsLabel, helperText: l10n.parcelSeatsHelp),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.commonSave)),
        ],
      ),
    );

    final value = double.tryParse(price.text.trim().replaceAll(',', '.'));
    final seatCount = int.tryParse(seats.text.trim()) ?? 0;
    price.dispose();
    seats.dispose();

    if (ok != true || value == null) return;
    await _run(() => ref.read(schedulesApiProvider).priceParcel(p.id, price: value, seats: seatCount));
  }

  Future<void> _deliver(TripParcel p) async {
    final l10n = AppLocalizations.of(context)!;
    final code = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.parcelDeliverTitle),
        content: TextField(
          controller: code,
          autofocus: true,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(labelText: l10n.parcelDeliverCodeLabel, helperText: l10n.parcelDeliverCodeHelp),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.parcelDeliverAction)),
        ],
      ),
    );

    final typed = code.text.trim();
    code.dispose();

    if (ok != true || typed.isEmpty) return;
    await _run(() => ref.read(schedulesApiProvider).deliverParcel(p.id, typed));
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
                          if (p.price != null) Text('${_money(p.price!)} ${p.currency}${p.seats > 0 ? ' · ${l10n.parcelTakesSeats(p.seats)}' : ''}'),
                          if (p.status == TripParcel.delivered && p.deliveredAt != null)
                            Text(l10n.parcelDeliveredAt(p.deliveredAt!.toLocal().toString().substring(0, 16)), style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (p.status == TripParcel.requested || p.status == TripParcel.priced)
                                FilledButton(onPressed: () => _price(p), child: Text(l10n.parcelSetPrice)),
                              if (p.status == TripParcel.accepted)
                                OutlinedButton(
                                  onPressed: p.hasCode ? () => _run(() => api.loadParcel(p.id)) : null,
                                  child: Text(p.hasCode ? l10n.parcelLoadAction : l10n.parcelWaitingForCode),
                                ),
                              if (p.status == TripParcel.loaded)
                                FilledButton(onPressed: () => _deliver(p), child: Text(l10n.parcelDeliverAction)),
                              if (p.status == TripParcel.requested || p.status == TripParcel.priced)
                                TextButton(onPressed: () => _run(() => api.rejectParcel(p.id)), child: Text(l10n.tripReservationRejectAction)),
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
