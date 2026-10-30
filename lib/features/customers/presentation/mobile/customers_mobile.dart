import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../data/customers_api.dart';
import '../crm_widgets.dart';

// ── the business owner: «عملائي» ─────────────────────────────────────────────────────────────────────────────────────

final _ownerFilterProvider = StateProvider.autoDispose<String>((ref) => 'owing');
final _ownerQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final _ownerListProvider = FutureProvider.autoDispose<({List<CrmCustomer> customers, CrmSummary summary})>(
  (ref) => ref.watch(customersApiProvider).customers(q: ref.watch(_ownerQueryProvider), filter: ref.watch(_ownerFilterProvider)),
);
final _ownerAwaitingProvider = FutureProvider.autoDispose<List<CrmPayment>>((ref) async => (await ref.watch(customersApiProvider).payments(status: 'pending')).where((p) => p.awaitingMe).toList());
final _ownerFileProvider = FutureProvider.autoDispose.family<CrmCustomerFile, int>((ref, id) => ref.watch(customersApiProvider).file(id));

/// «عملائي» on the owner's phone — following, not managing (owner: the full management lives on the computer): who
/// owes, the payments waiting for his yes, recording a payment received away from the shop, and «ذكّره».
class MyCustomersScreen extends ConsumerWidget {
  const MyCustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(_ownerFilterProvider);
    final awaiting = ref.watch(_ownerAwaitingProvider).valueOrNull ?? const <CrmPayment>[];
    final filters = {'owing': l10n.crmFilterOwing, 'overdue': l10n.crmFilterOverdue, 'all': l10n.crmFilterAll, 'top': l10n.crmFilterTop, 'lapsed': l10n.crmFilterLapsed};

    void refresh() {
      ref.invalidate(_ownerListProvider);
      ref.invalidate(_ownerAwaitingProvider);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.crmMyCustomers)),
      body: RefreshIndicator(
        onRefresh: () async => refresh(),
        child: AsyncValueView(
          value: ref.watch(_ownerListProvider),
          onRetry: refresh,
          builder: (context, data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Tile(label: l10n.crmOwedTotal, value: CrmLabels.money(context, data.summary.owedTotal), color: CrmLabels.balanceColor(context, 1)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Tile(label: l10n.crmPaymentsMonth, value: CrmLabels.money(context, data.summary.paymentsThisMonth), color: CrmLabels.balanceColor(context, 0)),
                  ),
                ],
              ),
              if (awaiting.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.crmPendingPayments, style: const TextStyle(fontWeight: FontWeight.w800)),
                for (final p in awaiting) CrmPaymentTile(payment: p, side: 'business', showCustomer: true, onChanged: refresh),
              ],
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.crmSearch, isDense: true),
                onSubmitted: (v) => ref.read(_ownerQueryProvider.notifier).state = v,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final e in filters.entries) ChoiceChip(label: Text(e.value), selected: filter == e.key, onSelected: (_) => ref.read(_ownerFilterProvider.notifier).state = e.key)],
              ),
              const SizedBox(height: 8),
              if (data.customers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.crmNoCustomers)),
                ),
              for (final c in data.customers)
                Card(
                  child: ListTile(
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([if (c.onApp) l10n.crmOnApp, if (c.lastAt != null) l10n.crmLastVisit(MaterialLocalizations.of(context).formatShortDate(c.lastAt!))].join(' · ')),
                    trailing: Text(
                      CrmLabels.balance(context, c.balance),
                      style: TextStyle(fontWeight: FontWeight.w800, color: CrmLabels.balanceColor(context, c.balance)),
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => _OwnerFileScreen(id: c.id)));
                      refresh();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerFileScreen extends ConsumerWidget {
  final int id;
  const _OwnerFileScreen({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(customersApiProvider);
    void refresh() => ref.invalidate(_ownerFileProvider(id));

    return AsyncValueView<CrmCustomerFile>(
      value: ref.watch(_ownerFileProvider(id)),
      onRetry: refresh,
      builder: (context, f) {
        final c = f.customer;
        return Scaffold(
          appBar: AppBar(title: Text(c.name)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Tile(
                label: l10n.crmBalanceNow,
                value: CrmLabels.money(context, c.balance),
                sub: c.creditLimit == null ? l10n.crmNoLimit : l10n.crmLimitOf(CrmLabels.money(context, c.creditLimit!)),
                color: CrmLabels.balanceColor(context, c.balance),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(l10n.crmRecordPayment),
                    onPressed: () async {
                      final input = await askPayment(context, title: l10n.crmRecordPayment, suggested: c.balance > 0 ? c.balance : null, hint: c.onApp ? null : l10n.crmBusinessOnlyHint);
                      if (input == null) return;
                      try {
                        final p = await api.recordPayment(c.id, amount: input.amount, method: input.method, reference: input.reference);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(p.pending ? l10n.crmPaymentRecorded : l10n.crmPaymentConfirmedNow)));
                        }
                      } on ApiException catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      }
                      refresh();
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(l10n.crmRemind),
                    onPressed: () async {
                      try {
                        final r = await api.remind(c.id);
                        await Clipboard.setData(ClipboardData(text: r.text));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${r.sent ? l10n.crmReminderSent : l10n.crmReminderShare} ${l10n.crmCopied}')));
                        }
                      } on ApiException catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CrmAgingRow(aging: f.aging),
              if (f.payments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.crmPayments, style: const TextStyle(fontWeight: FontWeight.w800)),
                for (final p in f.payments.take(10)) CrmPaymentTile(payment: p, side: 'business', onChanged: refresh),
              ],
              const SizedBox(height: 12),
              Text(l10n.crmTabAccount, style: const TextStyle(fontWeight: FontWeight.w800)),
              for (final m in f.moves.reversed) CrmMoveTile(move: m),
            ],
          ),
        );
      },
    );
  }
}

// ── the customer: «حسابي عند المحلات» ────────────────────────────────────────────────────────────────────────────────

final _accountsProvider = FutureProvider.autoDispose<List<CustomerAccount>>((ref) => ref.watch(customersApiProvider).myAccounts());
final _bookProvider = FutureProvider.autoDispose.family<CustomerBook, int>((ref, id) => ref.watch(customersApiProvider).myBook(id));

/// «حسابي عند المحلات» — what I owe at each shop that keeps a book on me, the payments waiting for my yes, and
/// «كود حسابي» to show at a counter. I read and confirm; I never edit a shop's book.
class CustomerAccountsScreen extends ConsumerWidget {
  const CustomerAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.crmMyAccounts),
        actions: [IconButton(tooltip: l10n.crmMyCode, icon: const Icon(Icons.qr_code_2), onPressed: () => showMyAccountCode(context, ref))],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_accountsProvider),
        child: AsyncValueView<List<CustomerAccount>>(
          value: ref.watch(_accountsProvider),
          onRetry: () => ref.invalidate(_accountsProvider),
          builder: (context, accounts) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OutlinedButton.icon(icon: const Icon(Icons.qr_code_2), label: Text(l10n.crmMyCode), onPressed: () => showMyAccountCode(context, ref)),
              const SizedBox(height: 12),
              if (accounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.crmNoAccounts)),
                ),
              for (final a in accounts)
                Card(
                  child: ListTile(
                    title: Text(a.businessName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([if (a.creditLimit != null) l10n.crmLimitOf(CrmLabels.money(context, a.creditLimit!)), if (a.awaitingMe > 0) l10n.crmStatusAwaitingMe].join(' · ')),
                    trailing: Text(
                      CrmLabels.myBalance(context, a.balance),
                      style: TextStyle(fontWeight: FontWeight.w800, color: CrmLabels.balanceColor(context, a.balance)),
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => _BookScreen(id: a.id)));
                      ref.invalidate(_accountsProvider);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «كود حسابي» — a short code (and its QR) for 10 minutes.
Future<void> showMyAccountCode(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final code = await ref.read(customersApiProvider).linkCode();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.crmMyCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: code.code, size: 180, backgroundColor: Colors.white),
            const SizedBox(height: 10),
            SelectableText(code.code, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 3)),
            const SizedBox(height: 8),
            Text(l10n.crmMyCodeHint, textAlign: TextAlign.center),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonOk))],
      ),
    );
  } on ApiException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
  }
}

class _BookScreen extends ConsumerWidget {
  final int id;
  const _BookScreen({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    void refresh() => ref.invalidate(_bookProvider(id));

    return AsyncValueView<CustomerBook>(
      value: ref.watch(_bookProvider(id)),
      onRetry: refresh,
      builder: (context, book) {
        final a = book.account;
        return Scaffold(
          appBar: AppBar(title: Text(a.businessName)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Tile(
                label: a.businessName,
                value: CrmLabels.myBalance(context, a.balance),
                sub: a.creditLimit == null ? null : l10n.crmLimitOf(CrmLabels.money(context, a.creditLimit!)),
                color: CrmLabels.balanceColor(context, a.balance),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: const Icon(Icons.payments_outlined),
                label: Text(l10n.crmIPaid),
                onPressed: () async {
                  final input = await askPayment(context, title: l10n.crmIPaid, suggested: a.balance > 0 ? a.balance : null);
                  if (input == null) return;
                  try {
                    await ref.read(customersApiProvider).iPaid(a.id, amount: input.amount, method: input.method, reference: input.reference);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.crmPaymentRecorded)));
                  } on ApiException catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                  refresh();
                },
              ),
              const SizedBox(height: 12),
              CrmAgingRow(aging: book.aging),
              if (book.payments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.crmPayments, style: const TextStyle(fontWeight: FontWeight.w800)),
                for (final p in book.payments.take(10)) CrmPaymentTile(payment: p, side: 'customer', onChanged: refresh),
              ],
              const SizedBox(height: 12),
              Text(l10n.crmTabAccount, style: const TextStyle(fontWeight: FontWeight.w800)),
              for (final m in book.moves.reversed) CrmMoveTile(move: m),
            ],
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? color;
  const _Tile({required this.label, required this.value, this.sub, this.color});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
          ),
          if (sub != null) Text(sub!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
