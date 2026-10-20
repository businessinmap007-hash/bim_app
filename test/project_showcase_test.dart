import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/business/data/models/business_post.dart';
import 'package:bim_app/features/projects/data/models/project_showcase.dart';

void main() {
  test('a showcase post carries the live, anonymous results', () {
    final post = BusinessPost.fromJson({
      'id': 5,
      'type': 'post',
      'title': 'A villa in progress',
      'body': '',
      'images': [],
      'showcase': {
        'progress': 50,
        'stages': [
          {'title': 'Frame', 'progress': 50, 'works': 2, 'works_confirmed': 1, 'confirmed_on': '2026-10-20'},
        ],
        'photos': [],
        'updated_on': '2026-10-20',
      },
    });

    expect(post.showcase, isNotNull);
    expect(post.showcase!.progress, 50);
    expect(post.showcase!.stages.single.worksConfirmed, 1);
    expect(BusinessPost.fromJson({'id': 1, 'title': 't', 'body': 'b', 'images': []}).showcase, isNull);
  });

  test('the request says whether the business may ask again', () {
    ShowcaseRequest r(String s) => ShowcaseRequest.fromJsonOrNull({'id': 1, 'status': s, 'public_title': 'x'})!;

    expect(r('requested').canAsk, isFalse);
    expect(r('approved').isLive, isTrue);
    expect(r('declined').canAsk, isTrue);
    expect(r('withdrawn').canAsk, isTrue);
    expect(ShowcaseRequest.fromJsonOrNull(null), isNull);
  });
}
