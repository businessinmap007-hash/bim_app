import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../../core/time/egypt_time.dart';

/// One end of a ride: ids the server checks against each other, plus the wording the customer picked.
class RidePlace {
  final int governorateId;
  final int cityId;
  final String label;
  final String city;

  const RidePlace({
    required this.governorateId,
    required this.cityId,
    required this.label,
    this.city = '',
  });

  Map<String, dynamic> toJson() => {
    'governorate_id': governorateId,
    'city_id': cityId,
    'label': label,
  };

  factory RidePlace.fromJson(Map<String, dynamic> json) => RidePlace(
    governorateId: (json['governorate_id'] as num?)?.toInt() ?? 0,
    cityId: (json['city_id'] as num?)?.toInt() ?? 0,
    label: json['label'] as String? ?? '',
    city: json['city'] as String? ?? '',
  );
}

/// The distance and the suggested price of a ride before it is asked for.
class RideQuoteResult {
  final bool known;
  final bool needsDistance;
  final double? distanceKm;
  final double? suggestedPrice;

  const RideQuoteResult({
    required this.known,
    required this.needsDistance,
    this.distanceKm,
    this.suggestedPrice,
  });

  factory RideQuoteResult.fromJson(Map<String, dynamic> json) =>
      RideQuoteResult(
        known: json['known'] as bool? ?? false,
        needsDistance: json['needs_distance'] as bool? ?? false,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        suggestedPrice: (json['suggested_price'] as num?)?.toDouble(),
      );
}

class RequestOffer {
  final int id;
  final double price;
  final bool acceptsBudget;
  final String? message;
  final int? etaMinutes;
  final String status;
  final int? businessId;
  final String? businessName;
  final String? businessLogo;

  const RequestOffer({
    required this.id,
    required this.price,
    required this.acceptsBudget,
    required this.status,
    this.message,
    this.etaMinutes,
    this.businessId,
    this.businessName,
    this.businessLogo,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';

  factory RequestOffer.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    return RequestOffer(
      id: (json['id'] as num).toInt(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      acceptsBudget: json['accepts_budget'] as bool? ?? false,
      message: json['message'] as String?,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'pending',
      businessId: (business?['id'] as num?)?.toInt(),
      businessName: business?['name'] as String?,
      businessLogo: business?['logo'] as String?,
    );
  }
}

/// A need posted to the platform (a ride today). The customer's copy carries every offer; the business's copy carries
/// only its own offer and how many others there are.
class ServiceRequestModel {
  final int id;
  final String kind;
  final String title;
  final String? details;
  final String status;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final double? budget;
  final double? suggestedPrice;
  final int offersCount;
  final int? bookingId;
  final RidePlace? origin;
  final RidePlace? destination;
  final int passengers;
  final double? distanceKm;
  final List<RequestOffer> offers;
  final RequestOffer? myOffer;
  final String? requesterFirstName;

  const ServiceRequestModel({
    required this.id,
    required this.kind,
    required this.title,
    required this.status,
    this.details,
    this.startsAt,
    this.expiresAt,
    this.budget,
    this.suggestedPrice,
    this.offersCount = 0,
    this.bookingId,
    this.origin,
    this.destination,
    this.passengers = 1,
    this.distanceKm,
    this.offers = const [],
    this.myOffer,
    this.requesterFirstName,
  });

  bool get isOpen => status == 'open';

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final params = json['params'] as Map<String, dynamic>? ?? const {};
    final origin = params['origin'] as Map<String, dynamic>?;
    final destination = params['destination'] as Map<String, dynamic>?;
    final my = json['my_offer'] as Map<String, dynamic>?;
    final requester = json['requester'] as Map<String, dynamic>?;

    return ServiceRequestModel(
      id: (json['id'] as num).toInt(),
      kind: json['kind'] as String? ?? 'ride',
      title: json['title'] as String? ?? '',
      details: json['details'] as String?,
      status: json['status'] as String? ?? 'open',
      startsAt: EgyptTime.tryParse(json['starts_at'] as String?),
      expiresAt: EgyptTime.tryParse(json['expires_at'] as String?),
      budget: (json['budget'] as num?)?.toDouble(),
      suggestedPrice: (json['suggested_price'] as num?)?.toDouble(),
      offersCount: (json['offers_count'] as num?)?.toInt() ?? 0,
      bookingId: (json['booking_id'] as num?)?.toInt(),
      origin: origin == null ? null : RidePlace.fromJson(origin),
      destination: destination == null ? null : RidePlace.fromJson(destination),
      passengers: (params['passengers'] as num?)?.toInt() ?? 1,
      distanceKm: (params['distance_km'] as num?)?.toDouble(),
      offers: (json['offers'] as List<dynamic>? ?? const [])
          .map((e) => RequestOffer.fromJson(e as Map<String, dynamic>))
          .toList(),
      myOffer: my == null ? null : RequestOffer.fromJson(my),
      requesterFirstName: requester?['first_name'] as String?,
    );
  }
}

/// The requests-and-offers core over HTTP — see Api\V2\ServiceRequestController. The customer posts, watches the offers
/// and picks one; the business sees the open requests it may answer and answers with a price.
class ServiceRequestsApi {
  final ApiClient _client;
  const ServiceRequestsApi(this._client);

  static String _stamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:00';
  }

  Future<RideQuoteResult> quote({
    required int originCityId,
    required int destinationCityId,
    double? distanceKm,
  }) async {
    final data =
        await _client.post(
              '/service-requests/quote',
              data: {
                'origin_city_id': originCityId,
                'destination_city_id': destinationCityId,
                'distance_km': ?distanceKm,
              },
            )
            as Map<String, dynamic>;
    return RideQuoteResult.fromJson(data);
  }

  Future<ServiceRequestModel> createRide({
    required RidePlace origin,
    required RidePlace destination,
    required int passengers,
    DateTime? startsAt,
    double? price,
    double? distanceKm,
    String? details,
  }) async {
    final data =
        await _client.post(
              '/service-requests',
              data: {
                'kind': 'ride',
                'origin': origin.toJson(),
                'destination': destination.toJson(),
                'passengers': passengers,
                if (startsAt != null) 'starts_at': _stamp(startsAt),
                'price': ?price,
                'distance_km': ?distanceKm,
                if (details != null && details.trim().isNotEmpty)
                  'details': details.trim(),
              },
            )
            as Map<String, dynamic>;
    return ServiceRequestModel.fromJson(
      data['request'] as Map<String, dynamic>,
    );
  }

  Future<Paginated<ServiceRequestModel>> mine({int page = 1}) async {
    final data =
        await _client.get('/service-requests', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, ServiceRequestModel.fromJson);
  }

  Future<ServiceRequestModel> show(int id) async {
    final data =
        await _client.get('/service-requests/$id') as Map<String, dynamic>;
    return ServiceRequestModel.fromJson(
      data['request'] as Map<String, dynamic>,
    );
  }

  Future<ServiceRequestModel> setPrice(int id, double price) async {
    final data =
        await _client.post(
              '/service-requests/$id/price',
              data: {'price': price},
            )
            as Map<String, dynamic>;
    return ServiceRequestModel.fromJson(
      data['request'] as Map<String, dynamic>,
    );
  }

  /// Picks an offer; returns the booking it became.
  Future<int> accept(int id, int offerId) async {
    final data =
        await _client.post('/service-requests/$id/offers/$offerId/accept')
            as Map<String, dynamic>;
    return (data['booking_id'] as num).toInt();
  }

  Future<void> cancel(int id) => _client.post('/service-requests/$id/cancel');

  // ─────────────────────── Business side ───────────────────────

  Future<Paginated<ServiceRequestModel>> incoming({int page = 1}) async {
    final data =
        await _client.get('/business/service-requests', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, ServiceRequestModel.fromJson);
  }

  Future<void> offer(
    int id, {
    double? price,
    bool acceptsBudget = false,
    String? message,
    int? etaMinutes,
  }) {
    return _client.post(
      '/business/service-requests/$id/offers',
      data: {
        if (acceptsBudget) 'accepts_budget': true else 'price': price,
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
        'eta_minutes': ?etaMinutes,
      },
    );
  }

  Future<void> withdraw(int id) =>
      _client.delete('/business/service-requests/$id/offers');
}
