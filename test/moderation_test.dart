import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/moderation/data/moderation_api.dart';

void main() {
  test('an account that holds the content ability is a moderator', () {
    final base = {'id': 1, 'name': 'A', 'email': 'a@x.test', 'phone': '0100', 'type': 'client'};

    expect(AuthUser.fromJson(base).isModerator, isFalse);
    expect(AuthUser.fromJson({...base, 'is_moderator': true}).isModerator, isTrue);
  });

  test('a queue row reads the reasons, the author and the state', () {
    final item = ReportedItem.fromJson({
      'type': 'owner_listing',
      'id': 9,
      'reports': 3,
      'state': 'hidden',
      'title': 'Used phone',
      'excerpt': 'good',
      'reasons': [
        {'key': 'fraud', 'name': 'Fraud', 'count': 2},
        {'key': 'spam', 'name': 'Spam', 'count': 1},
      ],
      'details': ['fake photos'],
      'author': {'id': 4, 'name': 'Sara'},
      'price': 1500,
    });

    expect(item.isPost, isFalse);
    expect(item.reports, 3);
    expect(item.state, 'hidden');
    expect(item.authorName, 'Sara');
    expect(item.price, 1500.0);
    expect(item.reasons.map((r) => '${r.name}:${r.count}'), ['Fraud:2', 'Spam:1']);
    expect(item.details, ['fake photos']);
  });
}
