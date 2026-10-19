import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/auth/data/models/auth_user.dart';
import 'package:bim_app/features/moderation/data/moderation_api.dart';

void main() {
  test('an account that holds the content ability is a moderator', () {
    final base = {
      'id': 1,
      'name': 'A',
      'email': 'a@x.test',
      'phone': '0100',
      'type': 'client',
    };

    expect(AuthUser.fromJson(base).isModerator, isFalse);
    expect(
      AuthUser.fromJson({...base, 'is_moderator': true}).isModerator,
      isTrue,
    );
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
    expect(item.reasons.map((r) => '${r.name}:${r.count}'), [
      'Fraud:2',
      'Spam:1',
    ]);
    expect(item.details, ['fake photos']);
  });

  test('a row says who is dealing with it and whether that is me', () {
    final mine = ReportedItem.fromJson({
      'type': 'post',
      'id': 1,
      'reports': 1,
      'state': 'live',
      'handler': {'id': 7, 'name': 'Fahim'},
      'claimed_by_me': true,
      'locked': false,
    });
    final theirs = ReportedItem.fromJson({
      'type': 'post',
      'id': 2,
      'reports': 1,
      'state': 'live',
      'handler': {'id': 8, 'name': 'Sara'},
      'claimed_by_me': false,
      'locked': true,
    });
    final done = ReportedItem.fromJson({
      'type': 'post',
      'id': 3,
      'reports': 1,
      'state': 'hidden',
      'handled_by': 'Fahim',
    });

    expect(mine.claimedByMe, isTrue);
    expect(mine.locked, isFalse);
    expect(theirs.locked, isTrue);
    expect(theirs.handlerName, 'Sara');
    expect(done.handledBy, 'Fahim');
    expect(done.locked, isFalse);
  });
}
