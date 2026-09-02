/// A {id, name, name_ar, name_en} place reference — mirrors AddressResource's
/// `country`/`governorate`/`city` sub-objects.
class AddressPlace {
  final int id;
  final String nameAr;
  final String? nameEn;
  const AddressPlace({required this.id, required this.nameAr, this.nameEn});

  String localizedName(String languageCode) {
    if (languageCode == 'en' && (nameEn?.isNotEmpty ?? false)) return nameEn!;
    return nameAr;
  }

  factory AddressPlace.fromJson(Map<String, dynamic> json) => AddressPlace(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String? ?? json['name'] as String? ?? '',
    nameEn: json['name_en'] as String?,
  );
}

/// A saved delivery address — mirrors `AddressResource`.
class Address {
  final int id;
  final int? countryId;
  final int? governorateId;
  final int? cityId;
  final String? zipCode;
  final String addressLine;
  final double? lat;
  final double? lng;
  final bool isPrimary;
  final AddressPlace? country;
  final AddressPlace? governorate;
  final AddressPlace? city;

  const Address({
    required this.id,
    this.countryId,
    this.governorateId,
    this.cityId,
    this.zipCode,
    required this.addressLine,
    this.lat,
    this.lng,
    this.isPrimary = false,
    this.country,
    this.governorate,
    this.city,
  });

  String summary(String languageCode) {
    final place = [
      governorate?.localizedName(languageCode),
      city?.localizedName(languageCode),
    ].whereType<String>().where((s) => s.isNotEmpty).join(' — ');
    return place.isEmpty ? addressLine : '$addressLine ($place)';
  }

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as int,
    countryId: (json['country_id'] as num?)?.toInt(),
    governorateId: (json['governorate_id'] as num?)?.toInt(),
    cityId: (json['city_id'] as num?)?.toInt(),
    zipCode: json['zip_code'] as String?,
    addressLine: json['address_line'] as String? ?? '',
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    isPrimary: json['is_primary'] as bool? ?? false,
    country: json['country'] != null ? AddressPlace.fromJson(json['country'] as Map<String, dynamic>) : null,
    governorate: json['governorate'] != null
        ? AddressPlace.fromJson(json['governorate'] as Map<String, dynamic>)
        : null,
    city: json['city'] != null ? AddressPlace.fromJson(json['city'] as Map<String, dynamic>) : null,
  );
}
