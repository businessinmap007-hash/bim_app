import '../../../investigations/application/investigations_providers.dart';
import '../../../investigations/presentation/screens/issue_investigation_screen.dart';
import '../../../investigations/presentation/screens/issued_investigations_screen.dart';
import '../../../patient_records/application/patient_records_providers.dart';
import '../../../patient_records/data/patient_record.dart';
import '../../../patient_records/presentation/screens/patient_file_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../prescriptions/presentation/screens/issue_prescription_screen.dart';
import '../../../prescriptions/presentation/screens/prescription_detail_screen.dart';
import '../../application/business_clinic_providers.dart';
import '../../data/models/business_clinic_appointment.dart';
import 'clinic_slots_screen.dart';

/// Api\V2\BusinessClinicAppointmentController — the clinic's own side. Two
/// tabs: the appointments queue (confirm/reject/complete/no-show/reschedule)
/// and slot management lives on its own screen, reached from here.
class ClinicManagementScreen extends StatelessWidget {
  const ClinicManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clinicManagementTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_available_outlined),
            tooltip: l10n.clinicSlotsTab,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClinicSlotsScreen()),
            ),
          ),
        ],
      ),
      body: const _AppointmentsQueue(),
    );
  }
}

const _statuses = ['requested', 'confirmed', 'completed', 'cancelled', 'no_show'];

class _AppointmentsQueue extends ConsumerStatefulWidget {
  const _AppointmentsQueue();

  @override
  ConsumerState<_AppointmentsQueue> createState() => _AppointmentsQueueState();
}

class _AppointmentsQueueState extends ConsumerState<_AppointmentsQueue> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(clinicAppointmentsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(clinicAppointmentsControllerProvider);

    return Column(
      children: [
        _StatusFilterStrip(
          selected: state.status,
          onPick: (status) => ref.read(clinicAppointmentsControllerProvider.notifier).filterByStatus(status),
        ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.commonSomethingWentWrong),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => ref.read(clinicAppointmentsControllerProvider.notifier).load(),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                )
              : state.items.isEmpty
              ? Center(child: Text(l10n.clinicQueueEmpty))
              : RefreshIndicator(
                  onRefresh: () => ref.read(clinicAppointmentsControllerProvider.notifier).load(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _AppointmentTile(appointment: state.items[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _AppointmentTile extends ConsumerStatefulWidget {
  final BusinessClinicAppointment appointment;
  const _AppointmentTile({required this.appointment});

  @override
  ConsumerState<_AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends ConsumerState<_AppointmentTile> {
  bool _busy = false;

  /// Returns whether [action] actually succeeded — callers that show their
  /// own follow-up snackbar (e.g. reschedule) must check this instead of
  /// assuming a completed await means success, since this already swallows
  /// the error here (showing its own message) rather than rethrowing.
  Future<bool> _act(Future<void> Function(int) action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    var succeeded = false;
    try {
      await action(widget.appointment.id);
      succeeded = true;
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    return succeeded;
  }

  Future<void> _reschedule() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: widget.appointment.scheduledAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.appointment.scheduledAt ?? now),
    );
    if (time == null || !mounted) return;

    final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final succeeded = await _act((id) => ref.read(clinicAppointmentsControllerProvider.notifier).reschedule(id, at));
    if (succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.clinicRescheduleConfirm)));
    }
  }

  /// What the doctor just issued is also written into the clinic's OWN file of this patient (on this device), dated
  /// today — the file is created when the patient had none. Nothing here goes to the server.
  Future<void> _keepInFile(List<(RecordKind, String)> items) async {
    if (items.isEmpty) return;
    final a = widget.appointment;
    final phone = (a.attendeeName != null ? a.attendeePhone : a.patientPhone) ?? '';
    final name = a.attendeeName ?? a.patientName ?? '';
    if (name.isEmpty && phone.isEmpty) return;

    final records = ref.read(patientRecordsProvider.notifier);
    final record = records.match(phone: phone, name: name) ?? PatientRecord(id: newRecordId(), name: name, phone: phone, updatedAt: DateTime.now());
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);
    final fresh = [for (final (kind, title) in items) RecordEntry(id: newRecordId(), date: date, kind: kind, title: title)];
    final seen = {for (final e in record.entries) e.fingerprint};

    await records.save(record.copyWith(entries: [...record.entries, for (final e in fresh) if (seen.add(e.fingerprint)) e]));
  }

  /// The clinic's own file of this patient (on this device) — created empty when there is none, then opened.
  Future<void> _openFile() async {
    final a = widget.appointment;
    final phone = (a.attendeeName != null ? a.attendeePhone : a.patientPhone) ?? '';
    final name = a.attendeeName ?? a.patientName ?? '';
    final records = ref.read(patientRecordsProvider.notifier);

    var record = records.match(phone: phone, name: name);
    if (record == null) {
      record = PatientRecord(id: newRecordId(), name: name, phone: phone, updatedAt: DateTime.now());
      await records.save(record);
    }
    if (!mounted) return;

    final id = record.id;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PatientFileScreen(recordId: id)));
  }

  /// One action of the card: full width, 44 high, an icon when it has one — the same outlined button everywhere on
  /// the card, so nothing is a different size or sits crooked beside another.
  Widget _action(
    BuildContext context, {
    required String label,
    IconData? icon,
    required VoidCallback? onPressed,
    bool tonal = false,
    bool primary = false,
    bool danger = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    // a long label shrinks to fit its half of the row instead of being cut
    final text = FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1));
    const size = Size.fromHeight(48);

    // every action is exactly the same height, whichever kind of button it is
    if (primary) {
      return SizedBox(
        height: 48,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.play_arrow_rounded, size: 22),
          label: text,
          style: FilledButton.styleFrom(minimumSize: size, maximumSize: const Size.fromHeight(48), padding: const EdgeInsets.symmetric(horizontal: 12)),
        ),
      );
    }

    if (tonal) {
      return SizedBox(
        height: 48,
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.check_rounded, size: 20),
          label: text,
          style: FilledButton.styleFrom(minimumSize: size, maximumSize: const Size.fromHeight(48), padding: const EdgeInsets.symmetric(horizontal: 12)),
        ),
      );
    }

    final style = OutlinedButton.styleFrom(
      minimumSize: size,
      maximumSize: const Size.fromHeight(48), padding: const EdgeInsets.symmetric(horizontal: 12),
      foregroundColor: danger ? cs.error : null,
      side: danger ? BorderSide(color: cs.error.withValues(alpha: 0.5)) : null,
    );

    return SizedBox(
      height: 48,
      child: icon == null
          ? OutlinedButton(onPressed: onPressed, style: style, child: text)
          : OutlinedButton.icon(onPressed: onPressed, style: style, icon: Icon(icon, size: 20), label: text),
    );
  }

  /// Buttons two to a row, equal width; a last odd one takes the whole row.
  Widget _pairs(List<Widget> buttons) {
    final rows = <Widget>[];
    for (var i = 0; i < buttons.length; i += 2) {
      final pair = buttons.skip(i).take(2).toList();
      rows.add(
        Row(
          children: [
            Expanded(child: pair[0]),
            if (pair.length == 2) ...[const SizedBox(width: 8), Expanded(child: pair[1])],
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: 8), rows[i]],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final a = widget.appointment;

    final records = ref.watch(patientRecordsProvider.notifier);
    ref.watch(patientRecordsProvider);
    final phone = (a.attendeeName != null ? a.attendeePhone : a.patientPhone) ?? '';
    final name = a.attendeeName ?? a.patientName ?? '';
    final hasFile = records.match(phone: phone, name: name) != null;

    final mine = (ref.watch(issuedInvestigationOrdersProvider).valueOrNull ?? const [])
        .where((o) => o.patient?.id == a.patientId)
        .toList();
    final ready = mine.where((o) => o.hasResults).length;

    final notifier = ref.read(clinicAppointmentsControllerProvider.notifier);
    final open = a.status == 'requested' || a.status == 'confirmed';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // who and when
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.patientName ?? '#${a.patientId}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: a.status, l10n: l10n),
              ],
            ),
            if (a.attendeeName != null) ...[
              const SizedBox(height: 4),
              Text(
                [l10n.clinicAttendeeFor(a.attendeeName!), if ((a.attendeePhone ?? '').isNotEmpty) a.attendeePhone!].join(' · '),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            if (a.scheduledAt != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: theme.hintColor),
                  const SizedBox(width: 6),
                  Text(_formatDateTime(a.scheduledAt!), style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
            if (a.reason != null && a.reason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(a.reason!, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ],
            const SizedBox(height: 12),

            // what the doctor does during the visit: two to a row, the same buttons as the state ones below.
            // «افتح الملف عند بدء الكشف»: starting the visit opens the patient file on this device at once
            _pairs([
              if (a.status == 'confirmed') _action(context, primary: true, label: l10n.clinicStartVisit, onPressed: _openFile),
              _action(
                context,
                icon: hasFile ? Icons.folder_shared_outlined : Icons.create_new_folder_outlined,
                label: hasFile ? l10n.patientFileOpen : l10n.clinicCreateFileShort,
                onPressed: _openFile,
              ),
              _action(
                context,
                icon: Icons.receipt_long_outlined,
                label: a.prescriptionId == null ? l10n.clinicWritePrescription : l10n.clinicViewPrescription,
                onPressed: () async {
                  if (a.prescriptionId == null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => IssuePrescriptionScreen(
                          patientId: a.patientId,
                          patientName: a.patientName,
                          appointmentId: a.id,
                          onIssued: (medicines, diagnosis) => _keepInFile([
                            if (diagnosis.isNotEmpty) (RecordKind.visit, diagnosis),
                            for (final m in medicines) (RecordKind.medicine, m),
                          ]),
                        ),
                      ),
                    );
                    notifier.load();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PrescriptionDetailScreen(prescriptionId: a.prescriptionId!)),
                    );
                  }
                },
              ),
              _action(
                context,
                icon: Icons.biotech_outlined,
                label: l10n.invOrderTests,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => IssueInvestigationScreen(
                      patientId: a.patientId,
                      patientName: a.patientName,
                      onIssued: (labs, radiology) => _keepInFile([
                        for (final t in labs) (RecordKind.test, t),
                        for (final t in radiology) (RecordKind.radiology, t),
                      ]),
                    ),
                  ),
                ),
              ),
              // the tests this doctor ordered for this patient, and whether results are in: read on this device
              if (mine.isNotEmpty)
                _action(
                  context,
                  icon: ready > 0 ? Icons.assignment_turned_in_outlined : Icons.assignment_outlined,
                  label: ready > 0 ? l10n.invDoctorOrdersReady(ready) : l10n.invDoctorOrders,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IssuedInvestigationsScreen(patientId: a.patientId, patientName: a.patientName),
                    ),
                  ),
                ),
            ]),

            // the state of the visit — two to a row, the ones that end it marked as such
            if (open) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _pairs([
                if (a.status == 'requested')
                  _action(
                    context,
                    tonal: true,
                    label: l10n.clinicActionConfirm,
                    onPressed: _busy ? null : () => _act((id) => notifier.confirm(id)),
                  ),
                if (a.status == 'confirmed')
                  _action(
                    context,
                    tonal: true,
                    label: l10n.clinicActionComplete,
                    onPressed: _busy ? null : () => _act((id) => notifier.complete(id)),
                  ),
                _action(context, label: l10n.clinicActionReschedule, icon: Icons.event_repeat_outlined, onPressed: _busy ? null : _reschedule),
                if (a.status == 'confirmed')
                  _action(
                    context,
                    danger: true,
                    label: l10n.clinicActionNoShow,
                    onPressed: _busy ? null : () => _act((id) => notifier.noShow(id)),
                  ),
                _action(
                  context,
                  danger: true,
                  label: l10n.clinicActionReject,
                  onPressed: _busy ? null : () => _act((id) => notifier.reject(id)),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

/// The strip of states the queue can be narrowed to: one pill each, the chosen one filled in the primary pair of the
/// theme, the others a soft chip with a dot in the colour of the state they stand for.
class _StatusFilterStrip extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onPick;
  const _StatusFilterStrip({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Widget pill({required String label, required bool on, required VoidCallback onTap, Color? dot, IconData? icon}) {
      final ink = on ? cs.onPrimary : cs.onSurface;

      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: Material(
          color: on ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.55),
          shape: StadiumBorder(side: BorderSide(color: on ? cs.primary : cs.outlineVariant)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 17, color: ink), const SizedBox(width: 6)],
                  if (dot != null && !on) ...[
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                  ],
                  Text(label, style: TextStyle(color: ink, fontSize: 14, fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: cs.surface,
      elevation: 1,
      child: SizedBox(
        height: 58,
        child: MouseWheelHorizontalScroll(
          builder: (context, controller) => ListView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            children: [
              pill(label: l10n.clinicQueueAllStatuses, on: selected == null, icon: Icons.view_agenda_outlined, onTap: () => onPick(null)),
              for (final s in _statuses)
                pill(label: _statusLabel(s, l10n), on: selected == s, dot: _statusColor(s), onTap: () => onPick(s)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;
  const _StatusChip({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status, l10n),
        style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'requested' => l10n.clinicStatusRequested,
  'confirmed' => l10n.clinicStatusConfirmed,
  'completed' => l10n.clinicStatusCompleted,
  'cancelled' => l10n.clinicStatusCancelled,
  'no_show' => l10n.clinicStatusNoShow,
  _ => status,
};

Color _statusColor(String status) => switch (status) {
  'confirmed' || 'completed' => AppColors.success,
  'cancelled' || 'no_show' => AppColors.error,
  _ => AppColors.warning,
};

String _formatDateTime(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
