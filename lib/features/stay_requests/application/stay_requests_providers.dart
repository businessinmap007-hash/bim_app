import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../booking_settings/application/booking_settings_controller.dart';
import '../data/models/stay_request.dart';
import '../data/stay_requests_api.dart';

final stayRequestsApiProvider = Provider<StayRequestsApi>((ref) => StayRequestsApi(ref.watch(apiClientProvider)));

/// What a guest's two buttons offer on this stay, and what they have already asked.
final stayRequestOptionsProvider = FutureProvider.autoDispose.family<StayRequestOptions, int>((ref, bookingId) {
  return ref.watch(stayRequestsApiProvider).options(bookingId);
});

/// The hotel's requests — `open` waits on the front desk, `done` is the finished ones.
final hotelStayRequestsProvider = FutureProvider.autoDispose.family<StayRequestsPayload, String>((ref, status) {
  return ref.watch(stayRequestsApiProvider).forHotel(status: status);
});

final stayServicesProvider = FutureProvider.autoDispose<StayServicesPayload>((ref) {
  return ref.watch(stayRequestsApiProvider).services();
});

/// Only a business that lets rooms (a `booking_stay` unit) has guests to hear from.
final hasStayUnitsProvider = FutureProvider.autoDispose<bool>((ref) async {
  final items = await ref.watch(bookingSettingsApiProvider).bookableItems();
  return items.any((i) => i.itemType == 'booking_stay');
});
