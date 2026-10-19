import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/service_requests_api.dart';

final serviceRequestsApiProvider = Provider<ServiceRequestsApi>((ref) {
  return ServiceRequestsApi(ref.watch(apiClientProvider));
});

/// My requests, newest first (first page — a person rarely has more open at once).
final myServiceRequestsProvider =
    FutureProvider.autoDispose<List<ServiceRequestModel>>((ref) async {
      return (await ref.watch(serviceRequestsApiProvider).mine()).items;
    });

/// One of my requests with every offer on it.
final serviceRequestProvider = FutureProvider.autoDispose
    .family<ServiceRequestModel, int>((ref, id) {
      return ref.watch(serviceRequestsApiProvider).show(id);
    });

/// The open requests of one kind this business may answer.
final incomingServiceRequestsProvider = FutureProvider.autoDispose
    .family<List<ServiceRequestModel>, String>((ref, kind) async {
      return (await ref.watch(serviceRequestsApiProvider).incoming(kind: kind))
          .items;
    });

/// The kinds of request this business's trade answers — empty hides the requests tile.
final answerableRequestKindsProvider = FutureProvider.autoDispose<List<String>>(
  (ref) {
    return ref.watch(serviceRequestsApiProvider).answerableKinds();
  },
);

/// The trades a «أحتاج فنيًا» request picks from.
final homeTradesProvider = FutureProvider.autoDispose<List<CarOption>>((ref) {
  return ref.watch(serviceRequestsApiProvider).homeTrades();
});

/// The workshops and factories a «اطلب عرض سعر» request picks from.
final workTradesProvider = FutureProvider.autoDispose<List<CarOption>>((ref) {
  return ref.watch(serviceRequestsApiProvider).workTrades();
});

/// «استراحة»: is this business taking customers' requests right now?
final requestsAvailableProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(serviceRequestsApiProvider).available();
});

/// The kinds of car and the makes a «أريد سيارة» request picks from.
final carOptionsProvider = FutureProvider.autoDispose<CarOptions>((ref) {
  return ref.watch(serviceRequestsApiProvider).carOptions();
});
