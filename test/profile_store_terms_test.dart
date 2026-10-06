import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/profile/application/profile_controller.dart';
import 'package:bim_app/features/profile/application/profile_options_controller.dart';
import 'package:bim_app/features/profile/data/models/profile_options.dart';
import 'package:bim_app/features/profile/data/profile_api.dart';

/// «شروط المتجر» moved into the profile — one place edits them, and one save keeps the terms and the attributes
/// together (the server replaces the whole set, so a tick left out would be erased).
class _FakeProfileApi implements ProfileApi {
  List<int> saved = const [];

  Map<String, dynamic> _json(List<int> selected) => {
    'child_id': 116,
    'terms': [
      {
        'id': 49,
        'name': 'التسليم والاستلام',
        'options': [
          {
            'id': 108,
            'name': 'توصيل طلبات',
            'selected': selected.contains(108),
          },
          {'id': 322, 'name': 'شحن', 'selected': selected.contains(322)},
        ],
      },
    ],
    'groups': [
      {
        'id': 7,
        'name': 'الدفع والسداد',
        'options': [
          {'id': 900, 'name': 'كاش', 'selected': selected.contains(900)},
        ],
      },
    ],
    'selected_ids': selected,
  };

  @override
  Future<ProfileOptionsPayload> showOptions() async =>
      ProfileOptionsPayload.fromJson(_json([108, 900]));

  @override
  Future<ProfileOptionsPayload> updateOptions(List<int> optionIds) async {
    saved = optionIds;
    return ProfileOptionsPayload.fromJson(_json(optionIds));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingLoadApi implements ProfileApi {
  int updates = 0;

  @override
  Future<ProfileOptionsPayload> showOptions() async =>
      throw Exception('offline');

  @override
  Future<ProfileOptionsPayload> updateOptions(List<int> optionIds) async {
    updates++;
    throw Exception('must not be called');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('the payload carries the store terms apart from the attributes', () {
    final payload = ProfileOptionsPayload.fromJson(
      _FakeProfileApi()._json([108]),
    );

    expect(payload.terms.single.name, 'التسليم والاستلام');
    expect(payload.terms.single.options.map((o) => o.name), [
      'توصيل طلبات',
      'شحن',
    ]);
    expect(payload.groups.single.name, 'الدفع والسداد');
    expect(payload.selectedIds, [108]);
  });

  test('an older server without terms still parses', () {
    final payload = ProfileOptionsPayload.fromJson({
      'child_id': 1,
      'groups': [],
      'selected_ids': [],
    });

    expect(payload.terms, isEmpty);
  });

  test('one save sends the terms and the attributes together', () async {
    final api = _FakeProfileApi();
    final container = ProviderContainer(
      overrides: [profileApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      profileOptionsControllerProvider.notifier,
    );
    await Future<void>.delayed(Duration.zero);

    controller.toggle(322, true); // a delivery term
    controller.toggle(108, false);
    await controller.save();

    expect(
      api.saved.toSet(),
      {322, 900},
      reason: 'the payment attribute kept, the delivery terms as ticked',
    );
    final state = container.read(profileOptionsControllerProvider);
    expect(
      state.terms.single.options.where((o) => o.selected).map((o) => o.name),
      ['شحن'],
    );
    expect(state.selectedIds, {322, 900});
  });

  test(
    'nothing is saved before the catalog was read - a failed load can never wipe what the store ticked',
    () async {
      final api = _FailingLoadApi();
      final container = ProviderContainer(
        overrides: [profileApiProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        profileOptionsControllerProvider.notifier,
      );
      await Future<void>.delayed(Duration.zero);

      final saved = await controller.save();

      expect(saved, isFalse);
      expect(
        api.updates,
        0,
        reason:
            'the server was never asked to replace the set with an empty one',
      );
    },
  );
}
