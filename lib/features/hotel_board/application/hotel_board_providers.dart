import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/hotel_board_api.dart';
import '../data/models/occupancy_board.dart';

final hotelBoardApiProvider = Provider<HotelBoardApi>((ref) => HotelBoardApi(ref.watch(apiClientProvider)));

/// One month of the hotel's board; the key is the first day of the month.
final hotelBoardProvider = FutureProvider.autoDispose.family<OccupancyBoardData, DateTime>((ref, month) => ref.watch(hotelBoardApiProvider).month(month));
