import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/customers/data/customers_api.dart';
import '../../features/customers/presentation/crm_widgets.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import '../desktop_app.dart';
import '../print/suite_print.dart';
import '../sync/desktop_sync.dart';
import 'common.dart';
import '../../features/inventory/data/inventory_models.dart' show invNum;

final _queryProvider = StateProvider.autoDispose<String>((ref) => '');
final _filterProvider = StateProvider.autoDispose<String>((ref) => 'all');
final _selectedProvider = StateProvider.autoDispose<int?>((ref) => null);

final _listProvider = FutureProvider.autoDispose<({List<CrmCustomer> customers, CrmSummary summary})>(
  (ref) => ref.watch(customersApiProvider).customers(q: ref.watch(_queryProvider), filter: ref.watch(_filterProvider)),
);
final _fileProvider = FutureProvider.autoDispose.family<CrmCustomerFile, int>((ref, id) => ref.watch(customersApiProvider).file(id));
final _awaitingProvider = FutureProvider.autoDispose<List<CrmPayment>>((ref) async => (await ref.watch(customersApiProvider).payments(status: 'pending')).where((p) => p.awaitingMe).toList());

/// «العملاء» (desktop suite phase 3) — every customer of the business with what he owes, spends and when he last came;
/// his file with the credit book, purchases and payments. A payment counts once both sides confirm it; a customer
/// outside the app cannot confirm, so the business's word stands and a receipt is printed for him to sign.
class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _refresh([int? id]) {
    ref.invalidate(_listProvider);
    ref.invalidate(_awaitingProvider);
    if (id != null) ref.invalidate(_fileProvider(id));
  }

  Future<void> _newCustomer() async {
    final form = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => const CustomerFormDialog());
    if (form == null || !mounted) return;
    final api = ref.read(customersApiProvider);
    final created = await suiteRun(
      context,
      () => api.create(
        name: form['name'] as String,
        phone: form['phone'] as String?,
        address: form['address'] as String?,
        tags: form['tags'] as List<String>?,
        notes: form['notes'] as String?,
        creditLimit: form['credit_limit'] as double?,
        paymentTermsDays: form['payment_terms_days'] as int?,
        openingBalance: form['opening_balance'] as double?,
      ),
      queueable: false,
    );
    _refresh();
    if (created != null) ref.read(_selectedProvider.notifier).state = created.id;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = ref.watch(_listProvider);
    final filter = ref.watch(_filterProvider);
    final selected = ref.watch(_selectedProvider);
    final awaiting = ref.watch(_awaitingProvider).valueOrNull ?? const <CrmPayment>[];
    final summary = list.valueOrNull?.summary ?? const CrmSummary();

    final filters = {
      'all': l10n.crmFilterAll,
      'owing': l10n.crmFilterOwing,
      'overdue': l10n.crmFilterOverdue,
      'top': l10n.crmFilterTop,
      'frequent': l10n.crmFilterFrequent,
      'new': l10n.crmFilterNew,
      'lapsed': l10n.crmFilterLapsed,
    };

    return SuitePage(
      title: l10n.crmTitle,
      scroll: false,
      actions: [FilledButton.icon(icon: const Icon(Icons.person_add_alt_1), label: Text(l10n.crmNewCustomer), onPressed: _newCustomer)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SuiteStat(label: l10n.crmOwedTotal, value: CrmLabels.money(context, summary.owedTotal), sub: '${summary.owingCount} / ${summary.count}', color: Tone.bad(context)),
                ),
                Expanded(
                  child: SuiteStat(label: l10n.crmPaymentsMonth, value: CrmLabels.money(context, summary.paymentsThisMonth), color: Tone.good(context)),
                ),
                Expanded(
                  child: SuiteStat(label: l10n.crmNewMonth, value: '${summary.newThisMonth}'),
                ),
                Expanded(
                  child: SuiteStat(label: l10n.crmPendingPayments, value: '${awaiting.length}', color: awaiting.isEmpty ? null : Tone.warn(context)),
                ),
              ],
            ),
          ),
          if (awaiting.isNotEmpty)
            SuiteSection(
              title: l10n.crmPendingPayments,
              child: Column(
                children: [for (final p in awaiting) CrmPaymentTile(payment: p, side: 'business', showCustomer: true, onChanged: () => _refresh(p.customerId))],
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 380,
                  child: Card(
                    margin: const EdgeInsets.all(6),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _search,
                            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.crmSearch, isDense: true),
                            onSubmitted: (v) => ref.read(_queryProvider.notifier).state = v,
                            onChanged: (v) {
                              if (v.isEmpty) ref.read(_queryProvider.notifier).state = '';
                            },
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final e in filters.entries) ChoiceChip(label: Text(e.value), selected: filter == e.key, onSelected: (_) => ref.read(_filterProvider.notifier).state = e.key),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: AsyncValueView(
                              value: list,
                              onRetry: () => ref.invalidate(_listProvider),
                              builder: (context, data) => data.customers.isEmpty
                                  ? Center(child: Text(l10n.crmNoCustomers))
                                  : ListView(
                                      children: [
                                        for (final c in data.customers)
                                          ListTile(
                                            selected: selected == c.id,
                                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                            subtitle: Text(
                                              [
                                                if (c.onApp) l10n.crmOnApp,
                                                if (c.phone != null) c.phone!,
                                                if (c.lastAt != null) l10n.crmLastVisit(MaterialLocalizations.of(context).formatShortDate(c.lastAt!)),
                                              ].join(' · '),
                                            ),
                                            trailing: Text(
                                              CrmLabels.balance(context, c.balance),
                                              style: TextStyle(fontWeight: FontWeight.w800, color: CrmLabels.balanceColor(context, c.balance)),
                                            ),
                                            onTap: () => ref.read(_selectedProvider.notifier).state = c.id,
                                          ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: selected == null ? Center(child: Text(l10n.crmPickToSee)) : _CustomerFilePanel(key: ValueKey(selected), id: selected, onChanged: () => _refresh(selected)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerFilePanel extends ConsumerStatefulWidget {
  final int id;
  final VoidCallback onChanged;
  const _CustomerFilePanel({super.key, required this.id, required this.onChanged});

  @override
  ConsumerState<_CustomerFilePanel> createState() => _CustomerFilePanelState();
}

class _CustomerFilePanelState extends ConsumerState<_CustomerFilePanel> {
  int _tab = 0;

  CustomersApi get _api => ref.read(customersApiProvider);

  Future<void> _recordPayment(CrmCustomerFile f) async {
    final l10n = AppLocalizations.of(context)!;
    final c = f.customer;
    final input = await askPayment(context, title: '${l10n.crmRecordPayment} — ${c.name}', suggested: c.balance > 0 ? c.balance : null, hint: c.onApp ? null : l10n.crmBusinessOnlyHint);
    if (input == null || !mounted) return;
    final store = ref.read(suiteStoreProvider);
    final p = await suiteRun(context, () => _api.recordPayment(c.id, amount: input.amount, method: input.method, reference: input.reference, deviceUuid: store.deviceUuid), queueable: false);
    widget.onChanged();
    if (p == null || !mounted) return;
    if (p.pending) suiteToast(context, l10n.crmPaymentRecorded, icon: Icons.hourglass_top);
    if (p.businessOnly && p.status == 'confirmed') await _printPaymentReceipt(c, p);
  }

  Future<void> _printPaymentReceipt(CrmCustomer c, CrmPayment p) async {
    final l10n = AppLocalizations.of(context)!;
    final pdf = await SuitePrint.document(
      businessName: ref.read(suiteBusinessProvider)?.name ?? '',
      title: '${l10n.crmPaymentReceipt}${p.number == null ? '' : ' — ${l10n.crmReceiptNo(p.number!)}'}',
      facts: [
        (l10n.crmName, c.name),
        if (c.phone != null) (l10n.crmPhone, c.phone!),
        (l10n.crmAmount, CrmLabels.money(context, p.amount)),
        (l10n.crmMethod, CrmLabels.method(l10n, p.method)),
        if (p.reference != null) (l10n.crmReference, p.reference!),
        (l10n.suiteWhen, MaterialLocalizations.of(context).formatMediumDate(p.createdAt ?? DateTime.now())),
      ],
      headers: const [],
      rows: const [],
      signatures: [l10n.crmSignAccountant, l10n.crmSignCustomer],
    );
    await ref.read(suitePrintProvider).print(pdf, receipt: false, name: 'payment-${p.number ?? p.id}');
  }

  Future<void> _printStatement(CrmCustomer c) async {
    final l10n = AppLocalizations.of(context)!;
    final s = await suiteRun(context, () => _api.statement(c.id), queueable: false);
    if (s == null || !mounted) return;
    String day(DateTime? d) => d == null ? '' : MaterialLocalizations.of(context).formatShortDate(d);
    final a = s.aging;
    final pdf = await SuitePrint.document(
      businessName: ref.read(suiteBusinessProvider)?.name ?? '',
      title: l10n.crmStatementTitle(c.name),
      facts: [
        if (c.phone != null) (l10n.crmPhone, c.phone!),
        (l10n.crmCreditLimit, c.creditLimit == null ? l10n.crmNoLimit : CrmLabels.money(context, c.creditLimit!)),
        if (c.paymentTermsDays != null) (l10n.crmTermsDays, '${c.paymentTermsDays}'),
        (l10n.suiteWhen, MaterialLocalizations.of(context).formatMediumDate(DateTime.now())),
      ],
      headers: [l10n.crmDate, l10n.crmLine, l10n.crmDebit, l10n.crmCreditCol, l10n.crmBalance],
      rows: [
        for (final m in s.lines)
          [day(m.occurredAt), m.note ?? CrmLabels.kind(l10n, m.kind), m.debit > 0 ? InvLabels.money(m.debit) : '', m.credit > 0 ? InvLabels.money(m.credit) : '', InvLabels.money(m.balance)],
      ],
      totalLabel: l10n.crmAmountDue,
      total: CrmLabels.money(context, s.closing),
      notes:
          '${l10n.crmAging30}: ${InvLabels.money(a.upTo30)} · ${l10n.crmAging60}: ${InvLabels.money(a.d31to60)} · '
          '${l10n.crmAging90}: ${InvLabels.money(a.d61to90)} · ${l10n.crmAgingOver}: ${InvLabels.money(a.over90)}',
      signatures: [l10n.crmSignAccountant, l10n.crmSignCustomer],
    );
    await ref.read(suitePrintProvider).print(pdf, receipt: false, name: 'statement-${c.id}');
  }

  Future<void> _remind(CrmCustomer c) async {
    final l10n = AppLocalizations.of(context)!;
    final r = await suiteRun(context, () => _api.remind(c.id), queueable: false);
    if (r == null || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.crmRemind),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.sent ? l10n.crmReminderSent : l10n.crmReminderShare),
              const SizedBox(height: 8),
              SelectableText(r.text, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (r.phone != null) Padding(padding: const EdgeInsets.only(top: 6), child: SelectableText(r.phone!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: r.text));
              if (ctx.mounted) suiteToast(ctx, l10n.crmCopied);
            },
            child: Text(l10n.crmCopy),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonOk)),
        ],
      ),
    );
  }

  Future<void> _edit(CrmCustomerFile f) async {
    final form = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CustomerFormDialog(file: f),
    );
    if (form == null || !mounted) return;
    form.remove('opening_balance');
    if (f.customer.onApp) form.remove('name');
    await suiteRun(context, () => _api.update(f.customer.id, form), queueable: false);
    widget.onChanged();
  }

  Future<void> _link(CrmCustomer c) async {
    final l10n = AppLocalizations.of(context)!;
    final code = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.crmLinkAccount),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.crmLinkHint),
              TextField(
                controller: code,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.crmCode),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.crmLinkAccount)),
        ],
      ),
    );
    final text = code.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) => code.dispose());
    if (ok != true || text.isEmpty || !mounted) return;
    final linked = await suiteRun(context, () => _api.link(c.id, text), queueable: false);
    widget.onChanged();
    if (linked != null && mounted) {
      suiteToast(context, l10n.crmLinked);
      ref.read(_selectedProvider.notifier).state = linked.customer.id;
    }
  }

  Future<void> _adjust(CrmCustomer c) async {
    final l10n = AppLocalizations.of(context)!;
    final amount = TextEditingController();
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.crmAdjust),
        content: SizedBox(
          width: 400,
          child: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                decoration: InputDecoration(labelText: l10n.crmAmount, helperText: l10n.crmAdjustHint),
              ),
              TextField(
                controller: reason,
                decoration: InputDecoration(labelText: l10n.crmAdjustReason),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    final value = double.tryParse(amount.text.trim());
    final why = reason.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      amount.dispose();
      reason.dispose();
    });
    if (ok != true || value == null || value == 0 || why.isEmpty || !mounted) return;
    await suiteRun(context, () => _api.adjust(c.id, value, why), queueable: false);
    widget.onChanged();
  }

  Future<void> _forget(CrmCustomer c) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.crmForget),
        content: Text(l10n.crmForgetConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.crmForget)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await suiteRun(context, () async {
      await _api.forget(c.id);
      return true;
    }, queueable: false);
    ref.read(_selectedProvider.notifier).state = null;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AsyncValueView<CrmCustomerFile>(
      value: ref.watch(_fileProvider(widget.id)),
      onRetry: () => ref.invalidate(_fileProvider(widget.id)),
      builder: (context, f) {
        final c = f.customer;
        final tabs = [l10n.crmTabAccount, '${l10n.crmTabPurchases} (${f.purchases.length})', l10n.crmPayments, l10n.crmTabTop, l10n.crmTabData];

        return Card(
          margin: const EdgeInsets.all(6),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                          if (c.onApp)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 8),
                              child: Chip(label: Text(l10n.crmOnApp), visualDensity: VisualDensity.compact),
                            ),
                        ],
                      ),
                      Text([if (c.phone != null) c.phone!, if (c.tags.isNotEmpty) c.tags.join('، '), l10n.crmVisits(c.visits)].join(' · '), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(icon: const Icon(Icons.payments_outlined), label: Text(l10n.crmRecordPayment), onPressed: () => _recordPayment(f)),
                      OutlinedButton.icon(icon: const Icon(Icons.print_outlined), label: Text(l10n.crmPrintStatement), onPressed: () => _printStatement(c)),
                      OutlinedButton.icon(icon: const Icon(Icons.notifications_active_outlined), label: Text(l10n.crmRemind), onPressed: () => _remind(c)),
                      PopupMenuButton<String>(
                        onSelected: (v) => switch (v) {
                          'edit' => _edit(f),
                          'adjust' => _adjust(c),
                          'link' => _link(c),
                          _ => _forget(c),
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'edit', child: Text(l10n.crmEdit)),
                          PopupMenuItem(value: 'adjust', child: Text(l10n.crmAdjust)),
                          if (!c.onApp) PopupMenuItem(value: 'link', child: Text(l10n.crmLinkAccount)),
                          PopupMenuItem(value: 'forget', child: Text(l10n.crmForget)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SuiteStat(
                        label: l10n.crmBalanceNow,
                        value: CrmLabels.money(context, c.balance),
                        sub: c.creditLimit == null ? l10n.crmNoLimit : l10n.crmLimitOf(CrmLabels.money(context, c.creditLimit!)),
                        color: CrmLabels.balanceColor(context, c.balance),
                      ),
                    ),
                    Expanded(
                      child: SuiteStat(label: l10n.crmSpendYear, value: CrmLabels.money(context, f.spendThisYear)),
                    ),
                    Expanded(
                      child: SuiteStat(label: l10n.crmAvgTicket, value: CrmLabels.money(context, f.averageTicket)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [for (var i = 0; i < tabs.length; i++) ChoiceChip(label: Text(tabs[i]), selected: _tab == i, onSelected: (_) => setState(() => _tab = i))],
              ),
              const Divider(),
              switch (_tab) {
                0 => _account(f),
                1 => _purchases(f),
                2 => Column(
                  children: [for (final p in f.payments) CrmPaymentTile(payment: p, side: 'business', onChanged: widget.onChanged)],
                ),
                3 =>
                  f.topItems.isEmpty
                      ? Padding(padding: const EdgeInsets.all(16), child: Text(l10n.crmTopItemsEmpty))
                      : Column(
                          children: [for (final t in f.topItems) ListTile(dense: true, title: Text(t.name), subtitle: Text(invNum(t.qty)), trailing: Text(CrmLabels.money(context, t.total)))],
                        ),
                _ => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c.phone != null) ListTile(dense: true, title: Text(l10n.crmPhone), subtitle: SelectableText(c.phone!)),
                    if (f.address != null) ListTile(dense: true, title: Text(l10n.crmAddress), subtitle: Text(f.address!)),
                    ListTile(dense: true, title: Text(l10n.crmTermsDays), subtitle: Text(c.paymentTermsDays == null ? '—' : '${c.paymentTermsDays}')),
                    ListTile(dense: true, title: Text(l10n.crmNotes), subtitle: Text(f.notes ?? '—')),
                  ],
                ),
              },
            ],
          ),
        );
      },
    );
  }

  Widget _account(CrmCustomerFile f) {
    final l10n = AppLocalizations.of(context)!;
    String day(DateTime? d) => d == null ? '' : MaterialLocalizations.of(context).formatShortDate(d);
    final lines = f.moves.reversed.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CrmAgingRow(aging: f.aging),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text(l10n.crmDate)),
              DataColumn(label: Text(l10n.crmLine)),
              DataColumn(label: Text(l10n.crmDebit)),
              DataColumn(label: Text(l10n.crmCreditCol)),
              DataColumn(label: Text(l10n.crmBalance)),
            ],
            rows: [
              for (final m in lines)
                DataRow(
                  cells: [
                    DataCell(Text(day(m.occurredAt))),
                    DataCell(Text(m.note ?? CrmLabels.kind(l10n, m.kind))),
                    DataCell(
                      Text(
                        m.debit > 0 ? InvLabels.money(m.debit) : '',
                        style: TextStyle(color: Tone.bad(context), fontWeight: FontWeight.w700),
                      ),
                    ),
                    DataCell(
                      Text(
                        m.credit > 0 ? InvLabels.money(m.credit) : '',
                        style: TextStyle(color: Tone.good(context), fontWeight: FontWeight.w700),
                      ),
                    ),
                    DataCell(Text(InvLabels.money(m.balance), style: const TextStyle(fontWeight: FontWeight.w800))),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _purchases(CrmCustomerFile f) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        for (final p in f.purchases)
          ListTile(
            dense: true,
            title: Text(p.source == 'order' ? l10n.crmPurchaseOrder(int.tryParse(p.number) ?? p.id) : l10n.crmPurchaseSale(int.tryParse(p.number) ?? p.id)),
            subtitle: Text([if (p.at != null) MaterialLocalizations.of(context).formatShortDate(p.at!), p.status, if (p.charged) l10n.crmOnAccount].join(' · ')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(CrmLabels.money(context, p.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                if (p.source == 'order' && !p.charged && p.status != 'cancelled' && p.status != 'rejected')
                  TextButton(
                    onPressed: () async {
                      await suiteRun(context, () => _api.chargeOrder(f.customer.id, p.id), queueable: false);
                      widget.onChanged();
                    },
                    child: Text(l10n.crmChargeOrder),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// New customer / edit his details. Returns the fields to send (tags split on commas).
class CustomerFormDialog extends StatefulWidget {
  final CrmCustomerFile? file;
  const CustomerFormDialog({super.key, this.file});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  late final CrmCustomer? _c = widget.file?.customer;
  late final _name = TextEditingController(text: _c?.name ?? '');
  late final _phone = TextEditingController(text: _c?.phone ?? '');
  late final _address = TextEditingController(text: widget.file?.address ?? '');
  late final _tags = TextEditingController(text: _c?.tags.join('، ') ?? '');
  late final _notes = TextEditingController(text: widget.file?.notes ?? '');
  late final _limit = TextEditingController(text: _c?.creditLimit == null ? '' : invNum(_c!.creditLimit!));
  late final _terms = TextEditingController(text: _c?.paymentTermsDays?.toString() ?? '');
  final _opening = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _tags, _notes, _limit, _terms, _opening]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editing = widget.file != null;
    return AlertDialog(
      title: Text(editing ? l10n.crmEdit : l10n.crmNewCustomer),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                enabled: !(_c?.onApp ?? false),
                autofocus: !editing,
                decoration: InputDecoration(labelText: l10n.crmName),
              ),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.crmPhone),
              ),
              TextField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.crmAddress),
              ),
              TextField(
                controller: _tags,
                decoration: InputDecoration(labelText: l10n.crmTags),
              ),
              TextField(
                controller: _notes,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.crmNotes),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _limit,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.crmCreditLimit, hintText: l10n.crmNoLimit),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _terms,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.crmTermsDays),
                    ),
                  ),
                ],
              ),
              if (!editing)
                TextField(
                  controller: _opening,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.crmOpeningBalance),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            final tags = _tags.text.split(RegExp('[,،]')).map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
            Navigator.pop(context, <String, dynamic>{
              'name': _name.text.trim(),
              'phone': _t(_phone),
              'address': _t(_address),
              'tags': tags.isEmpty ? null : tags,
              'notes': _t(_notes),
              'credit_limit': double.tryParse(_limit.text.trim()),
              'payment_terms_days': int.tryParse(_terms.text.trim()),
              'opening_balance': double.tryParse(_opening.text.trim()),
            });
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
