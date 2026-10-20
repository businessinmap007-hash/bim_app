import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/projects/data/models/customer_project_view.dart';

Map<String, dynamic> _task(int id, String status, {String? approval, Map<String, dynamic>? assignee}) => {
  'id': id,
  'title': 'Stage $id',
  'status': status,
  'progress': status == 'done' ? 100 : 20,
  'requires_approval': approval != null,
  'approval_status': approval,
  'assignee': assignee,
  'photos': <dynamic>[],
};

void main() {
  test('the current stage is the first one not done, and approvals waiting are counted', () {
    final view = CustomerProjectView.fromJson({
      'viewer': 'customer',
      'project': {'id': 1, 'title': 'Kitchen', 'status': 'active', 'visibility': 'private', 'progress': 40, 'is_overdue': false},
      'tasks': [
        _task(1, 'done', approval: 'approved'),
        _task(2, 'done', approval: 'pending'),
        _task(3, 'in_progress', assignee: {'id': 9, 'name': 'Ahmed', 'title': 'Electrician'}),
      ],
    });

    expect(view.currentStage?.id, 3);
    expect(view.currentStage?.assignee?.name, 'Ahmed');
    expect(view.waitingForApproval, 1);
    expect(view.tasks[1].waitsForMe, isTrue);
    expect(view.viewerIsBusiness, isFalse);
  });

  test('the business is told apart from the customer, and a finished project shows its last stage', () {
    final view = CustomerProjectView.fromJson({
      'viewer': 'business',
      'project': {'id': 2, 'title': 'Villa', 'status': 'completed', 'visibility': 'private', 'progress': 100, 'is_overdue': false},
      'tasks': [_task(1, 'done'), _task(2, 'done')],
    });

    expect(view.viewerIsBusiness, isTrue);
    expect(view.currentStage?.id, 2);
    expect(view.waitingForApproval, 0);
  });
}
