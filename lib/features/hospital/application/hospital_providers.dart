import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/hospital_api.dart';
import '../data/models/hospital_department.dart';
import '../data/models/hospital_procedure.dart';

final hospitalApiProvider = Provider<HospitalApi>((ref) => HospitalApi(ref.watch(apiClientProvider)));

/// A hospital's departments with their active doctors — what a patient reads on its page.
final hospitalDepartmentsProvider = FutureProvider.autoDispose.family<List<HospitalDepartment>, int>(
  (ref, hospitalId) => ref.watch(hospitalApiProvider).departments(hospitalId),
);

/// The hospital's own view, pending invitations included.
final myHospitalDepartmentsProvider = FutureProvider.autoDispose<List<HospitalDepartment>>(
  (ref) => ref.watch(hospitalApiProvider).myDepartments(),
);

/// A doctor's invitations and memberships.
final hospitalInvitationsProvider = FutureProvider.autoDispose<HospitalInvitations>(
  (ref) => ref.watch(hospitalApiProvider).invitations(),
);

/// What a hospital offers by kind — what a patient reads on its page.
final hospitalProceduresProvider = FutureProvider.autoDispose.family<List<ProcedureOfferingSection>, int>(
  (ref, hospitalId) => ref.watch(hospitalApiProvider).offeredProcedures(hospitalId),
);

/// The caller's own procedure requests as a patient.
final myProcedureRequestsProvider = FutureProvider.autoDispose<List<ProcedureRequestItem>>(
  (ref) => ref.watch(hospitalApiProvider).myProcedureRequests(),
);

/// The hospital's own catalogue: the platform list and its own entries, with what it offers.
final procedureCatalogProvider = FutureProvider.autoDispose<List<ProcedureCatalogSection>>(
  (ref) => ref.watch(hospitalApiProvider).procedureCatalog(),
);

/// The hospital's requests by tab: `incoming`, `upcoming`, `done`.
final hospitalProcedureRequestsProvider = FutureProvider.autoDispose.family<List<ProcedureRequestItem>, String>(
  (ref, tab) => ref.watch(hospitalApiProvider).hospitalProcedureRequests(tab),
);
