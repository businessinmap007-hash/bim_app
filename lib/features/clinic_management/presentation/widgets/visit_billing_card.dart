import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clinic/data/models/clinic_appointment.dart';
import '../../../specialty_services/presentation/widgets/specialty_widgets.dart' show formatServiceMoney;
import '../../application/business_clinic_providers.dart';
import '../../data/models/business_clinic_appointment.dart';

/// The money of one visit, on the clinic's side: the visit fee (paid on arrival), the services the patient named
/// (charged once the visit is done, and the clinic may raise or lower each), what was paid — one row per payment, so a
/// treatment paid in instalments reads as it happened — and what is left. The staff record payments here; the doctor
/// reads them, and so does the patient.
class VisitBillingCard extends ConsumerStatefulWidget {
  final BusinessClinicAppointment appointment;
  const VisitBillingCard({super.key, required this.appointment});

  @override
  ConsumerState<VisitBillingCard> createState() => _VisitBillingCardState();
}

class _VisitBillingCardState extends ConsumerState<VisitBillingCard> {
  bool _busy = false;

  String _money(AppLocalizations l10n, double v) => '${formatServiceMoney(v)} ${l10n.invCurrency}';

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _record() async {
    final first = (widget.appointment.billing?.paid ?? 0) == 0;

    final r = await showModalBottomSheet<({double amount, String kind, String note})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PaymentSheet(initialKind: first ? 'visit_fee' : 'service'),
    );
    if (r == null || !mounted) return;

    await _run(() => ref.read(clinicAppointmentsControllerProvider.notifier).recordPayment(widget.appointment.id, r.amount, r.kind, r.note));
  }

  Future<void> _editPrice(BillingService line) async {
    // a record: the value typed, or none (null inside = back to the listed price)
    final r = await showDialog<({double? value})>(
      context: context,
      builder: (_) => _PriceDialog(line: line),
    );
    if (r == null || !mounted) return;

    await _run(() => ref.read(clinicAppointmentsControllerProvider.notifier).setFinalPrice(widget.appointment.id, line.itemId, r.value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final b = widget.appointment.billing;
    if (b == null) return const SizedBox.shrink();
    final canPay = widget.appointment.status == 'confirmed' || widget.appointment.status == 'completed';

    Widget row(String label, String value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.w700 : null))),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (b.visitFee != null) row(l10n.billVisitFee, _money(l10n, b.visitFee!)),
          for (final s in b.services)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(s.name, style: theme.textTheme.bodyMedium)),
                  Text(
                    s.counted && s.amount != null
                        ? _money(l10n, s.amount!)
                        : (s.price == null ? l10n.specialtyPriceAfterExam : _money(l10n, s.price!)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: s.counted ? FontWeight.w700 : FontWeight.w400,
                      color: s.counted ? null : theme.hintColor,
                    ),
                  ),
                  if (canPay)
                    IconButton(
                      tooltip: l10n.billFinalPrice,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: _busy ? null : () => _editPrice(s),
                    ),
                ],
              ),
            ),
          if (b.servicesPending && b.services.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Text(l10n.billServicesAfterVisit, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ),
          const Divider(height: 16),
          row(l10n.billTotal, _money(l10n, b.total), bold: true),
          row(l10n.billPaid, _money(l10n, b.paid)),
          row(l10n.billRemaining, _money(l10n, b.remaining), bold: true),
          if (b.payments.isNotEmpty) ...[
            const Divider(height: 16),
            for (final p in b.payments)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        [
                          p.kind == 'visit_fee' ? l10n.billKindVisitFee : l10n.billKindService,
                          if (p.paidAt != null) DateFormat.MMMd(locale).add_jm().format(p.paidAt!),
                          if ((p.note ?? '').isNotEmpty) p.note!,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ),
                    Text(_money(l10n, p.amount), style: theme.textTheme.bodyMedium),
                    IconButton(
                      tooltip: l10n.commonDelete,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: _busy
                          ? null
                          : () => _run(() => ref.read(clinicAppointmentsControllerProvider.notifier).removePayment(widget.appointment.id, p.id)),
                    ),
                  ],
                ),
              ),
          ],
          if (canPay) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _record,
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.billRecordPayment),
            ),
          ],
        ],
      ),
    );
  }
}

/// The sheet that records a payment: its kind (the fee, or a service), the amount, a note. Owns its controllers.
class _PaymentSheet extends StatefulWidget {
  final String initialKind;
  const _PaymentSheet({required this.initialKind});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late String _kind = widget.initialKind;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) return;

    Navigator.of(context).pop((amount: value, kind: _kind, note: _note.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.billRecordPayment, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.billKindVisitFee),
                    selected: _kind == 'visit_fee',
                    onSelected: (_) => setState(() => _kind = 'visit_fee'),
                  ),
                  ChoiceChip(
                    label: Text(l10n.billKindService),
                    selected: _kind == 'service',
                    onSelected: (_) => setState(() => _kind = 'service'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.billAmount, suffixText: l10n.invCurrency),
              ),
              const SizedBox(height: 8),
              TextField(controller: _note, decoration: InputDecoration(labelText: l10n.billNote)),
              const SizedBox(height: 16),
              FilledButton(onPressed: _submit, child: Text(l10n.billRecordPayment)),
            ],
          ),
        ),
      ),
    );
  }
}

/// What a service is finally charged: a number, or empty for the listed price. Owns its controller.
class _PriceDialog extends StatefulWidget {
  final BillingService line;
  const _PriceDialog({required this.line});

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late final _c = TextEditingController(text: widget.line.finalPrice == null ? '' : formatServiceMoney(widget.line.finalPrice!));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    final text = _c.text.trim().replaceAll(',', '.');
    final value = text.isEmpty ? null : double.tryParse(text);
    if (text.isNotEmpty && value == null) return;

    Navigator.of(context).pop((value: value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listed = widget.line.price;

    return AlertDialog(
      title: Text(widget.line.name),
      content: TextField(
        controller: _c,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: l10n.billFinalPrice,
          helperText: listed == null ? l10n.billFinalPriceHint : '${l10n.billFinalPriceHint} (${formatServiceMoney(listed)} ${l10n.invCurrency})',
          suffixText: l10n.invCurrency,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _save, child: Text(l10n.billSave)),
      ],
    );
  }
}
