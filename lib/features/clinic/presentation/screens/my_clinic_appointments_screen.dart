import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/clinic_providers.dart';
import '../../data/models/clinic_appointment.dart';

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
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: appointment.clinicLogoUrl != null ? NetworkImage(appointment.clinicLogoUrl!) : null,
          child: appointment.clinicLogoUrl == null ? const Icon(Icons.local_hospital_outlined) : null,
        ),
        title: Text(appointment.clinicName ?? ''),
        subtitle: Text(
          '${_statusLabel(appointment.status, l10n)}'
          '${appointment.scheduledAt != null ? ' · ${_formatDateTime(appointment.scheduledAt!)}' : ''}',
        ),
        trailing: appointment.isCancellable
            ? TextButton(onPressed: onCancel, child: Text(l10n.clinicAppointmentCancel))
            : null,
        isThreeLine: false,
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'requested' => l10n.clinicStatusRequested,
  'confirmed' => l10n.clinicStatusConfirmed,
  'completed' => l10n.clinicStatusCompleted,
  'cancelled' => l10n.clinicStatusCancelled,
  'no_show' => l10n.clinicStatusNoShow,
  _ => status,
};
