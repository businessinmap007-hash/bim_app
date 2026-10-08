import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/hospital_api.dart';
import '../data/models/hospital_department.dart';

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
