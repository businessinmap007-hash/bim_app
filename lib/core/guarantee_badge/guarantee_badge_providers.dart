import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'guarantee_badge_info.dart';
import 'guarantee_badge_loader.dart';

final guaranteeBadgeLoaderProvider = Provider<GuaranteeBadgeLoader>((ref) => GuaranteeBadgeLoader(ref.watch(apiClientProvider).get));

/// The badge of one account (null = none). Any number of these asked together ride one request.
final guaranteeBadgeProvider = FutureProvider.autoDispose.family<GuaranteeBadgeInfo?, int>(
  (ref, userId) => ref.watch(guaranteeBadgeLoaderProvider).load(userId),
);
