import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/booking_terms.dart';
import 'booking_settings_controller.dart';

/// «شروط الحجز» as the server last saved them.
final bookingTermsProvider = FutureProvider.autoDispose<BookingTerms>((ref) {
  return ref.watch(bookingSettingsApiProvider).bookingTerms();
});
