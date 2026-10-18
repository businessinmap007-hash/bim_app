import '../../../core/network/api_client.dart';
import '../../../core/time/egypt_time.dart';

/// The reference fare of a ride and what a «راجع فاضي» starts from (half of it — the driver changes it).
class EmptyReturnQuote {
  final bool known;
  final bool needsDistance;
  final double? distanceKm;
  final double? referencePrice;
  final double? suggestedPrice;

  const EmptyReturnQuote({
    required this.known,
    required this.needsDistance,
    this.distanceKm,
    this.referencePrice,
    this.suggestedPrice,
  });

  factory EmptyReturnQuote.fromJson(Map<String, dynamic> json) =>
      EmptyReturnQuote(
        known: json['known'] as bool? ?? false,
        needsDistance: json['needs_distance'] as bool? ?? false,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        referencePrice: (json['reference_price'] as num?)?.toDouble(),
        suggestedPrice: (json['suggested_price'] as num?)?.toDouble(),
      );
}

/// One empty return: a limousine driver going back on a line, at his own (lower) price for the whole car.
class EmptyReturnOffer {
  final int id;
  final String status;
  final int? driverId;
  final String? driverName;
  final String? driverLogo;
  final String originCity;
  final String destinationCity;
  final DateTime? departsAt;
  final double price;
  final double? referencePrice;
  final int? savingPercent;
  final String currency;
  final int seats;
  final String? vehicleLabel;
  final String? notes;
  final bool isAhead;
  final bool exactMatch;
  final bool hasGuarantee;
  final double starsAverage;
  final int reviewCount;

  const EmptyReturnOffer({
    required this.id,
    required this.status,
    required this.originCity,
    required this.destinationCity,
    required this.price,
    required this.currency,
    required this.seats,
    required this.isAhead,
    required this.exactMatch,
    required this.hasGuarantee,
    required this.starsAverage,
    required this.reviewCount,
    this.driverId,
    this.driverName,
    this.driverLogo,
    this.departsAt,
    this.referencePrice,
    this.savingPercent,
    this.vehicleLabel,
    this.notes,
  });

  factory EmptyReturnOffer.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final origin = json['origin'] as Map<String, dynamic>? ?? const {};
    final destination =
        json['destination'] as Map<String, dynamic>? ?? const {};
    final trust = json['trust'] as Map<String, dynamic>?;
    return EmptyReturnOffer(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'active',
      driverId: (driver?['id'] as num?)?.toInt(),
      driverName: driver?['name'] as String?,
      driverLogo: driver?['logo'] as String?,
      originCity: origin['city'] as String? ?? '',
      destinationCity: destination['city'] as String? ?? '',
      departsAt: EgyptTime.tryParse(json['departs_at'] as String?),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      referencePrice: (json['reference_price'] as num?)?.toDouble(),
      savingPercent: (json['saving_percent'] as num?)?.toInt(),
      currency: json['currency'] as String? ?? 'EGP',
      seats: (json['seats'] as num?)?.toInt() ?? 4,
      vehicleLabel: json['vehicle_label'] as String?,
      notes: json['notes'] as String?,
      isAhead: json['is_ahead'] as bool? ?? true,
      exactMatch: json['exact_match'] as bool? ?? false,
      hasGuarantee: trust?['has_active_guarantee'] as bool? ?? false,
      starsAverage: (trust?['stars_average'] as num?)?.toDouble() ?? 0,
      reviewCount: (trust?['review_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A place on the way back, with the ids the location picker needs.
class SuggestedPlace {
  final int countryId;
  final int governorateId;
  final int cityId;
  final String governorate;
  final String city;

  const SuggestedPlace({
    required this.countryId,
    required this.governorateId,
    required this.cityId,
    required this.governorate,
    required this.city,
  });

  /// «governorate — city», the label every producer of a location selection builds.
  String get label => '$governorate — $city';

  factory SuggestedPlace.fromJson(Map<String, dynamic> json) => SuggestedPlace(
    countryId: (json['country_id'] as num?)?.toInt() ?? 0,
    governorateId: (json['governorate_id'] as num).toInt(),
    cityId: (json['city_id'] as num).toInt(),
    governorate: json['governorate'] as String? ?? '',
    city: json['city'] as String? ?? '',
  );
}

/// The way back of one of the driver's own rides, worked out by the server (the line swapped, the usual fare, a
/// starting price and a time to leave).
class EmptyReturnSuggestion {
  final int bookingId;
  final DateTime? rideStartsAt;
  final SuggestedPlace from;
  final SuggestedPlace to;
  final double? referencePrice;
  final double? suggestedPrice;
  final DateTime? suggestedDepartsAt;
  final int passengers;

  const EmptyReturnSuggestion({
    required this.bookingId,
    required this.from,
    required this.to,
    required this.passengers,
    this.rideStartsAt,
    this.referencePrice,
    this.suggestedPrice,
    this.suggestedDepartsAt,
  });

  factory EmptyReturnSuggestion.fromJson(Map<String, dynamic> json) =>
      EmptyReturnSuggestion(
        bookingId: (json['booking_id'] as num).toInt(),
        rideStartsAt: EgyptTime.tryParse(json['ride_starts_at'] as String?),
        from: SuggestedPlace.fromJson(json['from'] as Map<String, dynamic>),
        to: SuggestedPlace.fromJson(json['to'] as Map<String, dynamic>),
        referencePrice: (json['reference_price'] as num?)?.toDouble(),
        suggestedPrice: (json['suggested_price'] as num?)?.toDouble(),
        suggestedDepartsAt: EgyptTime.tryParse(
          json['suggested_departs_at'] as String?,
        ),
        passengers: (json['passengers'] as num?)?.toInt() ?? 1,
      );
}

/// «راجع فاضي» — see Api\V2\EmptyReturnController.
class EmptyReturnsApi {
  final ApiClient _client;
  const EmptyReturnsApi(this._client);

  Future<EmptyReturnQuote> quote({
    required int originCityId,
    required int destinationCityId,
    double? distanceKm,
  }) async {
    final data =
        await _client.get(
              '/empty-returns/quote',
              query: {
                'origin_city_id': originCityId,
                'destination_city_id': destinationCityId,
                'distance_km': ?distanceKm,
              },
            )
            as Map<String, dynamic>;
    return EmptyReturnQuote.fromJson(data);
  }

  /// What a customer going from one city to the other is offered.
  Future<List<EmptyReturnOffer>> forLine({
    required int originCityId,
    required int destinationCityId,
  }) async {
    final data =
        await _client.get(
              '/empty-returns',
              query: {
                'origin_city_id': originCityId,
                'destination_city_id': destinationCityId,
              },
            )
            as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? const [])
        .map((e) => EmptyReturnOffer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The driver's own rides, each with its way back worked out.
  Future<List<EmptyReturnSuggestion>> suggestions() async {
    final data =
        await _client.get('/business/empty-returns/suggestions')
            as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? const [])
        .map((e) => EmptyReturnSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EmptyReturnOffer>> mine() async {
    final data =
        await _client.get('/business/empty-returns') as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? const [])
        .map((e) => EmptyReturnOffer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> publish({
    required int originCityId,
    required int destinationCityId,
    required DateTime departsAt,
    required double price,
    int? seats,
    double? distanceKm,
    String? notes,
    int? fromBookingId,
  }) async {
    await _client.post(
      '/business/empty-returns',
      data: {
        'origin_city_id': originCityId,
        'destination_city_id': destinationCityId,
        // Cairo wall-clock digits, exactly what the server stores
        'departs_at': departsAt.toIso8601String(),
        'price': price,
        'seats': ?seats,
        'distance_km': ?distanceKm,
        'from_booking_id': ?fromBookingId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
  }

  Future<void> cancel(int id) => _client.delete('/business/empty-returns/$id');
}
