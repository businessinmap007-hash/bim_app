import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/stay_settlement.dart';
import 'booking_providers.dart';

/// «تسويات بانتظارك»: the open settlements of this account — the icon beside the notifications shows while there is one.
/// Fetched on the home screen and again whenever a settlement screen changes something (invalidate it).
final openStaySettlementsProvider = FutureProvider.autoDispose<List<OpenStaySettlement>>((ref) {
  return ref.read(bookingApiProvider).openStaySettlements();
});
