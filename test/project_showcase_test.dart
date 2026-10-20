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

  test('a plan showcase post carries changes only', () {
    final post = BusinessPost.fromJson({
      'id': 9,
      'title': 'Eight weeks',
      'body': '',
      'images': [],
      'plan_showcase': {
        'kind': 'combined',
        'weeks': 9,
        'confirmed_months': 2,
        'months': [
          {'month': '2026-09', 'measured_on': '2026-10-01', 'change': {'weight_kg': -3.5, 'fat_percent': -3.5}},
        ],
        'total_change': {'weight_kg': -7, 'fat_percent': -7.0, 'muscle_mass_kg': null},
        'updated_on': '2026-10-02',
      },
    });

    final s = post.planShowcase!;
    expect(s.kind, 'combined');
    expect(s.totalChange['weight_kg'], -7.0);
    expect(s.totalChange.containsKey('muscle_mass_kg'), isFalse);
    expect(s.months.single.change['fat_percent'], -3.5);
    expect(post.showcase, isNull);
  });
}
