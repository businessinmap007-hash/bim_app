import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/course_api.dart';
import '../data/models/course.dart';

final courseApiProvider = Provider<CourseApi>((ref) => CourseApi(ref.watch(apiClientProvider)));

/// What a customer can join at a business: its courses, each with the groups still open.
final courseDiscoveryProvider = FutureProvider.autoDispose.family<List<CourseInfo>, int>((ref, businessId) {
  return ref.watch(courseApiProvider).discover(businessId);
});

/// The signed-in business's own courses and groups.
final myCoursesProvider = FutureProvider.autoDispose<BusinessCourses>((ref) {
  return ref.watch(courseApiProvider).mine();
});
