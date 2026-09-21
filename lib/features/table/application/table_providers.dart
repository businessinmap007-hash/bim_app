import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/table_api.dart';

final tableApiProvider = Provider<TableApi>((ref) {
  return TableApi(ref.watch(apiClientProvider));
});

/// The business's pending table calls; the screen re-reads it on a timer.
final tableCallsProvider = FutureProvider.autoDispose<List<TableCall>>((ref) {
  return ref.watch(tableApiProvider).pendingCalls();
});
