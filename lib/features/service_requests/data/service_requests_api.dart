import 'package:dio/dio.dart';

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

  /// The listing the business pointed at (a dealer answering «أريد سيارة» with the car he has).
  final int? itemId;
  final String? itemName;
  final double? itemPrice;

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
    this.itemId,
    this.itemName,
    this.itemPrice,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';

  factory RequestOffer.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final item = json['item'] as Map<String, dynamic>?;
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
      itemId: (item?['id'] as num?)?.toInt(),
      itemName: item?['name'] as String?,
      itemPrice: (item?['price'] as num?)?.toDouble(),
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

  /// «أحتاج فنيًا»: signed links to the photos of the problem (to the customer, and to a technician while he may answer)
  final List<String> photos;

  /// «أريد سيارة»: 'buy' | 'rent', and the words of what he wants.
  final String? deal;
  final String? vehicleTypeName;
  final String? brandName;
  final int? yearMin;
  final int? days;

  /// «اطلب عرض سعر»: what is wanted, how many (and of what), by when, and whether a maker of any governorate may answer.
  final String? what;
  final int? quantity;
  final String? unit;
  final DateTime? deadline;
  final bool nationwide;

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
    this.photos = const [],
    this.deal,
    this.vehicleTypeName,
    this.brandName,
    this.yearMin,
    this.days,
    this.what,
    this.quantity,
    this.unit,
    this.deadline,
    this.nationwide = false,
  });

  bool get isOpen => status == 'open';
  bool get isCarWanted => kind == 'car_wanted';
  bool get isHomeService => kind == 'home_service';
  bool get isWorkQuote => kind == 'work_quote';
  bool get isRentalWanted => deal == 'rent';

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
      photos: [
        for (final p in json['photos'] as List<dynamic>? ?? const []) '$p',
      ],
      deal: params['deal'] as String?,
      vehicleTypeName:
          (params['vehicle_type'] as Map<String, dynamic>?)?['name'] as String?,
      brandName: (params['brand'] as Map<String, dynamic>?)?['name'] as String?,
      yearMin: (params['year_min'] as num?)?.toInt(),
      days: (params['days'] as num?)?.toInt(),
      what: params['what'] as String?,
      quantity: (params['quantity'] as num?)?.toInt(),
      unit: params['unit'] as String?,
      deadline: DateTime.tryParse(params['deadline'] as String? ?? ''),
      nationwide: params['nationwide'] as bool? ?? false,
    );
  }
}

/// A kind of car or a make a «أريد سيارة» request picks from.
class CarOption {
  final int id;
  final String name;
  const CarOption({required this.id, required this.name});

  factory CarOption.fromJson(Map<String, dynamic> json) => CarOption(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
  );
}

class CarOptions {
  final List<CarOption> vehicleTypes;
  final List<CarOption> brands;
  const CarOptions({this.vehicleTypes = const [], this.brands = const []});

  factory CarOptions.fromJson(Map<String, dynamic> json) => CarOptions(
    vehicleTypes: (json['vehicle_types'] as List<dynamic>? ?? const [])
        .map((e) => CarOption.fromJson(e as Map<String, dynamic>))
        .toList(),
    brands: (json['brands'] as List<dynamic>? ?? const [])
        .map((e) => CarOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
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

  Future<CarOptions> carOptions() async {
    final data =
        await _client.get('/service-requests/car-options')
            as Map<String, dynamic>;
    return CarOptions.fromJson(data);
  }

  /// The trades a «أحتاج فنيًا» request picks from.
  Future<List<CarOption>> homeTrades() async {
    final data =
        await _client.get('/service-requests/home-trades')
            as Map<String, dynamic>;
    return (data['trades'] as List<dynamic>? ?? const [])
        .map((e) => CarOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The workshops and factories a «اطلب عرض سعر» request picks from.
  Future<List<CarOption>> workTrades() async {
    final data =
        await _client.get('/service-requests/work-trades')
            as Map<String, dynamic>;
    return (data['trades'] as List<dynamic>? ?? const [])
        .map((e) => CarOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceRequestModel> createWorkQuote({
    required int tradeId,
    required String what,
    required String details,
    required int governorateId,
    int? cityId,
    int? quantity,
    String? unit,
    DateTime? deadline,
    double? maxPrice,
    bool nationwide = false,
  }) async {
    String two(int n) => n.toString().padLeft(2, '0');
    final data =
        await _client.post(
              '/service-requests',
              data: {
                'kind': 'work_quote',
                'trade_child_id': tradeId,
                'what': what.trim(),
                'details': details.trim(),
                'governorate_id': governorateId,
                'city_id': ?cityId,
                'quantity': ?quantity,
                if (unit != null && unit.trim().isNotEmpty) 'unit': unit.trim(),
                if (deadline != null)
                  'deadline':
                      '${deadline.year}-${two(deadline.month)}-${two(deadline.day)}',
                'max_price': ?maxPrice,
                if (nationwide) 'nationwide': true,
              },
            )
            as Map<String, dynamic>;
    return ServiceRequestModel.fromJson(
      data['request'] as Map<String, dynamic>,
    );
  }

  Future<ServiceRequestModel> createHomeService({
    required int tradeId,
    required int governorateId,
    required int cityId,
    required String details,
    DateTime? startsAt,
    double? maxPrice,
    List<String> photoPaths = const [],
  }) async {
    final fields = <String, dynamic>{
      'kind': 'home_service',
      'trade_child_id': tradeId,
      'governorate_id': governorateId,
      'city_id': cityId,
      'details': details.trim(),
      if (startsAt != null) 'starts_at': _stamp(startsAt),
      'max_price': ?maxPrice,
    };
    // the photos of the problem go as multipart; without them the request stays plain JSON
    final data =
        await _client.post(
              '/service-requests',
              data: photoPaths.isEmpty
                  ? fields
                  : FormData.fromMap({
                      ...fields,
                      'photos': [
                        for (final p in photoPaths)
                          await MultipartFile.fromFile(p),
                      ],
                    }),
            )
            as Map<String, dynamic>;
    return ServiceRequestModel.fromJson(
      data['request'] as Map<String, dynamic>,
    );
  }

  Future<ServiceRequestModel> createCarWanted({
    required String deal,
    required int governorateId,
    int? cityId,
    int? vehicleTypeOptionId,
    int? brandOptionId,
    int? yearMin,
    double? maxPrice,
    int? days,
    DateTime? startsAt,
    String? details,
  }) async {
    final data =
        await _client.post(
              '/service-requests',
              data: {
                'kind': 'car_wanted',
                'deal': deal,
                'governorate_id': governorateId,
                'city_id': ?cityId,
                'vehicle_type_option_id': ?vehicleTypeOptionId,
                'brand_option_id': ?brandOptionId,
                'year_min': ?yearMin,
                'max_price': ?maxPrice,
                if (deal == 'rent') 'days': ?days,
                if (startsAt != null) 'starts_at': _stamp(startsAt),
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

  /// Picks an offer; returns the booking it became. A home visit names which of his saved addresses the technician comes to.
  Future<int> accept(int id, int offerId, {int? addressId}) async {
    final data =
        await _client.post(
              '/service-requests/$id/offers/$offerId/accept',
              data: {'address_id': ?addressId},
            )
            as Map<String, dynamic>;
    return (data['booking_id'] as num).toInt();
  }

  Future<void> cancel(int id) => _client.post('/service-requests/$id/cancel');

  // ─────────────────────── Business side ───────────────────────

  Future<Paginated<ServiceRequestModel>> incoming({
    String kind = 'ride',
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/business/service-requests',
              query: {'kind': kind, 'page': page},
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, ServiceRequestModel.fromJson);
  }

  /// Which kinds of request this business's trade may answer (none: the requests tile stays hidden).
  Future<List<String>> answerableKinds() async {
    final data =
        await _client.get('/business/service-requests/kinds')
            as Map<String, dynamic>;
    return (data['kinds'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList();
  }

  /// «استراحة»: is the business taking requests (false = on a break)?
  Future<bool> available() async {
    final data =
        await _client.get('/business/service-requests/availability')
            as Map<String, dynamic>;
    return data['available'] as bool? ?? true;
  }

  Future<void> setAvailable(bool available) => _client.put(
    '/business/service-requests/availability',
    data: {'available': available},
  );

  Future<void> offer(
    int id, {
    double? price,
    bool acceptsBudget = false,
    String? message,
    int? etaMinutes,
    int? menuItemId,
  }) {
    return _client.post(
      '/business/service-requests/$id/offers',
      data: {
        if (acceptsBudget) 'accepts_budget': true else 'price': price,
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
        'eta_minutes': ?etaMinutes,
        'menu_item_id': ?menuItemId,
      },
    );
  }

  Future<void> withdraw(int id) =>
      _client.delete('/business/service-requests/$id/offers');
}
