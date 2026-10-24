import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/partnership.dart';
import '../data/partnerships_api.dart';

final partnershipsApiProvider = Provider<PartnershipsApi>((ref) => PartnershipsApi(ref.watch(apiClientProvider)));

final myPartnershipsProvider = FutureProvider.autoDispose<List<Partnership>>((ref) => ref.watch(partnershipsApiProvider).mine());

final partnershipDetailProvider = FutureProvider.autoDispose.family<PartnershipDetail, int>((ref, id) => ref.watch(partnershipsApiProvider).show(id));

final grantableRoomsProvider = FutureProvider.autoDispose.family<List<GrantableRoom>, int>((ref, id) => ref.watch(partnershipsApiProvider).grantable(id));

final releaseRequestsProvider = FutureProvider.autoDispose<List<ReleaseRequest>>((ref) => ref.watch(partnershipsApiProvider).releaseRequests());
