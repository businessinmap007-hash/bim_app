import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../business/presentation/screens/business_detail_screen.dart';
import '../../application/retail_discovery_providers.dart';
import '../../data/models/catalog_product_listing.dart';

/// Api\V2\RetailDiscoveryController::show() — one catalog product, every
/// business that sells it, cheapest first. Tapping a seller opens their
/// business page, where the existing per-business browse/add-to-cart flow
/// takes over.
class ProductOffersScreen extends ConsumerWidget {
  final int productId;
  const ProductOffersScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(productOffersProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopProductsTitle)),
      body: AsyncValueView(
        value: detailAsync,
        onRetry: () => ref.invalidate(productOffersProvider(productId)),
        builder: (context, product) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: product.image != null
                          ? CachedNetworkImage(imageUrl: product.image!, fit: BoxFit.cover)
                          : Container(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                              child: const Icon(Icons.inventory_2_outlined),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                        if (product.brand.isNotEmpty || product.package.isNotEmpty)
                          Text(
                            [product.brand, product.package].where((s) => s.isNotEmpty).join(' · '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (product.offers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(l10n.productOffersEmpty)),
                )
              else
                ...product.offers.map((offer) => _OfferTile(offer: offer)),
            ],
          );
        },
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final ProductOffer offer;
  const _OfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: offer.businessId)),
        ),
        leading: CircleAvatar(
          backgroundImage: offer.businessLogo != null ? NetworkImage(offer.businessLogo!) : null,
          child: offer.businessLogo == null ? const Icon(Icons.storefront_outlined) : null,
        ),
        title: Text(offer.businessName),
        subtitle: offer.stock != null ? Text('${l10n.productOffersStockLabel}: ${offer.stock}') : null,
        trailing: Text(
          '${offer.price.toStringAsFixed(0)} ${offer.currency}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
