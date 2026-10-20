import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/projects/data/models/customer_project_view.dart';
import 'package:bim_app/features/projects/data/models/project_agreement.dart';
import 'package:bim_app/features/projects/data/models/project_timeline.dart';

void main() {
  test('a quantity reads as done / planned with its unit and a clamped ratio', () {
    final item = QuantityItem.fromJson({'id': 1, 'name': 'عدد الأعمدة', 'unit': 'عمود', 'planned': 24, 'done': 18});

    expect(item.line(), '18 / 24 عمود');
    expect(item.ratio, 0.75);
    expect(QuantityItem.fromJson({'id': 2, 'name': 'x', 'planned': 10, 'done': 30}).ratio, 1.0);
    expect(QuantityItem.fromJson({'id': 3, 'name': 'x', 'planned': 0, 'done': 5}).ratio, 0.0);
  });

  test('the agreement block carries the version in force, the pending requests and the history', () {
    final view = CustomerProjectView.fromJson({
      'viewer': 'customer',
      'project': {'id': 1, 'title': 'Tower', 'status': 'active', 'visibility': 'private', 'progress': 10, 'is_overdue': false, 'operation': {'type': 'booking', 'id': 5}},
      'tasks': <dynamic>[],
      'agreed': true,
      'agreement': {'version': 2, 'status': 'agreed', 'due_on': '2027-06-30', 'grace_until': '2027-07-30', 'content_hash': 'abcdef1234567890'},
      'versions': [{}, {}],
      'change_requests': [
        {'id': 7, 'type': 'extension', 'payload': {'extra_days': 20, 'grace_until': '2027-08-19'}, 'status': 'pending'},
        {'id': 6, 'type': 'scope', 'payload': {'op': 'planned', 'from': 100, 'to': 140}, 'status': 'rejected', 'decision_note': 'no'},
      ],
      'quantity_log': [
        {'field': 'planned', 'old': '24', 'new': '30', 'reason': 'design', 'by': 'Eng', 'task': 'Columns', 'at': '2027-01-02T10:00:00Z', 'via_request': 6},
      ],
    });

    expect(view.block.agreed, isTrue);
    expect(view.block.agreement?.version, 2);
    expect(view.block.agreement?.graceUntil, '2027-07-30');
    expect(view.block.versions, 2);
    expect(view.block.pendingRequests.map((r) => r.id), [7]);
    expect(view.block.pendingRequests.first.isExtension, isTrue);
    expect(view.block.log.single.viaRequest, isTrue);
  });

  test('a work knows its main stage, its place, its quantities and whether the start was approved', () {
    final row = ProjectTaskRow.fromJson({
      'id': 9,
      'title': 'النقاشة',
      'parent_id': 3,
      'zone': 'الدور الثالث / شقة 2',
      'weight': 6,
      'start_status': 'approved',
      'items': [{'id': 1, 'name': 'المساحة', 'unit': 'م²', 'planned': 80, 'done': 20}],
    });

    expect(row.parentId, 3);
    expect(row.zone, 'الدور الثالث / شقة 2');
    expect(row.items.single.ratio, 0.25);
    expect(row.startStatus, 'approved');
  });
}
