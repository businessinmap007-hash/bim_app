import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../projects/data/models/project_showcase.dart';
import '../data/showcase_api.dart';

final showcaseApiProvider = Provider<ShowcaseApi>((ref) => ShowcaseApi(ref.watch(apiClientProvider)));

/// The trainer's request to show one plan's results, and where it stands.
final planShowcaseProvider = FutureProvider.autoDispose.family<ShowcaseRequest?, int>((ref, planId) {
  return ref.watch(showcaseApiProvider).trainerShowcase(planId);
});
