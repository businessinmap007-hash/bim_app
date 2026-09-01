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

final citiesProvider = FutureProvider.family<List<LocationCity>, int>((ref, governorateId) {
  return ref.watch(locationApiProvider).cities(governorateId);
});
