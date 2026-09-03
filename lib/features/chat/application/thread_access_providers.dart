import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/thread_access_api.dart';

final threadAccessApiProvider = Provider<ThreadAccessApi>((ref) {
  return ThreadAccessApi(ref.watch(apiClientProvider));
});

/// autoDispose: a stale "you already answered" from an earlier visit must
/// never linger — this always re-checks when the banner mounts.
final threadAccessStatusProvider = FutureProvider.autoDispose.family<ThreadAccessStatus, int>((
  ref,
  threadId,
) {
  return ref.watch(threadAccessApiProvider).status(threadId);
});
