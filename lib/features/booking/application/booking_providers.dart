import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/booking_api.dart';
import '../data/models/booking_form.dart';

final bookingApiProvider = Provider<BookingApi>((ref) {
  return BookingApi(ref.watch(apiClientProvider));
});

final bookingFormProvider = FutureProvider.family<BookingFormPayload, int>((ref, businessId) {
  return ref.watch(bookingApiProvider).form(businessId);
});
