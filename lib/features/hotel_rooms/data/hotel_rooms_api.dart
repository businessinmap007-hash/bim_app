import '../../../core/env/env.dart';
import '../../../core/network/api_client.dart';

/// What the customer asked for: the hotel class (the stars), the place, and the price — null means «any».
class HotelRoomQuery {
  final int? classId;
  final int? governorateId;
  final int? cityId;
  final double? priceMin;
  final double? priceMax;

  const HotelRoomQuery({
    this.classId,
    this.governorateId,
    this.cityId,
    this.priceMin,
    this.priceMax,
  });

  /// How many filters are on — the number beside the filter button.
  int get activeCount => [
    classId,
    governorateId,
    cityId,
    priceMin,
    priceMax,
  ].where((v) => v != null).length;

  HotelRoomQuery copyWith({
    int? classId,
    int? governorateId,
    int? cityId,
    double? priceMin,
    double? priceMax,
    bool clearClass = false,
    bool clearGovernorate = false,
    bool clearCity = false,
    bool clearPrice = false,
  }) {
    return HotelRoomQuery(
      classId: clearClass ? null : (classId ?? this.classId),
      governorateId: clearGovernorate
          ? null
          : (governorateId ?? this.governorateId),
      cityId: (clearCity || clearGovernorate) ? null : (cityId ?? this.cityId),
      priceMin: clearPrice ? null : (priceMin ?? this.priceMin),
      priceMax: clearPrice ? null : (priceMax ?? this.priceMax),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HotelRoomQuery &&
      other.classId == classId &&
      other.governorateId == governorateId &&
      other.cityId == cityId &&
      other.priceMin == priceMin &&
      other.priceMax == priceMax;

  @override
  int get hashCode =>
      Object.hash(classId, governorateId, cityId, priceMin, priceMax);
}

class FilterOption {
  final int id;
  final String name;
  final int count;
  const FilterOption({
    required this.id,
    required this.name,
    required this.count,
  });

  factory FilterOption.fromJson(Map<String, dynamic> json) => FilterOption(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}

class HotelRoomFilters {
  final List<FilterOption> classes;
  final List<FilterOption> governorates;
  final List<FilterOption> cities;
  final double? priceMin;
  final double? priceMax;

  const HotelRoomFilters({
    this.classes = const [],
    this.governorates = const [],
    this.cities = const [],
    this.priceMin,
    this.priceMax,
  });

  factory HotelRoomFilters.fromJson(Map<String, dynamic> json) {
    List<FilterOption> list(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .map((e) => FilterOption.fromJson(e as Map<String, dynamic>))
            .toList();
    final price = json['price'] as Map<String, dynamic>? ?? const {};
    return HotelRoomFilters(
      classes: list('classes'),
      governorates: list('governorates'),
      cities: list('cities'),
      priceMin: (price['min'] as num?)?.toDouble(),
      priceMax: (price['max'] as num?)?.toDouble(),
    );
  }
}

/// A partner company's offer on the same room, beside the hotel's own price.
class PartnerOffer {
  final int offerId;
  final String? sellerName;
  final double price;
  final int? availableQuantity;

  const PartnerOffer({
    required this.offerId,
    required this.price,
    this.sellerName,
    this.availableQuantity,
  });

  factory PartnerOffer.fromJson(Map<String, dynamic> json) => PartnerOffer(
    offerId: (json['offer_id'] as num).toInt(),
    sellerName: (json['seller'] as Map<String, dynamic>?)?['name'] as String?,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    availableQuantity: (json['available_quantity'] as num?)?.toInt(),
  );
}

/// One room type at one hotel.
class HotelRoom {
  final int hotelId;
  final String hotelName;
  final String? className;
  final String? governorate;
  final String? city;
  final int unitId;
  final String roomName;
  final int? capacity;
  final String? imageUrl;
  final double price;
  final double bestPrice;
  final String currency;
  final List<PartnerOffer> partnerOffers;

  const HotelRoom({
    required this.hotelId,
    required this.hotelName,
    required this.unitId,
    required this.roomName,
    required this.price,
    required this.bestPrice,
    required this.currency,
    this.className,
    this.governorate,
    this.city,
    this.capacity,
    this.imageUrl,
    this.partnerOffers = const [],
  });

  /// The partner offer when it undercuts the hotel — what the card points at.
  PartnerOffer? get cheaperPartner =>
      partnerOffers.isNotEmpty && partnerOffers.first.price < price
      ? partnerOffers.first
      : null;

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotel'] as Map<String, dynamic>? ?? const {};
    final room = json['room'] as Map<String, dynamic>? ?? const {};
    final image = room['image'];
    String? url;
    if (image is Map<String, dynamic>) {
      url = Env.assetUrl(
        (image['url'] ?? image['path'] ?? image['image']) as String?,
      );
    } else if (image is String) {
      url = Env.assetUrl(image);
    }

    return HotelRoom(
      hotelId: (hotel['id'] as num).toInt(),
      hotelName: hotel['name'] as String? ?? '',
      className: (hotel['class'] as Map<String, dynamic>?)?['name'] as String?,
      governorate: hotel['governorate'] as String?,
      city: hotel['city'] as String?,
      unitId: (room['unit_id'] as num).toInt(),
      roomName: room['name'] as String? ?? '',
      capacity: (room['capacity'] as num?)?.toInt(),
      imageUrl: url,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      bestPrice:
          (json['best_price'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0,
      currency: json['currency'] as String? ?? 'EGP',
      partnerOffers: (json['partner_offers'] as List<dynamic>? ?? const [])
          .map((e) => PartnerOffer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotelRoomsPage {
  final List<HotelRoom> rooms;
  final int total;
  const HotelRoomsPage({this.rooms = const [], this.total = 0});
}

/// Rooms across hotels by class, place and price — see Api\V2\HotelRoomSearchController.
class HotelRoomsApi {
  final ApiClient _client;
  const HotelRoomsApi(this._client);

  Future<HotelRoomFilters> filters({int? governorateId}) async {
    final data =
        await _client.get(
              '/discovery/hotel-rooms/filters',
              query: {'governorate_id': ?governorateId},
            )
            as Map<String, dynamic>;
    return HotelRoomFilters.fromJson(data);
  }

  Future<HotelRoomsPage> rooms(HotelRoomQuery q) async {
    final data =
        await _client.get(
              '/discovery/hotel-rooms',
              query: {
                'class_option_id': ?q.classId,
                'governorate_id': ?q.governorateId,
                'city_id': ?q.cityId,
                'price_min': ?q.priceMin,
                'price_max': ?q.priceMax,
                'per_page': 50,
              },
            )
            as Map<String, dynamic>;
    return HotelRoomsPage(
      rooms: (data['data'] as List<dynamic>? ?? const [])
          .map((e) => HotelRoom.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }
}
