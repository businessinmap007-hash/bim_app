/// One priced row a business can point an offer at — a menu item, a retail
/// listing, or a business service price row, normalised to the one shape the
/// offer form actually needs (see OfferableResolver on the backend, which
/// reads this same current price rather than trusting a typed number).
class OfferableItem {
  final int id;
  final String label;
  final double price;
  final String currency;

  const OfferableItem({required this.id, required this.label, required this.price, required this.currency});
}
