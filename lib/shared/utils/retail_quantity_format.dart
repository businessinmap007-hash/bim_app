/// "20 kg" when a unit is set, else just "20" — the string plugged into
/// retailListingMinOrderQtyBadge/retailStorefrontMinQtyLabel, since a bare
/// number is ambiguous about whether it means kilos, cartons, or tons.
String formatRetailQty(int qty, String? unit) {
  final trimmedUnit = unit?.trim();
  return trimmedUnit == null || trimmedUnit.isEmpty ? '$qty' : '$qty $trimmedUnit';
}
