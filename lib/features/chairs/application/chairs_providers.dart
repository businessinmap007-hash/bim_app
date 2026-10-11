import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/chairs_api.dart';
import '../data/models/service_chair.dart';

final chairsApiProvider = Provider<ChairsApi>((ref) => ChairsApi(ref.watch(apiClientProvider)));

/// The chairs a customer may choose from at a business (empty = one line).
final chairsDiscoveryProvider = FutureProvider.autoDispose.family<List<ServiceChair>, int>((ref, businessId) {
  return ref.watch(chairsApiProvider).discover(businessId);
});

final myChairsProvider = FutureProvider.autoDispose<List<ServiceChair>>((ref) => ref.watch(chairsApiProvider).mine());

/// The day's queue as the business runs it.
final businessQueueProvider = FutureProvider.autoDispose<BusinessQueue>((ref) => ref.watch(chairsApiProvider).queue());

/// «كرسيي»: the queue of the chairs this account sits at in an employer's business (a barber).
final myChairQueueProvider = FutureProvider.autoDispose.family<BusinessQueue, int>((ref, businessId) {
  return ref.watch(chairsApiProvider).queue(businessId: businessId, mine: true);
});

/// The staff of the business a chair may be given to.
final chairStaffProvider = FutureProvider.autoDispose<List<ChairStaffMember>>(
  (ref) => ref.watch(chairsApiProvider).staff(),
);
