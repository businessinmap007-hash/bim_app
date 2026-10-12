import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/specialty_services_api.dart';
import '../data/models/specialty_service.dart';

final specialtyServicesApiProvider = Provider<SpecialtyServicesApi>((ref) => SpecialtyServicesApi(ref.watch(apiClientProvider)));

/// What a dental clinic offers by kind — what a patient reads on its page.
final specialtyServicesProvider = FutureProvider.autoDispose.family<List<ServiceOfferingSection>, int>(
  (ref, clinicId) => ref.watch(specialtyServicesApiProvider).offered(clinicId),
);

/// The clinic's own catalogue: the platform list and its own entries, with what it offers.
final specialtyCatalogProvider = FutureProvider.autoDispose<List<ServiceCatalogSection>>(
  (ref) => ref.watch(specialtyServicesApiProvider).catalog(),
);
