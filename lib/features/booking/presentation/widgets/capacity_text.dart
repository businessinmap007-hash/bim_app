import '../../../../l10n/app_localizations.dart';

/// «السعة: 2» — or, for a room type that names its children, «السعة: 2 بالغ + 2 طفل».
String capacityText(AppLocalizations l10n, int capacity, int? maxChildren) =>
    '${l10n.bookingCapacityLabel}: ${maxChildren != null && maxChildren > 0 ? l10n.roomOccupancy(capacity, maxChildren) : capacity}';
