import '../../inventory/data/inventory_api.dart';

double _d(Object? v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);
double? _dn(Object? v) => v == null ? null : _d(v);
int _i(Object? v) => v == null ? 0 : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0);
int? _in(Object? v) => v == null ? null : _i(v);
DateTime? _dt(Object? v) => v == null ? null : DateTime.tryParse(v.toString())?.toLocal();
Map<String, dynamic> _m(Object? v) => v is Map ? v.cast<String, dynamic>() : const {};
List<Map<String, dynamic>> _l(Object? v) => v is List ? [for (final e in v) _m(e)] : const [];

/// One row of the business's customers list.
class CrmCustomer {
  final int id;
  final String name;
  final String? phone;
  final bool onApp;
  final List<String> tags;
  final double balance;
  final double? creditLimit;
  final int? paymentTermsDays;
  final double spend;
  final int visits;
  final DateTime? lastAt;
  final DateTime? createdAt;

  const CrmCustomer({
    required this.id,
    required this.name,
    this.phone,
    required this.onApp,
    this.tags = const [],
    required this.balance,
    this.creditLimit,
    this.paymentTermsDays,
    this.spend = 0,
    this.visits = 0,
    this.lastAt,
    this.createdAt,
  });

  factory CrmCustomer.fromJson(Map<String, dynamic> j) => CrmCustomer(
    id: _i(j['id']),
    name: '${j['name'] ?? ''}',
    phone: j['phone'] as String?,
    onApp: j['on_app'] == true,
    tags: ((j['tags'] as List<dynamic>?) ?? const []).map((t) => '$t').toList(),
    balance: _d(j['balance']),
    creditLimit: _dn(j['credit_limit']),
    paymentTermsDays: _in(j['payment_terms_days']),
    spend: _d(j['spend']),
    visits: _i(j['visits']),
    lastAt: _dt(j['last_at']),
    createdAt: _dt(j['created_at']),
  );

  /// What may still go on his account before the limit; null = no limit set.
  double? get headroom => creditLimit == null ? null : creditLimit! - balance;
}

class CrmSummary {
  final int count;
  final int owingCount;
  final double owedTotal;
  final double paymentsThisMonth;
  final int newThisMonth;
  final int pendingPayments;

  const CrmSummary({this.count = 0, this.owingCount = 0, this.owedTotal = 0, this.paymentsThisMonth = 0, this.newThisMonth = 0, this.pendingPayments = 0});

  factory CrmSummary.fromJson(Map<String, dynamic> j) => CrmSummary(
    count: _i(j['count']),
    owingCount: _i(j['owing_count']),
    owedTotal: _d(j['owed_total']),
    paymentsThisMonth: _d(j['payments_this_month']),
    newThisMonth: _i(j['new_this_month']),
    pendingPayments: _i(j['pending_payments']),
  );
}

/// How old what he owes is (payments settle the oldest debts first).
class CrmAging {
  final double upTo30;
  final double d31to60;
  final double d61to90;
  final double over90;
  final double overdue;

  const CrmAging({this.upTo30 = 0, this.d31to60 = 0, this.d61to90 = 0, this.over90 = 0, this.overdue = 0});

  factory CrmAging.fromJson(Map<String, dynamic> j) => CrmAging(upTo30: _d(j['0_30']), d31to60: _d(j['31_60']), d61to90: _d(j['61_90']), over90: _d(j['over_90']), overdue: _d(j['overdue']));
}

/// One line of the credit book: + he owes more, − less.
class CrmMove {
  final int id;
  final String kind;
  final double amount;
  final double debit;
  final double credit;
  final double balance;
  final String? note;
  final DateTime? occurredAt;

  const CrmMove({required this.id, required this.kind, required this.amount, required this.debit, required this.credit, required this.balance, this.note, this.occurredAt});

  factory CrmMove.fromJson(Map<String, dynamic> j) => CrmMove(
    id: _i(j['id']),
    kind: '${j['kind']}',
    amount: _d(j['amount']),
    debit: _d(j['debit']),
    credit: _d(j['credit']),
    balance: _d(j['balance']),
    note: j['note'] as String?,
    occurredAt: _dt(j['occurred_at']),
  );
}

/// A credit payment, as ONE side sees it (never the other side's reference before the match).
class CrmPayment {
  final int id;
  final int customerId;
  final int? number;
  final double amount;
  final String method;
  final String startedBy;
  final String status;
  final String? reference;
  final int attemptsLeft;
  final bool businessOnly;
  final bool awaitingMe;
  final String? reason;
  final String? customerName;
  final DateTime? createdAt;

  const CrmPayment({
    required this.id,
    required this.customerId,
    this.number,
    required this.amount,
    required this.method,
    required this.startedBy,
    required this.status,
    this.reference,
    this.attemptsLeft = 3,
    this.businessOnly = false,
    this.awaitingMe = false,
    this.reason,
    this.customerName,
    this.createdAt,
  });

  factory CrmPayment.fromJson(Map<String, dynamic> j) => CrmPayment(
    id: _i(j['id']),
    customerId: _i(j['customer_id']),
    number: _in(j['number']),
    amount: _d(j['amount']),
    method: '${j['method']}',
    startedBy: '${j['started_by']}',
    status: '${j['status']}',
    reference: j['reference'] as String?,
    attemptsLeft: _i(j['attempts_left']),
    businessOnly: j['business_only'] == true,
    awaitingMe: j['awaiting_me'] == true,
    reason: j['reason'] as String?,
    customerName: j['customer_name'] as String?,
    createdAt: _dt(j['created_at']),
  );

  bool get isTransfer => method != 'cash';
  bool get pending => status == 'pending';
}

class CrmPurchase {
  final String source; // order | pos_sale
  final int id;
  final String number;
  final double total;
  final double onAccount;
  final String status;
  final DateTime? at;
  final bool charged;

  const CrmPurchase({required this.source, required this.id, required this.number, required this.total, this.onAccount = 0, required this.status, this.at, this.charged = false});

  factory CrmPurchase.fromJson(Map<String, dynamic> j) => CrmPurchase(
    source: '${j['source']}',
    id: _i(j['id']),
    number: '${j['number']}',
    total: _d(j['total']),
    onAccount: _d(j['on_account']),
    status: '${j['status']}',
    at: _dt(j['at']),
    charged: j['charged'] == true,
  );
}

/// The whole file, as the business sees it.
class CrmCustomerFile {
  final CrmCustomer customer;
  final String? notes;
  final String? address;
  final double averageTicket;
  final double spendThisYear;
  final CrmAging aging;
  final List<CrmMove> moves;
  final List<CrmPurchase> purchases;
  final List<({String name, double qty, double total})> topItems;
  final List<CrmPayment> payments;

  const CrmCustomerFile({
    required this.customer,
    this.notes,
    this.address,
    this.averageTicket = 0,
    this.spendThisYear = 0,
    this.aging = const CrmAging(),
    this.moves = const [],
    this.purchases = const [],
    this.topItems = const [],
    this.payments = const [],
  });

  factory CrmCustomerFile.fromJson(Map<String, dynamic> j) {
    final c = _m(j['customer']);
    return CrmCustomerFile(
      customer: CrmCustomer.fromJson(c),
      notes: c['notes'] as String?,
      address: c['address'] as String?,
      averageTicket: _d(c['average_ticket']),
      spendThisYear: _d(c['spend_this_year']),
      aging: CrmAging.fromJson(_m(c['aging'])),
      moves: _l(j['moves']).map(CrmMove.fromJson).toList(),
      purchases: _l(j['purchases']).map(CrmPurchase.fromJson).toList(),
      topItems: [for (final t in _l(j['top_items'])) (name: '${t['name']}', qty: _d(t['qty']), total: _d(t['total']))],
      payments: _l(j['payments']).map(CrmPayment.fromJson).toList(),
    );
  }
}

class CrmStatement {
  final double opening;
  final double closing;
  final List<CrmMove> lines;
  final CrmAging aging;

  const CrmStatement({required this.opening, required this.closing, required this.lines, required this.aging});

  factory CrmStatement.fromJson(Map<String, dynamic> j) =>
      CrmStatement(opening: _d(j['opening']), closing: _d(j['closing']), lines: _l(j['lines']).map(CrmMove.fromJson).toList(), aging: CrmAging.fromJson(_m(j['aging'])));
}

/// «حسابي عند المحلات» — one business that keeps a book on me.
class CustomerAccount {
  final int id;
  final int businessId;
  final String businessName;
  final double balance;
  final double? creditLimit;
  final int? paymentTermsDays;
  final int awaitingMe;

  const CustomerAccount({required this.id, required this.businessId, required this.businessName, required this.balance, this.creditLimit, this.paymentTermsDays, this.awaitingMe = 0});

  factory CustomerAccount.fromJson(Map<String, dynamic> j) => CustomerAccount(
    id: _i(j['id']),
    businessId: _i(j['business_id']),
    businessName: '${j['business_name'] ?? ''}',
    balance: _d(j['balance']),
    creditLimit: _dn(j['credit_limit']),
    paymentTermsDays: _in(j['payment_terms_days']),
    awaitingMe: _i(j['awaiting_me']),
  );
}

class CustomerBook {
  final CustomerAccount account;
  final CrmAging aging;
  final List<CrmMove> moves;
  final List<CrmPayment> payments;

  const CustomerBook({required this.account, required this.aging, required this.moves, required this.payments});

  factory CustomerBook.fromJson(Map<String, dynamic> j) {
    final a = _m(j['account']);
    return CustomerBook(
      account: CustomerAccount.fromJson(a),
      aging: CrmAging.fromJson(_m(a['aging'])),
      moves: _l(j['moves']).map(CrmMove.fromJson).toList(),
      payments: _l(j['payments']).map(CrmPayment.fromJson).toList(),
    );
  }
}

/// «ملفات العملاء ودفتر الآجل» — both sides: the business (/business/customers…) and the customer (/customer-accounts…).
/// It rides the inventory transport, so the desktop reads from its local copy when the line is down.
class CustomersApi {
  final InventoryTransport _t;

  const CustomersApi(this._t);

  // ── the business ──

  Future<({List<CrmCustomer> customers, CrmSummary summary})> customers({String? q, String filter = 'all', String? tag}) async {
    final data = _m(await _t.get('/business/customers', query: {if (q != null && q.trim().isNotEmpty) 'q': q.trim(), 'filter': filter, 'tag': ?tag}));
    return (customers: _l(data['customers']).map(CrmCustomer.fromJson).toList(), summary: CrmSummary.fromJson(_m(data['summary'])));
  }

  Future<CrmCustomer> create({required String name, String? phone, String? address, List<String>? tags, String? notes, double? creditLimit, int? paymentTermsDays, double? openingBalance}) async {
    final data = _m(
      await _t.send(
        'POST',
        '/business/customers',
        body: {
          'name': name,
          'phone': ?phone,
          'address': ?address,
          'tags': ?tags,
          'notes': ?notes,
          'credit_limit': ?creditLimit,
          'payment_terms_days': ?paymentTermsDays,
          'opening_balance': ?openingBalance,
        },
      ),
    );
    return CrmCustomer.fromJson(_m(data['customer']));
  }

  Future<CrmCustomerFile> file(int id) async => CrmCustomerFile.fromJson(_m(await _t.get('/business/customers/$id')));

  Future<CrmCustomerFile> update(int id, Map<String, dynamic> body) async => CrmCustomerFile.fromJson(_m(await _t.send('PATCH', '/business/customers/$id', body: body)));

  Future<void> forget(int id) => _t.send('DELETE', '/business/customers/$id');

  Future<CrmCustomer> resolveCode(String code) async => CrmCustomer.fromJson(_m(_m(await _t.send('POST', '/business/customers/resolve-code', body: {'code': code}))['customer']));

  Future<CrmCustomerFile> link(int id, String code) async => CrmCustomerFile.fromJson(_m(await _t.send('POST', '/business/customers/$id/link', body: {'code': code})));

  Future<CrmCustomerFile> chargeOrder(int id, int orderId, {bool override = false}) async =>
      CrmCustomerFile.fromJson(_m(await _t.send('POST', '/business/customers/$id/charge-order', body: {'order_id': orderId, if (override) 'credit_override': true})));

  Future<CrmCustomerFile> adjust(int id, double amount, String reason) async =>
      CrmCustomerFile.fromJson(_m(await _t.send('POST', '/business/customers/$id/adjust', body: {'uuid': InventoryApi.newUuid(), 'amount': amount, 'reason': reason})));

  Future<CrmStatement> statement(int id, {DateTime? from, DateTime? to}) async {
    String day(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final data = _m(await _t.get('/business/customers/$id/statement', query: {if (from != null) 'from': day(from), if (to != null) 'to': day(to)}));
    return CrmStatement.fromJson(_m(data['statement']));
  }

  Future<CrmPayment> recordPayment(int customerId, {required double amount, required String method, String? reference, String? note, String? deviceUuid}) async {
    final data = _m(
      await _t.send(
        'POST',
        '/business/customers/$customerId/payments',
        body: {'uuid': InventoryApi.newUuid(), 'amount': amount, 'method': method, 'reference': ?reference, 'note': ?note, 'device_uuid': ?deviceUuid},
      ),
    );
    return CrmPayment.fromJson(_m(data['payment']));
  }

  Future<List<CrmPayment>> payments({String? status}) async => _l(_m(await _t.get('/business/customer-payments', query: {'status': ?status}))['payments']).map(CrmPayment.fromJson).toList();

  Future<CrmPayment> businessAnswer(int paymentId, String action, {String? reference, String? reason}) async {
    final data = _m(await _t.send('POST', '/business/customer-payments/$paymentId/$action', body: {'reference': ?reference, 'reason': ?reason}));
    return CrmPayment.fromJson(_m(data['payment']));
  }

  Future<({bool sent, String text, String? phone})> remind(int id) async {
    final data = _m(await _t.send('POST', '/business/customers/$id/remind'));
    return (sent: data['sent'] == true, text: '${data['text'] ?? ''}', phone: data['phone'] as String?);
  }

  // ── the customer ──

  Future<List<CustomerAccount>> myAccounts() async => _l(_m(await _t.get('/customer-accounts'))['accounts']).map(CustomerAccount.fromJson).toList();

  Future<CustomerBook> myBook(int id) async => CustomerBook.fromJson(_m(await _t.get('/customer-accounts/$id')));

  Future<CrmPayment> iPaid(int accountId, {required double amount, required String method, String? reference}) async {
    final data = _m(await _t.send('POST', '/customer-accounts/$accountId/payments', body: {'uuid': InventoryApi.newUuid(), 'amount': amount, 'method': method, 'reference': ?reference}));
    return CrmPayment.fromJson(_m(data['payment']));
  }

  Future<CrmPayment> customerAnswer(int paymentId, String action, {String? reference, String? reason}) async {
    final data = _m(await _t.send('POST', '/customer-accounts/payments/$paymentId/$action', body: {'reference': ?reference, 'reason': ?reason}));
    return CrmPayment.fromJson(_m(data['payment']));
  }

  Future<({String code, DateTime? expiresAt})> linkCode() async {
    final data = _m(await _t.send('POST', '/customer-accounts/link-code'));
    return (code: '${data['code']}', expiresAt: _dt(data['expires_at']));
  }
}
