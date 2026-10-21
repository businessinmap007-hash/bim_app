import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/models/trip_program.dart';
import '../data/trip_programs_api.dart';

final tripProgramsApiProvider = Provider<TripProgramsApi>((ref) => TripProgramsApi(ref.watch(apiClientProvider)));

final myTripProgramsProvider = FutureProvider.autoDispose<List<TripProgramBrief>>((ref) => ref.watch(tripProgramsApiProvider).mine());

final tripRoomCardsProvider = FutureProvider.autoDispose<List<TripRoom>>((ref) => ref.watch(tripProgramsApiProvider).roomCards());

/// The programmes a business published (the programmes tab of its page).
final businessTripProgramsProvider = FutureProvider.autoDispose.family<List<TripProgramBrief>, int>((ref, businessId) => ref.watch(tripProgramsApiProvider).published(businessId));

final publishedTripProgramProvider = FutureProvider.autoDispose.family<TripProgram, ({int businessId, int id})>((ref, key) => ref.watch(tripProgramsApiProvider).publishedProgram(key.businessId, key.id));
