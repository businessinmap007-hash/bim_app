import '../../../../core/env/env.dart';
import '../../../addresses/data/models/address.dart';
import 'rating_summary.dart';

/// Which tabs the client should surface — decided by the backend
/// (BusinessPageController::show), not guessed client-side from other data.
class BusinessSections {
  final bool posts;
  final bool menu;
  final bool services;

  const BusinessSections({
    required this.posts,
    required this.menu,
    required this.services,
  });

  bool get any => posts || menu || services;

  factory BusinessSections.fromJson(Map<String, dynamic> json) => BusinessSections(
    posts: json['posts'] as bool? ?? false,
    menu: json['menu'] as bool? ?? false,
    services: json['services'] as bool? ?? false,
  );
}

/// One "التسليم والاستلام" option the business ticked on its own profile
/// screen — `type` is the underlying `fulfillment_type` the checkout API
/// already accepts (delivery/pickup), `nameAr`/`nameEn` are exactly the
/// words the merchant sees and picks there. See
/// BusinessMenuSetting::fulfillmentMethodsFor().
class FulfillmentMethod {
  final int id;
  final String nameAr;
  final String nameEn;
  final String type;

  const FulfillmentMethod({required this.id, required this.nameAr, required this.nameEn, required this.type});

  factory FulfillmentMethod.fromJson(Map<String, dynamic> json) => FulfillmentMethod(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
    type: json['type'] as String? ?? 'delivery',
  );

  String label(String locale) => locale == 'en' ? nameEn : nameAr;
}

/// Which fulfillment methods the unified entry point above the menu should
/// offer — decided by the backend from what the business itself ticked on
/// its "التسليم والاستلام" options screen (BusinessPageController::show),
/// never guessed client-side. `dineIn` reflects whether the business has any
/// active table (BIM-13.3), not something ticked there.
class BusinessFulfillment {
  final List<FulfillmentMethod> methods;
  final bool dineIn;

  /// The flat charge added to a delivery order (null = free delivery).
  final double? deliveryFee;

  /// The business's city - a delivery to another city is priced per order.
  final int? cityId;
  final int? governorateId;

  const BusinessFulfillment({this.methods = const [], required this.dineIn, this.deliveryFee, this.cityId, this.governorateId});

  bool get any => methods.isNotEmpty || dineIn;

  /// The keys `FulfillmentSelectorBar`/`CheckoutScreen` choose between:
  /// each method's id (as a string) plus 'dine_in' when the business has an
  /// active table. Order matches what the merchant sees on its own screen.
  List<String> get selectionKeys => [
    ...methods.map((m) => m.id.toString()),
    if (dineIn) 'dine_in',
  ];

  /// The `fulfillment_type` CustomerCartService actually processes, for a
  /// `selectionKeys` value. Falls back to 'delivery' for an unrecognised or
  /// null key so checkout is never left without a type to submit.
  String typeOfSelection(String? key) {
    if (key == 'dine_in') return 'dine_in';

    final method = methods.where((m) => m.id.toString() == key).firstOrNull;

    return method?.type ?? 'delivery';
  }

  factory BusinessFulfillment.fromJson(Map<String, dynamic> json) => BusinessFulfillment(
    methods: (json['methods'] as List<dynamic>? ?? const [])
        .map((e) => FulfillmentMethod.fromJson(e as Map<String, dynamic>))
        .toList(),
    dineIn: json['dine_in'] as bool? ?? false,
    deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
    cityId: (json['city_id'] as num?)?.toInt(),
    governorateId: (json['governorate_id'] as num?)?.toInt(),
  );
}

/// A business's social media links — every field optional, the object itself
/// null when nothing was ever set (see BusinessPageController::socialLinks).
class SocialLinks {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final String? linkedin;

  const SocialLinks({this.facebook, this.instagram, this.twitter, this.youtube, this.linkedin});

  bool get isEmpty => facebook == null && instagram == null && twitter == null && youtube == null && linkedin == null;

  factory SocialLinks.fromJson(Map<String, dynamic> json) => SocialLinks(
    facebook: json['facebook'] as String?,
    instagram: json['instagram'] as String?,
    twitter: json['twitter'] as String?,
    youtube: json['youtube'] as String?,
    linkedin: json['linkedin'] as String?,
  );

  static SocialLinks? fromJsonOrNull(dynamic json) =>
      json is Map<String, dynamic> ? SocialLinks.fromJson(json) : null;
}

/// GET /businesses/{id} — the profile aggregate a search result opens into.
class BusinessProfile {
  final int id;
  final String name;
  final String? logoUrl;
  final String? coverUrl;
  final String? about;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final AddressPlace? country;
  final AddressPlace? governorate;
  final AddressPlace? city;
  final int? categoryId;
  final AddressPlace? categoryName;
  final int? categoryChildId;
  final AddressPlace? categoryChildName;
  final List<AddressPlace> options;
  final SocialLinks? social;
  final RatingSummary rating;
  final bool openNow;
  final bool isFollowing;
  final int postsCount;
  final int followersCount;
  final BusinessSections sections;
  final BusinessFulfillment fulfillment;
  final String? checkInTime;
  final String? checkOutTime;

  const BusinessProfile({
    required this.id,
    required this.name,
    this.logoUrl,
    this.coverUrl,
    this.about,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.country,
    this.governorate,
    this.city,
    this.categoryId,
    this.categoryName,
    this.categoryChildId,
    this.categoryChildName,
    this.options = const [],
    this.social,
    required this.rating,
    required this.openNow,
    this.isFollowing = false,
    required this.postsCount,
    this.followersCount = 0,
    required this.sections,
    required this.fulfillment,
    this.checkInTime,
    this.checkOutTime,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasCheckTimes => checkInTime != null || checkOutTime != null;

  BusinessProfile copyWith({bool? isFollowing, int? followersCount}) => BusinessProfile(
    id: id,
    name: name,
    logoUrl: logoUrl,
    coverUrl: coverUrl,
    about: about,
    phone: phone,
    address: address,
    latitude: latitude,
    longitude: longitude,
    country: country,
    governorate: governorate,
    city: city,
    categoryId: categoryId,
    categoryName: categoryName,
    categoryChildId: categoryChildId,
    categoryChildName: categoryChildName,
    options: options,
    social: social,
    rating: rating,
    openNow: openNow,
    isFollowing: isFollowing ?? this.isFollowing,
    postsCount: postsCount,
    followersCount: followersCount ?? this.followersCount,
    sections: sections,
    fulfillment: fulfillment,
    checkInTime: checkInTime,
    checkOutTime: checkOutTime,
  );

  /// The API returns "HH:mm:ss"; only "HH:mm" is worth showing.
  static String? _trimSeconds(String? value) =>
      value != null && value.length >= 5 ? value.substring(0, 5) : value;

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>? ?? const {};
    final counts = json['counts'] as Map<String, dynamic>? ?? const {};
    final location = json['location'] as Map<String, dynamic>? ?? const {};

    return BusinessProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      logoUrl: Env.assetUrl(json['logo'] as String?),
      coverUrl: Env.assetUrl(json['cover'] as String?),
      about: (json['about'] as String?)?.trim().isNotEmpty == true ? json['about'] as String : null,
      phone: json['phone'] as String?,
      address: (json['address'] as String?)?.trim().isNotEmpty == true ? json['address'] as String : null,
      latitude: (location['latitude'] as num?)?.toDouble(),
      longitude: (location['longitude'] as num?)?.toDouble(),
      country: location['country'] != null
          ? AddressPlace.fromJson(location['country'] as Map<String, dynamic>)
          : null,
      governorate: location['governorate'] != null
          ? AddressPlace.fromJson(location['governorate'] as Map<String, dynamic>)
          : null,
      city: location['city'] != null ? AddressPlace.fromJson(location['city'] as Map<String, dynamic>) : null,
      categoryId: (category['id'] as num?)?.toInt(),
      categoryName: category['name'] != null
          ? AddressPlace.fromJson(category['name'] as Map<String, dynamic>)
          : null,
      categoryChildId: (category['child_id'] as num?)?.toInt(),
      categoryChildName: category['child_name'] != null
          ? AddressPlace.fromJson(category['child_name'] as Map<String, dynamic>)
          : null,
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((e) => AddressPlace.fromJson(e as Map<String, dynamic>))
          .toList(),
      social: SocialLinks.fromJsonOrNull(json['social']),
      rating: RatingSummary.fromJson(json['rating'] as Map<String, dynamic>? ?? const {}),
      openNow: json['open_now'] as bool? ?? true,
      isFollowing: json['is_following'] as bool? ?? false,
      postsCount: (counts['posts'] as num?)?.toInt() ?? 0,
      followersCount: (counts['followers'] as num?)?.toInt() ?? 0,
      sections: BusinessSections.fromJson(json['sections'] as Map<String, dynamic>? ?? const {}),
      fulfillment: BusinessFulfillment.fromJson(json['fulfillment'] as Map<String, dynamic>? ?? const {}),
      checkInTime: _trimSeconds(json['check_in_time'] as String?),
      checkOutTime: _trimSeconds(json['check_out_time'] as String?),
    );
  }
}
