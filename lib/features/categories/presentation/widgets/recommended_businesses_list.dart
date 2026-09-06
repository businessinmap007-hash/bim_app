import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../discovery/application/discovery_providers.dart';
import '../../../discovery/data/models/business_summary.dart';
import '../../../discovery/presentation/widgets/business_card.dart';

/// A vertical, rating-ranked business list — shared by the icon-row (أ) and
/// bar+menu (ج) Categories layouts, both of which show one "browse" surface
/// under their category picker (unlike the tabs+rows layout, whose rows
/// scroll horizontally and are built separately — a different enough shape
/// that unifying it here would cost more than the ~15 lines it would save).
///
/// [categoryId] null means platform-wide; passing one narrows to that root.
class RecommendedBusinessesList extends ConsumerWidget {
  final int? categoryId;

  const RecommendedBusinessesList({super.key, this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(recommendedBusinessesProvider(categoryId));

    return AsyncValueView<List<BusinessSummary>>(
      value: items,
      onRetry: () => ref.invalidate(recommendedBusinessesProvider(categoryId)),
      builder: (context, list) {
        if (list.isEmpty) {
          return Center(child: Text(l10n.categoriesRecommendedEmpty));
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(recommendedBusinessesProvider(categoryId)),
          child: ResponsiveCenter(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final business = list[index];
                return BusinessCard(
                  business: business,
                  onTap: () => context.push('/business/${business.id}'),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
