import '../../../core/network/api_client.dart';
import 'models/booking.dart';
import 'models/booking_form.dart';

/// /bookings — the customer's own booking requests. See Api\V2\BookingController.
class BookingApi {
  final ApiClient _client;
  const BookingApi(this._client);

  /// What this business's booking screen must ask (Api\V2\BookingController::form).
  Future<BookingFormPayload> form(int businessId) async {
    final data = await _client.get('/bookings/form/$businessId') as Map<String, dynamic>;
    return BookingFormPayload.fromJson(data);
  }

  Future<Booking> create({
    required int businessId,
    required int serviceId,
    int? bookableId,
    int? offeringId,
    String? offeringType,
    DateTime? startsAt,
    DateTime? endsAt,
    bool allDay = false,
    int? partySize,
    int? quantity,
    String? notes,
    Map<String, dynamic>? meta,
    List<int> optionIds = const [],
  }) async {
    final data = await _client.post(
      '/bookings',
      data: {
        'business_id': businessId,
        'service_id': serviceId,
        if (bookableId != null) 'bookable_id': bookableId,
        if (offeringId != null) 'offering_id': offeringId,
        if (offeringType != null) 'offering_type': offeringType,
        if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
        if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
        'all_day': allDay,
        if (partySize != null) 'party_size': partySize,
        if (quantity != null) 'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (meta != null && meta.isNotEmpty) 'meta': meta,
        if (optionIds.isNotEmpty) 'option_ids': optionIds,
      },
    ) as Map<String, dynamic>;
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }
}
