import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/dental_api.dart';
import '../data/models/dental_service.dart';

final dentalApiProvider = Provider<DentalApi>((ref) => DentalApi(ref.watch(apiClientProvider)));

/// What a dental clinic offers by kind — what a patient reads on its page.
final dentalServicesProvider = FutureProvider.autoDispose.family<List<DentalOfferingSection>, int>(
  (ref, clinicId) => ref.watch(dentalApiProvider).offered(clinicId),
);

/// The clinic's own catalogue: the platform list and its own entries, with what it offers.
final dentalCatalogProvider = FutureProvider.autoDispose<List<DentalCatalogSection>>(
  (ref) => ref.watch(dentalApiProvider).catalog(),
);
