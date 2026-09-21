import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/location_api.dart';
import '../data/models/location_models.dart';

final locationApiProvider = Provider<LocationApi>((ref) {
  return LocationApi(ref.watch(apiClientProvider));
});

final countriesProvider = FutureProvider<List<LocationCountry>>((ref) {
  return ref.watch(locationApiProvider).countries();
});

final governoratesProvider = FutureProvider.family<List<LocationGovernorate>, int>((ref, countryId) {
  return ref.watch(locationApiProvider).governorates(countryId);
});

/// Server-side search inside one governorate: the list is capped, so a village that is
/// not among the first rows is only reachable by typing its name.
final citySearchProvider = FutureProvider.family<List<LocationCity>, ({int governorateId, String q})>((ref, key) {
  return ref.watch(locationApiProvider).cities(key.governorateId, q: key.q);
});

final citiesProvider = FutureProvider.family<List<LocationCity>, int>((ref, governorateId) {
  return ref.watch(locationApiProvider).cities(governorateId);
});
