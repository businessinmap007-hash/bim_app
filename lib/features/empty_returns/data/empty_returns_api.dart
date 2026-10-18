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
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
  }

  Future<void> cancel(int id) => _client.delete('/business/empty-returns/$id');
}
