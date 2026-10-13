import '../../../../shared/widgets/arrival_notice_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/clinic_providers.dart';
import '../../data/models/clinic_appointment.dart';
import '../../../prescriptions/presentation/screens/prescription_detail_screen.dart';

class MyClinicAppointmentsScreen extends ConsumerStatefulWidget {
  const MyClinicAppointmentsScreen({super.key});

  @override
  ConsumerState<MyClinicAppointmentsScreen> createState() => _MyClinicAppointmentsScreenState();
}

class _MyClinicAppointmentsScreenState extends ConsumerState<MyClinicAppointmentsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myClinicAppointmentsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cancel(ClinicAppointment appointment) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.clinicAppointmentCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.clinicAppointmentCancel)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(myClinicAppointmentsControllerProvider.notifier).cancel(appointment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.clinicAppointmentCancelled)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myClinicAppointmentsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myClinicAppointmentsTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(myClinicAppointmentsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.myClinicAppointmentsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myClinicAppointmentsControllerProvider.notifier).load(),
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
                  final appointment = state.items[index];
                  return _AppointmentTile(appointment: appointment, onCancel: () => _cancel(appointment));
                },
              ),
            ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final ClinicAppointment appointment;
  final VoidCallback onCancel;
  const _AppointmentTile({required this.appointment, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
      ListTile(
        leading: CircleAvatar(
          backgroundImage: appointment.clinicLogoUrl != null ? NetworkImage(appointment.clinicLogoUrl!) : null,
          child: appointment.clinicLogoUrl == null ? const Icon(Icons.local_hospital_outlined) : null,
        ),
        title: Text(appointment.clinicName ?? ''),
        subtitle: Text(
          '${_statusLabel(appointment.status, l10n)}'
          '${appointment.scheduledAt != null ? ' · ${_formatDateTime(appointment.scheduledAt!)}' : ''}'
          '${appointment.servicesLine.isNotEmpty ? '\n${appointment.servicesLine}' : ''}'
          '${_billingLine(appointment, l10n).isNotEmpty ? '\n${_billingLine(appointment, l10n)}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (appointment.prescriptionId != null)
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PrescriptionDetailScreen(prescriptionId: appointment.prescriptionId!)),
                ),
                child: Text(l10n.clinicViewPrescription),
              ),
            if (appointment.isCancellable)
              TextButton(onPressed: onCancel, child: Text(l10n.clinicAppointmentCancel)),
          ],
        ),
        isThreeLine: false,
      ),
      // the clinic's own «be there N minutes early» while the appointment still stands
      if ((appointment.arrivalNotice ?? '').isNotEmpty && appointment.isCancellable)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ArrivalNoticeBanner(message: appointment.arrivalNotice),
        ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'requested' => l10n.clinicStatusRequested,
  'confirmed' => l10n.clinicStatusConfirmed,
  'completed' => l10n.clinicStatusCompleted,
  'cancelled' => l10n.clinicStatusCancelled,
  'no_show' => l10n.clinicStatusNoShow,
  _ => status,
};

String _money(double v, AppLocalizations l10n) => '${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ${l10n.invCurrency}';

/// «رسم الزيارة ٣٠٠ · المدفوع ٣٠٠ · المتبقي ٠» — the services' cost joins the total once the visit is done.
String _billingLine(ClinicAppointment a, AppLocalizations l10n) {
  final b = a.billing;
  if (b == null || (a.status != 'confirmed' && a.status != 'completed')) return '';

  return [
    if (b.visitFee != null) '${l10n.billVisitFee} ${_money(b.visitFee!, l10n)}',
    if (!b.servicesPending && b.services.isNotEmpty) '${l10n.billServices} ${_money(b.servicesTotal, l10n)}',
    '${l10n.billPaid} ${_money(b.paid, l10n)}',
    '${l10n.billRemaining} ${_money(b.remaining, l10n)}',
  ].join(' · ');
}
