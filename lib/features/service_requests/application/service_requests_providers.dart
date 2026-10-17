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

/// The open requests this business may answer.
final incomingServiceRequestsProvider =
    FutureProvider.autoDispose<List<ServiceRequestModel>>((ref) async {
      return (await ref.watch(serviceRequestsApiProvider).incoming()).items;
    });
