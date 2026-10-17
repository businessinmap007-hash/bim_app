import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../booking_settings/application/booking_settings_controller.dart';
import '../../../booking_settings/data/models/booking_settings_models.dart';
import '../../application/booking_providers.dart' show bookingApiProvider;
import '../../data/booking_api.dart' show CustomerLookup;

/// «جاء عميل بدون حجز»: the business books a customer who is standing there. If the phone belongs to an account the
/// booking is recorded on that account (with his history); otherwise it is a NAMED guest — never counted, never rated.
class GuestBookingScreen extends ConsumerStatefulWidget {
  const GuestBookingScreen({super.key});

  @override
  ConsumerState<GuestBookingScreen> createState() => _GuestBookingScreenState();
}

class _GuestBookingScreenState extends ConsumerState<GuestBookingScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  PriceRow? _offering;
  BookableItemRow? _unit;
  DateTime? _start;
  DateTime? _end;
  int _people = 1;

  CustomerLookup? _lookup;
  bool _looking = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _doLookup() async {
    final phone = _phone.text.trim();
    if (phone.length < 8) return;

    setState(() => _looking = true);
    try {
      final found = await ref.read(bookingApiProvider).customerLookup(phone);
      if (mounted) setState(() => _lookup = found);
    } catch (_) {
      if (mounted) setState(() => _lookup = null);
    } finally {
      if (mounted) setState(() => _looking = false);
    }
  }

  Future<DateTime?> _pick(DateTime? initial) async {
    final day = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (day == null || !mounted) return null;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()));
    if (time == null) return null;

    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final hasAccount = _lookup?.found == true;

    if (_offering == null || _start == null || (!hasAccount && _name.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(bookingApiProvider).createForGuest(
        serviceId: _offering!.serviceId,
        offeringId: _offering!.id,
        bookableId: _unit?.id,
        startsAt: _start,
        endsAt: _end,
        partySize: _people,
        notes: _notes.text.trim(),
        guestName: _name.text.trim(),
        guestPhone: _phone.text.trim(),
        clientId: hasAccount ? _lookup!.customerId : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.guestBookingDone)));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _when(DateTime t) => t.toString().substring(0, 16);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(bookingSettingsControllerProvider);
    final hasAccount = _lookup?.found == true;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guestBookingTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.guestPhoneLabel,
              helperText: l10n.guestPhoneHint,
              suffixIcon: _looking
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                  : IconButton(icon: const Icon(Icons.search), tooltip: l10n.guestLookupAction, onPressed: _doLookup),
            ),
            onChanged: (_) => setState(() => _lookup = null),
            onSubmitted: (_) => _doLookup(),
          ),
          const SizedBox(height: 8),
          if (_lookup != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: hasAccount
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.guestAccountFound(_lookup!.name ?? ''), style: theme.textTheme.titleSmall),
                        if (_lookup!.previousDealings > 0) ...[
                          const SizedBox(height: 6),
                          Chip(
                            avatar: const Icon(Icons.verified_outlined, size: 16),
                            label: Text(l10n.returningCustomerBadge(_lookup!.previousDealings)),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    )
                  : Text(l10n.guestNoAccount, style: theme.textTheme.bodySmall),
            ),
          if (!hasAccount) ...[
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.guestNameLabel)),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<PriceRow>(
            initialValue: _offering,
            decoration: InputDecoration(labelText: l10n.guestOfferingLabel),
            items: [
              for (final p in settings.prices.where((p) => p.isActive))
                DropdownMenuItem(value: p, child: Text(p.label, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => _offering = v),
          ),
          if (settings.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<BookableItemRow>(
              initialValue: _unit,
              decoration: InputDecoration(labelText: l10n.guestUnitLabel),
              items: [
                for (final u in settings.items.where((u) => u.isActive))
                  DropdownMenuItem(value: u, child: Text(u.label, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _unit = v),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.event_outlined),
            label: Text(_start == null ? l10n.guestStartLabel : '${l10n.guestStartLabel}: ${_when(_start!)}'),
            onPressed: () async {
              final picked = await _pick(_start);
              if (picked != null) setState(() => _start = picked);
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.event_available_outlined),
            label: Text(_end == null ? l10n.guestEndLabel : '${l10n.guestEndLabel}: ${_when(_end!)}'),
            onPressed: () async {
              final picked = await _pick(_end ?? _start);
              if (picked != null) setState(() => _end = picked);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(l10n.guestPartySizeLabel)),
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _people > 1 ? () => setState(() => _people--) : null),
              Text('$_people'),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _people++)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(controller: _notes, maxLines: 2, decoration: InputDecoration(labelText: l10n.businessBookingsNotes)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.guestBookingAction),
          ),
        ],
      ),
    );
  }
}
