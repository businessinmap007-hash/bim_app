import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'assignee.dart';
import 'assignment_api.dart';

final assignmentApiProvider = Provider<AssignmentApi>((ref) => AssignmentApi(ref.watch(apiClientProvider)));

/// The providers one can assign to at the business I work for (family arg = the business a delegate acts for).
final businessProvidersProvider = FutureProvider.autoDispose.family<List<Assignee>, int?>(
  (ref, businessId) => ref.watch(assignmentApiProvider).providers(businessId: businessId),
);

/// The providers a customer sees at a business.
final publicProvidersProvider = FutureProvider.autoDispose.family<List<Assignee>, int>(
  (ref, businessId) => ref.watch(assignmentApiProvider).publicProviders(businessId),
);
