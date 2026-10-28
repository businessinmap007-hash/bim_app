/// «موسم»: a stretch of dates a hotel prices on its own — its rooms (a % or an amount on every room type, or a night price for a type),
/// its meal plans, and the shortest stay that may arrive in it.
class HotelSeason {
  final int id;
  final String name;
  final DateTime start;
  final DateTime end;

  /// `percent` or `amount`, with [roomChangeValue] (may be negative) — null keeps the rooms at their own price
  final String? roomChangeType;
  final double? roomChangeValue;

  /// a night price for a room type in the season, by its id
  final Map<int, double> roomPrices;

  /// a meal plan's price in the season, by its option id
  final Map<int, double> mealPrices;
  final int? minNights;

  const HotelSeason({
    this.id = 0,
    required this.name,
    required this.start,
    required this.end,
    this.roomChangeType,
    this.roomChangeValue,
    this.roomPrices = const {},
    this.mealPrices = const {},
    this.minNights,
  });

  static Map<int, double> _prices(Object? json) => {
    if (json is Map<String, dynamic>)
      for (final e in json.entries)
        if (int.tryParse(e.key) != null && e.value is num) int.parse(e.key): (e.value as num).toDouble(),
  };

  factory HotelSeason.fromJson(Map<String, dynamic> json) => HotelSeason(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    start: DateTime.parse(json['start_date'] as String),
    end: DateTime.parse(json['end_date'] as String),
    roomChangeType: json['room_change_type'] as String?,
    roomChangeValue: (json['room_change_value'] as num?)?.toDouble(),
    roomPrices: _prices(json['room_prices']),
    mealPrices: _prices(json['meal_prices']),
    minNights: (json['min_nights'] as num?)?.toInt(),
  );

  static String _day(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'name': name,
    'start_date': _day(start),
    'end_date': _day(end),
    'room_change_type': roomChangeValue == null ? null : (roomChangeType ?? 'percent'),
    'room_change_value': roomChangeValue,
    'room_prices': {for (final e in roomPrices.entries) '${e.key}': e.value},
    'meal_prices': {for (final e in mealPrices.entries) '${e.key}': e.value},
    'min_nights': minNights,
  };
}

/// What the seasons screen reads: the seasons, and the hotel's room types and meal plans the form prices.
class HotelSeasonsData {
  final List<HotelSeason> seasons;
  final List<({int id, String title})> roomTypes;
  final List<({int optionId, String name, double price})> mealPlans;

  const HotelSeasonsData({this.seasons = const [], this.roomTypes = const [], this.mealPlans = const []});

  factory HotelSeasonsData.fromJson(Map<String, dynamic> json) => HotelSeasonsData(
    seasons: [for (final s in json['seasons'] as List<dynamic>? ?? const []) HotelSeason.fromJson(s as Map<String, dynamic>)],
    roomTypes: [
      for (final r in json['room_types'] as List<dynamic>? ?? const [])
        (id: ((r as Map<String, dynamic>)['id'] as num).toInt(), title: r['title'] as String? ?? ''),
    ],
    mealPlans: [
      for (final m in json['meal_plans'] as List<dynamic>? ?? const [])
        (
          optionId: ((m as Map<String, dynamic>)['option_id'] as num).toInt(),
          name: m['name'] as String? ?? '',
          price: (m['price'] as num?)?.toDouble() ?? 0,
        ),
    ],
  );
}
