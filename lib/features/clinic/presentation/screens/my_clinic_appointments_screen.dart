import '../../../../shared/widgets/arrival_notice_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/guarantee_badge/widgets/account_name.dart';

import '../../../../core/deposit/visit_deposit.dart';
import '../../../../core/deposit/widgets/visit_deposit_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/clinic_providers.dart';
import '../../data/models/clinic_appointment.dart';
import '../../../prescriptions/presentation/screens/prescription_detail_screen.dart';
import '../../../../core/time/clock_format.dart';

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
        title: AccountName(text: appointment.clinicName ?? '', userId: appointment.clinicId),
        subtitle: Text(
          '${appointment.physicianLine != null ? '${l10n.clinicWithPhysician(appointment.physicianLine!)}\n' : ''}'
          '${_statusLabel(appointment.status, l10n)}'
          '${appointment.scheduledAt != null ? ' · ${_formatDateTime(context, appointment.scheduledAt!)}' : ''}'
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
      // what the clinic recorded as paid: the patient says yes, or no — so neither side forgets or denies
      if (appointment.billing != null && appointment.billing!.payments.isNotEmpty) _PaymentsBlock(appointment: appointment),
      // the clinic's own «be there N minutes early» while the appointment still stands
      if ((appointment.arrivalNotice ?? '').isNotEmpty && appointment.isCancellable)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ArrivalNoticeBanner(message: appointment.arrivalNotice),
        ),
      // «عربون الجدية»: what the clinic asks and where it stands
      if (appointment.deposit != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Consumer(
            builder: (context, ref, _) => VisitDepositCard(
              deposit: appointment.deposit!,
              kind: VisitKind.clinicAppointment,
              subjectId: appointment.id,
              forBusiness: false,
              visitEnded: appointment.status == 'no_show',
              onChanged: () => ref.read(myClinicAppointmentsControllerProvider.notifier).load(),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime dt) => ClockFormat.dateTime(context, dt);

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
    if (b.carriedOver > 0) '${l10n.billCarriedOver} ${_money(b.carriedOverDue > 0 ? b.carriedOverDue : b.carriedOver, l10n)}',
    if (!b.servicesPending && b.services.isNotEmpty) '${l10n.billServices} ${_money(b.servicesTotal, l10n)}',
    '${l10n.billPaid} ${_money(b.paid, l10n)}',
    '${l10n.billRemaining} ${_money(b.remaining, l10n)}',
  ].join(' · ');
}

/// The payments the clinic recorded against this visit; each waits for the patient's yes — or his no, with a word.
class _PaymentsBlock extends ConsumerWidget {
  final ClinicAppointment appointment;
  const _PaymentsBlock({required this.appointment});

  Future<void> _dispute(BuildContext context, WidgetRef ref, VisitPayment p) async {
    final l10n = AppLocalizations.of(context)!;
    final note = await showDialog<String>(context: context, builder: (_) => const _DisputeDialog());
    if (note == null) return;

    try {
      await ref.read(myClinicAppointmentsControllerProvider.notifier).disputePayment(appointment.id, p.id, note: note);
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final b = appointment.billing!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final p in b.payments)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(
                    switch (p.confirmation) {
                      'confirmed' => Icons.verified_outlined,
                      'disputed' => Icons.report_gmailerrorred_outlined,
                      _ => Icons.hourglass_empty_rounded,
                    },
                    size: 18,
                    color: switch (p.confirmation) {
                      'confirmed' => Colors.green,
                      'disputed' => theme.colorScheme.error,
                      _ => theme.hintColor,
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_money(p.amount, l10n)} · ${p.kind == 'visit_fee' ? l10n.billKindVisitFee : l10n.billKindService}'
                      '${(p.note ?? '').isNotEmpty ? ' · ${p.note}' : ''}'
                      ' · ${switch (p.confirmation) {
                        'confirmed' => l10n.billConfirmed,
                        'disputed' => l10n.billDisputed,
                        _ => l10n.billAwaitingYou,
                      }}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (p.confirmation == 'pending') ...[
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref.read(myClinicAppointmentsControllerProvider.notifier).confirmPayment(appointment.id, p.id);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
                          }
                        }
                      },
                      child: Text(l10n.billConfirm),
                    ),
                    TextButton(onPressed: () => _dispute(context, ref, p), child: Text(l10n.billDispute)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The patient's word on a payment he did not make; owns its controller.
class _DisputeDialog extends StatefulWidget {
  const _DisputeDialog();

  @override
  State<_DisputeDialog> createState() => _DisputeDialogState();
}

class _DisputeDialogState extends State<_DisputeDialog> {
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
      title: Text(l10n.billDispute),
      content: TextField(
        controller: _note,
        autofocus: true,
        maxLines: 2,
        decoration: InputDecoration(labelText: l10n.billDisputeNote),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(_note.text.trim()), child: Text(l10n.billDispute)),
      ],
    );
  }
}
