import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/empty_returns_api.dart';

final emptyReturnsApiProvider = Provider<EmptyReturnsApi>((ref) {
  return EmptyReturnsApi(ref.watch(apiClientProvider));
});

/// The line a customer is asking a ride for: origin city id, destination city id.
typedef EmptyReturnLine = ({int from, int to});

final emptyReturnsForLineProvider = FutureProvider.autoDispose
    .family<List<EmptyReturnOffer>, EmptyReturnLine>((ref, line) {
      return ref
          .watch(emptyReturnsApiProvider)
          .forLine(originCityId: line.from, destinationCityId: line.to);
    });

final myEmptyReturnsProvider =
    FutureProvider.autoDispose<List<EmptyReturnOffer>>((ref) {
      return ref.watch(emptyReturnsApiProvider).mine();
    });
