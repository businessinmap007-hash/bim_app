import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/promotion.dart';
import '../data/promotions_api.dart';

final promotionsApiProvider = Provider<PromotionsApi>((ref) => PromotionsApi(ref.watch(apiClientProvider)));

/// My promotions (a business).
final myPromotionsProvider = FutureProvider.autoDispose<MyPromotions>((ref) => ref.watch(promotionsApiProvider).mine());

/// My products by section, to pick what a promotion covers.
final promotionCatalogProvider = FutureProvider.autoDispose<PromotionCatalog>((ref) => ref.watch(promotionsApiProvider).catalog());

/// What is running on a business now (the offers tab of its page).
final businessPromotionsProvider = FutureProvider.autoDispose.family<List<Promotion>, int>((ref, businessId) {
  return ref.watch(promotionsApiProvider).forBusiness(businessId);
});
