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
        SizedBox(
          height: 44,
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l10n.clinicQueueAllStatuses),
                    selected: state.status == null,
                    onSelected: (_) => ref.read(clinicAppointmentsControllerProvider.notifier).filterByStatus(null),
                  ),
                ),
                for (final s in _statuses)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_statusLabel(s, l10n)),
                      selected: state.status == s,
                      onSelected: (_) => ref.read(clinicAppointmentsControllerProvider.notifier).filterByStatus(s),
                    ),
                  ),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final a = widget.appointment;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(a.patientName ?? '#${a.patientId}', style: Theme.of(context).textTheme.titleSmall),
                ),
                _StatusChip(status: a.status, l10n: l10n),
              ],
            ),
            if (a.scheduledAt != null) ...[
              const SizedBox(height: 4),
              Text(_formatDateTime(a.scheduledAt!)),
            ],
            if (a.reason != null && a.reason!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(a.reason!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: Text(a.prescriptionId == null ? l10n.clinicWritePrescription : l10n.clinicViewPrescription),
                onPressed: () async {
                  if (a.prescriptionId == null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => IssuePrescriptionScreen(
                          patientId: a.patientId,
                          patientName: a.patientName,
                          appointmentId: a.id,
                        ),
                      ),
                    );
                    ref.read(clinicAppointmentsControllerProvider.notifier).load();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PrescriptionDetailScreen(prescriptionId: a.prescriptionId!),
                      ),
                    );
                  }
                },
              ),
            ),
            if (a.status == 'requested' || a.status == 'confirmed') ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (a.status == 'requested')
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _act((id) => ref.read(clinicAppointmentsControllerProvider.notifier).confirm(id)),
                      child: Text(l10n.clinicActionConfirm),
                    ),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _act((id) => ref.read(clinicAppointmentsControllerProvider.notifier).reject(id)),
                    child: Text(l10n.clinicActionReject),
                  ),
                  OutlinedButton(
                    onPressed: _busy ? null : _reschedule,
                    child: Text(l10n.clinicActionReschedule),
                  ),
                  if (a.status == 'confirmed') ...[
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _act((id) => ref.read(clinicAppointmentsControllerProvider.notifier).complete(id)),
                      child: Text(l10n.clinicActionComplete),
                    ),
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _act((id) => ref.read(clinicAppointmentsControllerProvider.notifier).noShow(id)),
                      child: Text(l10n.clinicActionNoShow),
                    ),
                  ],
                ],
              ),
            ],
          ],
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
