import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/hotel_rooms_api.dart';

final hotelRoomsApiProvider = Provider<HotelRoomsApi>((ref) {
  return HotelRoomsApi(ref.watch(apiClientProvider));
});

/// The classes, places and price range a live hotel offers; [governorateId] adds that governorate's cities.
final hotelRoomFiltersProvider = FutureProvider.autoDispose
    .family<HotelRoomFilters, int?>((ref, governorateId) {
      return ref
          .watch(hotelRoomsApiProvider)
          .filters(governorateId: governorateId);
    });

/// The rooms that match what the customer picked.
final hotelRoomsProvider = FutureProvider.autoDispose
    .family<HotelRoomsPage, HotelRoomQuery>((ref, query) {
      return ref.watch(hotelRoomsApiProvider).rooms(query);
    });
