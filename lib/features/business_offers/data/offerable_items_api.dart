import '../../business_menu/data/business_menu_api.dart';
import '../../business_prices/data/business_prices_api.dart';
import '../../retail_listings/data/retail_listings_api.dart';
import 'models/offerable_item.dart';

class OfferableItemsPage {
  final List<OfferableItem> items;
  final bool hasMore;
  const OfferableItemsPage({required this.items, required this.hasMore});
}

/// Sources an offer's `offerable_id` picker from the three existing "my
/// items" APIs (menu items, retail listings, service prices) rather than
/// building a fourth one — see OfferableResolver on the backend, which only
/// prices these three types.
class OfferableItemsApi {
  final BusinessMenuApi _menu;
  final RetailListingsApi _retail;
  final BusinessPricesApi _prices;

  const OfferableItemsApi(this._menu, this._retail, this._prices);

  Future<OfferableItemsPage> fetch(String offerableType, {String? q, int page = 1}) async {
    switch (offerableType) {
      case 'menu_item':
        final result = await _menu.items(q: q, page: page);
        return OfferableItemsPage(
          items: result.items
              .map(
                (e) => OfferableItem(id: e.id, label: e.nameAr, price: e.basePrice, currency: 'EGP'),
              )
              .toList(),
          hasMore: result.hasMore,
        );
      case 'product':
        final result = await _retail.list(q: q, page: page);
        return OfferableItemsPage(
          items: result.items
              .map(
                (e) => OfferableItem(
                  id: e.id,
                  label: e.productName ?? '#${e.id}',
                  price: e.price,
                  currency: e.currency,
                ),
              )
              .toList(),
          hasMore: result.hasMore,
        );
      case 'service':
        final result = await _prices.list(page: page);
        return OfferableItemsPage(
          items: result.items
              .map(
                (e) => OfferableItem(
                  id: e.id,
                  label: _firstNonEmpty([e.label, e.lineOption?.name, e.service.name]) ?? '#${e.id}',
                  price: e.price,
                  currency: e.currency,
                ),
              )
              .toList(),
          hasMore: result.hasMore,
        );
      default:
        return const OfferableItemsPage(items: [], hasMore: false);
    }
  }

  String? _firstNonEmpty(List<String?> candidates) {
    for (final c in candidates) {
      if (c != null && c.isNotEmpty) return c;
    }
    return null;
  }
}
