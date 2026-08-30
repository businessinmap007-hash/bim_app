import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/categories_api.dart';
import '../data/models/category_root.dart';
import '../data/models/specialty.dart';

final categoriesApiProvider = Provider<CategoriesApi>((ref) {
  return CategoriesApi(ref.watch(apiClientProvider));
});

final categoryRootsProvider = FutureProvider<List<CategoryRoot>>((ref) {
  return ref.watch(categoriesApiProvider).roots();
});

final specialtiesProvider = FutureProvider.family<List<Specialty>, int>((
  ref,
  categoryId,
) {
  return ref.watch(categoriesApiProvider).specialties(categoryId);
});
