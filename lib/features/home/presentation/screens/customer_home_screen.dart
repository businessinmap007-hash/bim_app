import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../categories/application/categories_providers.dart';
import '../../../categories/data/models/category_root.dart';
import '../../../categories/presentation/widgets/category_root_tile.dart';

/// The customer's landing screen: root categories, per
/// business-in-map-roadmap.md's own priority order (accounts first, then
/// the category/discovery directory). Tapping a category drills into its
/// specialties, then into the business list for that specialty.
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roots = ref.watch(categoryRootsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeCustomerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.authLogout,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView<List<CategoryRoot>>(
        value: roots,
        onRetry: () => ref.invalidate(categoryRootsProvider),
        builder: (context, items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.categoriesEmpty));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(categoryRootsProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final category = items[index];
                return CategoryRootTile(
                  category: category,
                  onTap: () => context.push(
                    '/categories/${category.id}/specialties',
                    extra: category.nameAr,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
