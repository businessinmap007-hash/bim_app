/// Mirrors Api\V2\LocationController — the address book's own geography
/// pickers (249 countries, 27 governorates, 1,339 cities, Egypt-only today),
/// reused here for a profile's administrative location.
class LocationCountry {
  final int id;
  final String nameAr;
  final String? nameEn;

  const LocationCountry({required this.id, required this.nameAr, this.nameEn});

  String localizedName(String languageCode) {
    if (languageCode == 'en' && (nameEn?.isNotEmpty ?? false)) return nameEn!;
    return nameAr;
  }

  factory LocationCountry.fromJson(Map<String, dynamic> json) => LocationCountry(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
  );
}

class LocationGovernorate {
  final int id;
  final int countryId;
  final String nameAr;
  final String? nameEn;

  const LocationGovernorate({required this.id, required this.countryId, required this.nameAr, this.nameEn});

  String localizedName(String languageCode) {
    if (languageCode == 'en' && (nameEn?.isNotEmpty ?? false)) return nameEn!;
    return nameAr;
  }

  factory LocationGovernorate.fromJson(Map<String, dynamic> json) => LocationGovernorate(
    id: json['id'] as int,
    countryId: json['country_id'] as int,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
  );
}

class LocationCity {
  final int id;
  final int governorateId;
  final String nameAr;
  final String? nameEn;

  const LocationCity({required this.id, required this.governorateId, required this.nameAr, this.nameEn});

  String localizedName(String languageCode) {
    if (languageCode == 'en' && (nameEn?.isNotEmpty ?? false)) return nameEn!;
    return nameAr;
  }

  factory LocationCity.fromJson(Map<String, dynamic> json) => LocationCity(
    id: json['id'] as int,
    governorateId: json['governorate_id'] as int,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String?,
  );
}

/// GET /locations/nearest — GPS resolved to our own geography, or null when
/// nothing was within a confident distance (the caller falls back to the
/// manual picker in that case).
class NearestLocationMatch {
  final int cityId;
  final int governorateId;
  final int countryId;
  final String cityNameAr;
  final String? cityNameEn;
  final String governorateNameAr;
  final String? governorateNameEn;

  const NearestLocationMatch({
    required this.cityId,
    required this.governorateId,
    required this.countryId,
    required this.cityNameAr,
    this.cityNameEn,
    required this.governorateNameAr,
    this.governorateNameEn,
  });

  static NearestLocationMatch? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final city = json['city'] as Map<String, dynamic>;
    final governorate = json['governorate'] as Map<String, dynamic>?;
    return NearestLocationMatch(
      cityId: city['id'] as int,
      governorateId: city['governorate_id'] as int,
      countryId: json['country_id'] as int? ?? 0,
      cityNameAr: city['name_ar'] as String? ?? '',
      cityNameEn: city['name_en'] as String?,
      governorateNameAr: governorate?['name_ar'] as String? ?? '',
      governorateNameEn: governorate?['name_en'] as String?,
    );
  }
}
