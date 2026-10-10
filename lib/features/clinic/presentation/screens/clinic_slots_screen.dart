import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/clinic_providers.dart';
import '../../data/models/clinic_slot.dart';

/// A clinic's (or hospital's) open appointment slots, drawn like the «حجز عيادة» canvas board: day chips, a grid of
/// times for the chosen day, a reason box, and a bottom bar that sums up the visit (kind, date and time, price) with
/// the one booking button. Booking confirms it at once (no back-and-forth with the clinic). See
/// Api\V2\ClinicAppointmentController.
class ClinicSlotsScreen extends ConsumerStatefulWidget {
  final int clinicId;
  final String clinicName;

  const ClinicSlotsScreen({super.key, required this.clinicId, required this.clinicName});

  @override
  ConsumerState<ClinicSlotsScreen> createState() => _ClinicSlotsScreenState();
}

class _ClinicSlotsScreenState extends ConsumerState<ClinicSlotsScreen> {
  String? _kind;
  DateTime? _day;
  int? _slotId;
  bool _booking = false;
  bool _forOther = false;
  final _reason = TextEditingController();
  final _forName = TextEditingController();
  final _forPhone = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    _forName.dispose();
    _forPhone.dispose();
    super.dispose();
  }

  Future<void> _book(ClinicSlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _booking = true);
    try {
      await ref.read(clinicApiProvider).bookSlot(
        slot.id,
        reason: _reason.text.trim(),
        forName: _forOther ? _forName.text.trim() : null,
        forPhone: _forOther ? _forPhone.text.trim() : null,
      );
      ref.invalidate(clinicSlotsProvider(widget.clinicId));
      if (!mounted) return;
      setState(() {
        _slotId = null;
        _reason.clear();
        _forOther = false;
        _forName.clear();
        _forPhone.clear();
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.clinicAppointmentBooked)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(clinicSlotsProvider(widget.clinicId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.clinicName)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(clinicSlotsProvider(widget.clinicId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (slots) {
          final dated = slots.where((s) => s.startsAt != null).toList()..sort((a, b) => a.startsAt!.compareTo(b.startsAt!));
          if (dated.isEmpty) return Center(child: Text(l10n.clinicNoOpenSlots));

          // the visit kinds on offer («كشف / إعادة / استشارة»): the patient picks one, and only its days and times remain
          final kinds = <String>[];
          for (final s in dated) {
            final k = s.visitKind;
            if (k != null && k.isNotEmpty && !kinds.contains(k)) kinds.add(k);
          }
          final kind = kinds.isEmpty ? null : (kinds.contains(_kind) ? _kind : kinds.first);
          final ofKind = kind == null ? dated : dated.where((s) => s.visitKind == kind).toList();

          final days = <DateTime>[];
          for (final s in ofKind) {
            final d = _dateOnly(s.startsAt!);
            if (!days.contains(d)) days.add(d);
          }
          final day = _day != null && days.contains(_day) ? _day! : days.first;
          final times = ofKind.where((s) => _dateOnly(s.startsAt!) == day).toList();
          final picked = times.where((s) => s.id == _slotId).firstOrNull;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (kinds.isNotEmpty) ...[
                      _SectionCard(
                        title: l10n.clinicPickKind,
                        child: RadioGroup<String>(
                          groupValue: kind,
                          onChanged: (k) => setState(() {
                            _kind = k;
                            _day = null;
                            _slotId = null;
                          }),
                          child: Column(
                            children: [
                              for (final k in kinds)
                                RadioListTile<String>(
                                  value: k,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(k),
                                  secondary: _kindPrice(dated, k, l10n.invCurrency),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _SectionCard(
                      title: l10n.clinicPickDay,
                      child: SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) => _DayChip(
                            day: days[i],
                            selected: days[i] == day,
                            onTap: () => setState(() {
                              _day = days[i];
                              _slotId = null;
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: l10n.clinicPickTime,
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.4,
                        children: [
                          for (final s in times)
                            _TimeChip(
                              label: DateFormat.jm(locale).format(s.startsAt!),
                              selected: s.id == _slotId,
                              onTap: () => setState(() => _slotId = s.id),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: l10n.clinicPatientLabel,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: _Chip(
                                    selected: !_forOther,
                                    onTap: () => setState(() => _forOther = false),
                                    builder: (ink) => Text(l10n.clinicForMe, style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: _Chip(
                                    selected: _forOther,
                                    onTap: () => setState(() => _forOther = true),
                                    builder: (ink) => Text(l10n.clinicForOther, style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_forOther) ...[
                            const SizedBox(height: 10),
                            TextField(
                              controller: _forName,
                              decoration: InputDecoration(labelText: l10n.clinicAttendeeName),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _forPhone,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(labelText: l10n.clinicAttendeePhone),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reason,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: l10n.clinicReasonHint),
                    ),
                  ],
                ),
              ),
              _SummaryBar(
                slot: picked,
                busy: _booking,
                onBook: picked == null || (_forOther && _forName.text.trim().isEmpty) ? null : () => _book(picked),
              ),
            ],
          );
        },
      ),
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// What a visit kind costs: the price its first open slot carries.
Widget? _kindPrice(List<ClinicSlot> slots, String kind, String currency) {
  final price = slots.where((s) => s.visitKind == kind).map((s) => s.price).whereType<double>().firstOrNull;
  if (price == null) return null;

  return Text('${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)} $currency', style: const TextStyle(fontWeight: FontWeight.w600));
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// Active = the theme's primary pair (navy with gold ink in light, gold with navy ink in dark); idle = a bordered chip.
class _Chip extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget Function(Color ink) builder;
  const _Chip({required this.selected, required this.onTap, required this.builder});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ink = selected ? cs.onPrimary : cs.onSurface;

    return Material(
      color: selected ? cs.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(child: builder(ink)),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final VoidCallback onTap;
  const _DayChip({required this.day, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return SizedBox(
      width: 62,
      child: _Chip(
        selected: selected,
        onTap: onTap,
        builder: (ink) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat.E(locale).format(day), style: TextStyle(fontSize: 11, color: ink)),
            Text(
              DateFormat.d(locale).format(day),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TimeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Chip(
      selected: selected,
      onTap: onTap,
      builder: (ink) => Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final ClinicSlot? slot;
  final bool busy;
  final VoidCallback? onBook;
  const _SummaryBar({required this.slot, required this.busy, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final s = slot;
    final kind = s?.visitKind;
    final startsAt = s?.startsAt;
    final summary = s == null
        ? l10n.clinicPickSlotHint
        : [
            if (kind != null && kind.isNotEmpty) kind,
            if (startsAt != null) DateFormat.MMMEd(locale).add_jm().format(startsAt),
          ].join(' — ');
    final price = s?.price;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(summary, style: theme.textTheme.bodyMedium)),
                  if (price != null)
                    Text(
                      '${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)} ${l10n.invCurrency}',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: busy ? null : onBook,
                child: busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.clinicRequestBooking),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
