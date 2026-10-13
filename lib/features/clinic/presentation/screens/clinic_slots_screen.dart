import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/arrival_notice_banner.dart';
import '../../../booking/application/booking_providers.dart';
import '../../../booking/presentation/widgets/booking_grid_widgets.dart';
import '../../../booking/presentation/widgets/booking_shape_tab.dart';
import '../../../specialty_services/application/specialty_services_providers.dart';
import '../../../specialty_services/presentation/widgets/specialty_widgets.dart';
import '../../application/clinic_providers.dart';
import '../../data/models/clinic_appointment.dart' show VisitKindOption;
import '../../data/models/clinic_slot.dart';
import '../../../../core/time/clock_format.dart';

/// A clinic's (or hospital's) open appointment slots, drawn like the «حجز عيادة» canvas board: day chips, a grid of
/// times for the chosen day, a reason box, and a bottom bar that sums up the visit (kind, date and time, price) with
/// the one booking button. Booking confirms it at once (no back-and-forth with the clinic). See
/// Api\V2\ClinicAppointmentController.
class ClinicSlotsScreen extends StatelessWidget {
  final int clinicId;
  final String clinicName;

  /// A specialty clinic that listed its services: the patient says which one he came for.
  final bool hasServices;

  const ClinicSlotsScreen({super.key, required this.clinicId, required this.clinicName, this.hasServices = false});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(clinicName)),
    body: ClinicBookingBoard(clinicId: clinicId, hasServices: hasServices),
  );
}

/// The booking board itself: visit kind, under it the service the patient came for (a specialty clinic that listed
/// them), the day, the time, who the visit is for and the bar that books. It is the clinic page's «الحجز» tab
/// ([embedded]: scrolls with the page's header) and the body of [ClinicSlotsScreen] for a link that opens it alone.
class ClinicBookingBoard extends ConsumerStatefulWidget {
  final int clinicId;
  final bool hasServices;
  final bool embedded;

  const ClinicBookingBoard({super.key, required this.clinicId, this.hasServices = false, this.embedded = false});

  @override
  ConsumerState<ClinicBookingBoard> createState() => _ClinicBookingBoardState();
}

class _ClinicBookingBoardState extends ConsumerState<ClinicBookingBoard> {
  String? _kind;
  DateTime? _day;
  int? _slotId;
  final Set<int> _serviceIds = {};
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
      await ref
          .read(clinicApiProvider)
          .bookSlot(
            slot.id,
            reason: _reason.text.trim(),
            specialtyServiceIds: _serviceIds.toList(),
            forName: _forOther ? _forName.text.trim() : null,
            forPhone: _forOther ? _forPhone.text.trim() : null,
          );
      ref.invalidate(clinicSlotsProvider(widget.clinicId));
      if (!mounted) return;
      setState(() {
        _slotId = null;
        _serviceIds.clear();
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

  /// What the bar says above the date: the visit kind and the services picked, or the hint before a time is picked.
  String _summary(ClinicSlot? slot, String serviceNames, AppLocalizations l10n) {
    if (slot == null) return l10n.clinicPickSlotHint;

    final kind = slot.visitKind;
    return [if (kind != null && kind.isNotEmpty) kind, if (serviceNames.isNotEmpty) serviceNames].join(' — ');
  }

  /// The names of the services picked, in the order they are listed, for the summary bar.
  String _pickedServiceNames() {
    if (_serviceIds.isEmpty || !widget.hasServices) return '';

    final sections = ref.read(specialtyServicesProvider(widget.clinicId)).valueOrNull ?? const [];
    return sections.expand((s) => s.services).where((p) => _serviceIds.contains(p.id)).map((p) => p.name).join('، ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(clinicSlotsProvider(widget.clinicId));

    return async.when(
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
        final dated = slots.where((s) => s.startsAt != null).toList()
          ..sort((a, b) => a.startsAt!.compareTo(b.startsAt!));
        if (dated.isEmpty) return Center(child: Text(l10n.clinicNoOpenSlots));

        // EVERY visit kind the clinic prices («كشف · استشارة · متابعة · إجراء طبي…») is a radio option, one only; a kind with
        // no open time shows but cannot be picked. A clinic that prices none falls back to the kinds its slots carry.
        final options = ref.watch(clinicVisitKindsProvider(widget.clinicId)).valueOrNull?.kinds ?? const <VisitKindOption>[];
        final byKey = options.isNotEmpty;
        final choices = <_KindChoice>[
          if (byKey)
            for (final o in options)
              _KindChoice(
                id: o.key,
                label: o.name,
                price: o.price,
                enabled: dated.any((s) => s.visitKindKey == o.key || s.visitKindKey == null),
              )
          else
            for (final k in {
              for (final s in dated)
                if ((s.visitKind ?? '').isNotEmpty) s.visitKind!,
            })
              _KindChoice(id: k, label: k, price: dated.where((s) => s.visitKind == k).map((s) => s.price).whereType<double>().firstOrNull),
        ];
        final enabledIds = [for (final c in choices) if (c.enabled) c.id];
        final kind = choices.isEmpty ? null : (enabledIds.contains(_kind) ? _kind : (enabledIds.isEmpty ? null : enabledIds.first));
        final ofKind = kind == null
            ? (choices.isEmpty ? dated : <ClinicSlot>[])
            : dated.where((s) => byKey ? (s.visitKindKey == kind || s.visitKindKey == null) : s.visitKind == kind).toList();
        if (ofKind.isEmpty) return Center(child: Text(l10n.clinicNoOpenSlots));

        final days = <DateTime>[];
        for (final s in ofKind) {
          final d = _dateOnly(s.startsAt!);
          if (!days.contains(d)) days.add(d);
        }
        final day = _day != null && days.contains(_day) ? _day! : days.first;
        final times = ofKind.where((s) => _dateOnly(s.startsAt!) == day).toList();
        final picked = times.where((s) => s.id == _slotId).firstOrNull;

        final children = <Widget>[
          // the clinic's own «be there N minutes early», before the patient picks a time
          Builder(
            builder: (context) {
              final notice = ref.watch(bookingFormProvider(widget.clinicId)).valueOrNull?.arrivalNotice;
              if ((notice ?? '').isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArrivalNoticeBanner(message: notice),
              );
            },
          ),
          // what he still owes this clinic from earlier visits — asked with the next session
          Builder(
            builder: (context) {
              final r = ref.watch(clinicVisitKindsProvider(widget.clinicId)).valueOrNull;
              if (r == null || r.balance <= 0) return const SizedBox.shrink();

              String money(double v) => '${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)} ${l10n.invCurrency}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(
                  title: l10n.billOwedTitle,
                  child: Text(l10n.billOwedBody(money(r.balance), money(r.balanceDue > 0 ? r.balanceDue : r.balance))),
                ),
              );
            },
          ),
          if (choices.isNotEmpty) ...[
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
                    for (final c in choices)
                      RadioListTile<String>(
                        value: c.id,
                        enabled: c.enabled,
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.label),
                        subtitle: c.enabled ? null : Text(l10n.clinicKindNoSlots),
                        secondary: c.price == null
                            ? null
                            : Text(
                                '${c.price!.toStringAsFixed(c.price! % 1 == 0 ? 0 : 2)} ${l10n.invCurrency}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.hasServices) ...[
            _ServicePicker(
              clinicId: widget.clinicId,
              selected: _serviceIds,
              onToggle: (id, on) => setState(() => on ? _serviceIds.add(id) : _serviceIds.remove(id)),
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
                    label: ClockFormat.time(context, s.startsAt!),
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
                          builder: (ink) => Text(
                            l10n.clinicForMe,
                            style: TextStyle(fontWeight: FontWeight.w600, color: ink),
                          ),
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
                          builder: (ink) => Text(
                            l10n.clinicForOther,
                            style: TextStyle(fontWeight: FontWeight.w600, color: ink),
                          ),
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
        ];

        final bar = BookingSummaryBar(
          summary: _summary(picked, _pickedServiceNames(), l10n),
          when: picked?.startsAt == null ? null : DateFormat.MMMEd(locale).add_jm().format(picked!.startsAt!),
          price: picked?.price,
          label: l10n.clinicRequestBooking,
          busy: _booking,
          onPressed: picked == null || (_forOther && _forName.text.trim().isEmpty) ? null : () => _book(picked),
        );

        // as a tab it scrolls under the page's header; alone it is a plain padded list above the bar
        if (widget.embedded) return BoardScaffold(bottom: bar, children: children);

        return Column(
          children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: children),
            ),
            bar,
          ],
        );
      },
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// One radio option of the visit-kind list.
class _KindChoice {
  final String id;
  final String label;
  final double? price;
  final bool enabled;

  const _KindChoice({required this.id, required this.label, this.price, this.enabled = true});
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
      builder: (ink) => Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      ),
    );
  }
}

/// «اختر الخدمات المطلوبة»: the services a specialty clinic listed, by kind, each with its price. Optional, and several
/// may be picked — tap one again to take it off.
class _ServicePicker extends ConsumerWidget {
  final int clinicId;
  final Set<int> selected;
  final void Function(int id, bool on) onToggle;

  const _ServicePicker({required this.clinicId, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sections = ref.watch(specialtyServicesProvider(clinicId)).valueOrNull ?? const [];
    if (sections.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: l10n.clinicPickService,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in sections) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Text(
                specialtyKindLabel(l10n, s.kind),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in s.services)
                  ChoiceChip(
                    label: Text(
                      p.price == null ? p.name : '${p.name} · ${formatServiceMoney(p.price!)} ${l10n.invCurrency}',
                    ),
                    selected: selected.contains(p.id),
                    onSelected: (on) => onToggle(p.id, on),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
