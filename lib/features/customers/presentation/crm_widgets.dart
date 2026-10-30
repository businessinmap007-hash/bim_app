import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/application/inventory_providers.dart';
import '../../inventory/presentation/inventory_labels.dart';
import '../data/customers_api.dart';

/// Both sides use the inventory transport: straight to the server on the phone, the local copy on the desktop.
final customersApiProvider = Provider<CustomersApi>((ref) => CustomersApi(ref.watch(inventoryTransportProvider)));

const crmMethods = ['cash', 'wallet', 'instapay', 'bank'];

class CrmLabels {
  const CrmLabels._();

  static String money(BuildContext context, num v) => '${InvLabels.money(v)} ${AppLocalizations.of(context)!.stkCurrency}';

  /// «عليه 1,750» / «له 50» / «خالص» from the business's side.
  static String balance(BuildContext context, double b) {
    final l10n = AppLocalizations.of(context)!;
    if (b > 0.004) return l10n.crmOwes(money(context, b));
    if (b < -0.004) return l10n.crmHasCredit(money(context, -b));
    return l10n.crmSettled;
  }

  /// The same from the customer's own side: «عليّ» / «لي».
  static String myBalance(BuildContext context, double b) {
    final l10n = AppLocalizations.of(context)!;
    if (b > 0.004) return l10n.crmIOwe(money(context, b));
    if (b < -0.004) return l10n.crmOwedToMe(money(context, -b));
    return l10n.crmSettled;
  }

  static String method(AppLocalizations l10n, String m) => switch (m) {
    'wallet' => l10n.crmMethodWallet,
    'instapay' => l10n.crmMethodInstapay,
    'bank' => l10n.crmMethodBank,
    _ => l10n.crmMethodCash,
  };

  static String kind(AppLocalizations l10n, String k) => switch (k) {
    'opening' => l10n.crmKindOpening,
    'sale' => l10n.crmKindSale,
    'order' => l10n.crmKindOrder,
    'payment' => l10n.crmKindPayment,
    'return' => l10n.crmKindReturn,
    _ => l10n.crmKindAdjustment,
  };

  static String status(AppLocalizations l10n, CrmPayment p) => switch (p.status) {
    'pending' => p.awaitingMe ? l10n.crmStatusAwaitingMe : l10n.crmStatusPending,
    'confirmed' => p.businessOnly ? l10n.crmStatusBusinessOnly : l10n.crmStatusConfirmed,
    'mismatch' => l10n.crmStatusMismatch,
    'rejected' => l10n.crmStatusRejected,
    _ => l10n.crmStatusCancelled,
  };

  static Color statusColor(BuildContext context, CrmPayment p) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (p.status) {
      'confirmed' => dark ? const Color(0xFF7DD3A0) : const Color(0xFF1F7A44),
      'pending' => dark ? const Color(0xFFF2C879) : const Color(0xFF7A5200),
      'mismatch' || 'rejected' => dark ? const Color(0xFFF4A091) : const Color(0xFFB93A22),
      _ => Theme.of(context).hintColor,
    };
  }

  /// Red when he owes, green when settled or in credit — light shades on the dark theme.
  static Color balanceColor(BuildContext context, double b) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (b > 0.004) return dark ? const Color(0xFFF4A091) : const Color(0xFFB93A22);
    return dark ? const Color(0xFF7DD3A0) : const Color(0xFF1F7A44);
  }
}

double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '').replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x0660}'));

/// «تسجيل دفعة» / «دفعت» — amount, method and, for a transfer, the reference from the person's OWN bank or wallet app.
Future<({double amount, String method, String? reference})?> askPayment(BuildContext context, {required String title, double? suggested, String? hint}) {
  return showDialog<({double amount, String method, String? reference})>(
    context: context,
    builder: (_) => _PaymentDialog(title: title, suggested: suggested, hint: hint),
  );
}

class _PaymentDialog extends StatefulWidget {
  final String title;
  final double? suggested;
  final String? hint;
  const _PaymentDialog({required this.title, this.suggested, this.hint});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final _amount = TextEditingController(text: widget.suggested == null || widget.suggested! <= 0 ? '' : InvLabels.money(widget.suggested!).replaceAll(',', ''));
  final _ref = TextEditingController();
  String _method = 'cash';

  @override
  void dispose() {
    _amount.dispose();
    _ref.dispose();
    super.dispose();
  }

  bool get _valid => (_num(_amount.text) ?? 0) > 0 && (_method == 'cash' || _ref.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.crmAmount, suffixText: l10n.stkCurrency),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Text(l10n.crmMethod, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final m in crmMethods) ChoiceChip(label: Text(CrmLabels.method(l10n, m)), selected: _method == m, onSelected: (_) => setState(() => _method = m))],
            ),
            if (_method != 'cash') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _ref,
                decoration: InputDecoration(labelText: l10n.crmReference, helperText: l10n.crmReferenceHint, helperMaxLines: 3),
                onChanged: (_) => setState(() {}),
              ),
            ],
            if (widget.hint != null) ...[const SizedBox(height: 10), Text(widget.hint!, style: Theme.of(context).textTheme.bodySmall)],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: _valid ? () => Navigator.pop(context, (amount: _num(_amount.text)!, method: _method, reference: _method == 'cash' ? null : _ref.text.trim())) : null,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// The other side's reference (blind) for confirming a transfer.
Future<String?> askReference(BuildContext context, CrmPayment p) async {
  final l10n = AppLocalizations.of(context)!;
  final c = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${l10n.crmConfirm} · ${CrmLabels.money(ctx, p.amount)} · ${CrmLabels.method(l10n, p.method)}'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.crmReference, helperText: l10n.crmReferenceHint, helperMaxLines: 3),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.crmConfirm)),
      ],
    ),
  );
  final text = c.text.trim();
  // disposed after the route's exit animation (see feedback: dialog controllers dispose late)
  WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
  return ok == true && text.isNotEmpty ? text : null;
}

/// One payment with the answers open to [side] ('business' | 'customer'). [onChanged] runs after any answer.
class CrmPaymentTile extends ConsumerWidget {
  final CrmPayment payment;
  final String side;
  final VoidCallback onChanged;
  final bool showCustomer;

  const CrmPaymentTile({super.key, required this.payment, required this.side, required this.onChanged, this.showCustomer = false});

  Future<void> _answer(BuildContext context, WidgetRef ref, String action, {String? reference}) async {
    final api = ref.read(customersApiProvider);
    try {
      if (side == 'business') {
        await api.businessAnswer(payment.id, action, reference: reference);
      } else {
        await api.customerAnswer(payment.id, action, reference: reference);
      }
      if (context.mounted && action == 'confirm') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.crmPaymentConfirmedNow)));
      }
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final p = payment;
    final when = p.createdAt == null ? '' : MaterialLocalizations.of(context).formatShortDate(p.createdAt!);
    final mineToCancel = p.pending && !p.awaitingMe;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${showCustomer && p.customerName != null ? '${p.customerName} · ' : ''}${CrmLabels.money(context, p.amount)} · ${CrmLabels.method(l10n, p.method)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  CrmLabels.status(l10n, p),
                  style: TextStyle(color: CrmLabels.statusColor(context, p), fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              [
                when,
                if (p.number != null) l10n.crmReceiptNo(p.number!),
                if (p.reference != null) '${l10n.crmReference}: ${p.reference}',
                if (p.pending && p.isTransfer && p.awaitingMe) l10n.crmAttemptsLeft(p.attemptsLeft),
                if (p.reason != null) p.reason!,
              ].where((s) => s.isNotEmpty).join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (p.awaitingMe || mineToCancel) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (p.awaitingMe)
                    FilledButton(
                      onPressed: () async {
                        String? reference;
                        if (p.isTransfer) {
                          reference = await askReference(context, p);
                          if (reference == null) return;
                        }
                        if (context.mounted) await _answer(context, ref, 'confirm', reference: reference);
                      },
                      child: Text(l10n.crmConfirm),
                    ),
                  if (p.awaitingMe) OutlinedButton(onPressed: () => _answer(context, ref, 'reject'), child: Text(side == 'business' ? l10n.crmRejectBusiness : l10n.crmRejectCustomer)),
                  if (mineToCancel) TextButton(onPressed: () => _answer(context, ref, 'cancel'), child: Text(l10n.crmCancelPayment)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A book line for a narrow screen: what, when, + or −, and the balance after it.
class CrmMoveTile extends StatelessWidget {
  final CrmMove move;
  const CrmMoveTile({super.key, required this.move});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m = move;
    final up = m.amount > 0;
    return ListTile(
      dense: true,
      title: Text(m.note ?? CrmLabels.kind(l10n, m.kind)),
      subtitle: Text(m.occurredAt == null ? CrmLabels.kind(l10n, m.kind) : MaterialLocalizations.of(context).formatMediumDate(m.occurredAt!)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${up ? '+' : '−'}${InvLabels.money(m.amount.abs())}',
            style: TextStyle(fontWeight: FontWeight.w800, color: CrmLabels.balanceColor(context, up ? 1 : 0)),
          ),
          Text(InvLabels.money(m.balance), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// The four age buckets of what he owes.
class CrmAgingRow extends StatelessWidget {
  final CrmAging aging;
  const CrmAgingRow({super.key, required this.aging});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cells = [(l10n.crmAging30, aging.upTo30), (l10n.crmAging60, aging.d31to60), (l10n.crmAging90, aging.d61to90), (l10n.crmAgingOver, aging.over90)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (label, v) in cells)
              Container(
                width: 120,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    Text(InvLabels.money(v), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
          ],
        ),
        if (aging.overdue > 0.004)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${l10n.crmOverdue}: ${CrmLabels.money(context, aging.overdue)}',
              style: TextStyle(color: CrmLabels.balanceColor(context, 1), fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}
