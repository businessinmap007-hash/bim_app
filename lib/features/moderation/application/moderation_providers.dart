import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/moderation_api.dart';

final moderationApiProvider = Provider<ModerationApi>((ref) {
  return ModerationApi(ref.watch(apiClientProvider));
});

final reportReasonsProvider = FutureProvider.autoDispose<List<ReportReason>>((
  ref,
) {
  return ref.watch(moderationApiProvider).reasons();
});

/// The moderator's queue; the argument is "handled" (false = still open).
final reportQueueProvider = FutureProvider.autoDispose
    .family<List<ReportedItem>, bool>((ref, handled) {
      return ref.watch(moderationApiProvider).queue(handled: handled);
    });
