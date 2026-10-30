import 'package:bim_app/features/customers/data/customers_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// «ملفات العملاء ودفتر الآجل»: the app reads the server's file, book and payments as they come over the wire.
void main() {
  test('a customer row knows what may still go on his account', () {
    final c = CrmCustomer.fromJson({'id': 7, 'name': 'محمود', 'on_app': true, 'balance': '1750.00', 'credit_limit': 2000, 'spend': 38420.5, 'visits': 46, 'last_at': '2026-10-29 18:00:00'});
    expect(c.onApp, isTrue);
    expect(c.headroom, 250);
    expect(c.visits, 46);
    expect(CrmCustomer.fromJson({'id': 1, 'name': 'x', 'balance': 0}).headroom, isNull);
  });

  test('the file carries the aging buckets and the book with its running balance', () {
    final f = CrmCustomerFile.fromJson({
      'customer': {
        'id': 7,
        'name': 'محمود',
        'balance': 710,
        'notes': 'سري',
        'aging': {'0_30': 410, '31_60': 0, '61_90': 300, 'over_90': 0, 'overdue': 300},
      },
      'moves': [
        {'id': 1, 'kind': 'opening', 'amount': 500, 'debit': 500, 'credit': 0, 'balance': 500, 'occurred_at': '2026-08-16T10:00:00Z'},
        {'id': 2, 'kind': 'payment', 'amount': -200, 'debit': 0, 'credit': 200, 'balance': 300, 'note': 'دفعة نقدًا — إيصال 1'},
      ],
      'purchases': [
        {'source': 'order', 'id': 55, 'number': '55', 'total': 410, 'status': 'pending', 'charged': true},
      ],
      'top_items': [
        {'name': 'بن', 'qty': '4.000', 'total': 400},
      ],
      'payments': [],
    });
    expect(f.notes, 'سري');
    expect(f.aging.d61to90, 300);
    expect(f.aging.overdue, 300);
    expect(f.moves.last.credit, 200);
    expect(f.moves.last.balance, 300);
    expect(f.purchases.single.charged, isTrue);
    expect(f.topItems.single.qty, 4);
  });

  test('a payment says whose turn it is and never needs the other side reference', () {
    final p = CrmPayment.fromJson({
      'id': 3,
      'customer_id': 7,
      'amount': '1500.00',
      'method': 'instapay',
      'started_by': 'customer',
      'status': 'pending',
      'reference': null,
      'attempts_left': 2,
      'awaiting_me': true,
    });
    expect(p.isTransfer, isTrue);
    expect(p.pending, isTrue);
    expect(p.awaitingMe, isTrue);
    expect(p.reference, isNull);
    expect(p.attemptsLeft, 2);
  });

  test('the customer side reads his book at one shop', () {
    final b = CustomerBook.fromJson({
      'account': {'id': 7, 'business_id': 12, 'business_name': 'ماركت الأمانة', 'balance': -50, 'aging': {}},
      'moves': [],
      'payments': [],
    });
    expect(b.account.businessName, 'ماركت الأمانة');
    expect(b.account.balance, -50);
    expect(b.aging.upTo30, 0);
  });
}
