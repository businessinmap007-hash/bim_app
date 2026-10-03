import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../discovery/application/discovery_providers.dart';
import '../../../discovery/data/models/business_summary.dart';
import '../../../discovery/presentation/widgets/business_card.dart';
import '../../../retail_discovery/application/retail_discovery_providers.dart';
import '../../../retail_discovery/data/models/catalog_product_listing.dart';
import '../../../retail_discovery/presentation/screens/retail_storefront_screen.dart';
import '../../../retail_discovery/presentation/widgets/retail_listing_card_tile.dart';

/// A vertical, rating-ranked business list — shared by the icon-row (أ) and
/// bar+menu (ج) Categories layouts, both of which show one "browse" surface
/// under their category picker (unlike the tabs+rows layout, whose rows
/// scroll horizontally and are built separately — a different enough shape
/// that unifying it here would cost more than the ~15 lines it would save).
///
/// [categoryId] null means platform-wide; passing one narrows to that root.
/// [serviceId] narrows to businesses pricing that platform service (see the
/// service-type chip row) — independent of, and combinable with, [categoryId].
///
/// The "Retail" service is a special case: a bare business card says
/// nothing about what a seller actually carries, so once the customer picks
/// it this delegates to [_RetailListingsFeed] instead — one card per
/// LISTING (business + product + price; see RetailListingCard) rather than
/// per business.
class RecommendedBusinessesList extends ConsumerWidget {
  final int? categoryId;
  final int? serviceId;

  const RecommendedBusinessesList({super.key, this.categoryId, this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (serviceId != null) {
      final services = ref.watch(serviceTypesProvider).valueOrNull ?? const [];
      final isRetail = services.any((s) => s.id == serviceId && s.key == 'retail');
      if (isRetail) return const _RetailListingsFeed();
    }

    final filter = (categoryId: categoryId, serviceId: serviceId);
    final items = ref.watch(recommendedBusinessesProvider(filter));

    return AsyncValueView<List<BusinessSummary>>(
      value: items,
      onRetry: () => ref.invalidate(recommendedBusinessesProvider(filter)),
      builder: (context, list) {
        if (list.isEmpty) {
          return Center(child: Text(l10n.categoriesRecommendedEmpty));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(recommendedBusinessesProvider(filter)),
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

/// The "Retail" service's own feed — one card per LISTING, narrowed by
/// [selectedCategoryRootIdProvider] exactly like the generic business list
/// above is by [categoryId].
class _RetailListingsFeed extends ConsumerWidget {
  const _RetailListingsFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(retailListingsProvider);

    return AsyncValueView<List<RetailListingCard>>(
      value: items,
      onRetry: () => ref.invalidate(retailListingsProvider),
      builder: (context, list) {
        if (list.isEmpty) {
          return Center(child: Text(l10n.retailListingsFeedEmpty));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(retailListingsProvider),
          child: ResponsiveCenter(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final listing = list[index];
                return RetailListingCardTile(
                  listing: listing,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RetailStorefrontScreen(businessId: listing.businessId)),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
