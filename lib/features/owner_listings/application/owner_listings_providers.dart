import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/owner_listings_api.dart';

final ownerListingsApiProvider = Provider<OwnerListingsApi>((ref) {
  return OwnerListingsApi(ref.watch(apiClientProvider));
});

/// The categories (a closed list on the server) with the fields each one asks.
final ownerCategoriesProvider = FutureProvider.autoDispose<List<OwnerCategory>>(
  (ref) {
    return ref.watch(ownerListingsApiProvider).categories();
  },
);

final ownerBrowseProvider = FutureProvider.autoDispose
    .family<List<OwnerListing>, OwnerBrowseQuery>((ref, query) {
      return ref.watch(ownerListingsApiProvider).browse(query);
    });

final myOwnerListingsProvider = FutureProvider.autoDispose<List<OwnerListing>>((
  ref,
) {
  return ref.watch(ownerListingsApiProvider).mine();
});

final ownerListingProvider = FutureProvider.autoDispose
    .family<OwnerListing, int>((ref, id) {
      return ref.watch(ownerListingsApiProvider).show(id);
    });

final myOwnerInquiriesProvider = FutureProvider.autoDispose<List<OwnerInquiry>>(
  (ref) {
    return ref.watch(ownerListingsApiProvider).inquiries();
  },
);

final ownerInquiryProvider = FutureProvider.autoDispose
    .family<OwnerInquiry, int>((ref, id) {
      return ref.watch(ownerListingsApiProvider).inquiry(id);
    });

/// What the account must do to publish: a bronze+ guarantee or a seriousness deposit (priced in the control panel).
final ownerRequirementProvider = FutureProvider.autoDispose<OwnerRequirement>((
  ref,
) {
  return ref.watch(ownerListingsApiProvider).requirement();
});
