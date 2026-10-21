/// «شاشة الغرف» — mirrors Api\V2\HotelOccupancyController / OccupancyBoard::month().
library;

class OccBooking {
  final int id;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final int quantity;
  final String? guest;

  /// `direct` (the hotel's own guest) or `partner` (sold by a travel agency through an allocation).
  final String source;
  final String? partner;
  final String? roomNumber;

  /// What the guest declared for a scoped room type: `local`, `foreign` or null.
  final String? guestOrigin;

  const OccBooking({
    required this.id,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    this.quantity = 1,
    this.guest,
    this.source = 'direct',
    this.partner,
    this.roomNumber,
    this.guestOrigin,
  });

  bool get viaPartner => source == 'partner';

  /// Wall-clock strings of the hotel's own day, read as they are.
  static DateTime _at(String? v) => DateTime.parse((v ?? '').replaceFirst(' ', 'T'));

  /// Does this stay hold [day]? A night is a day from check-in up to, not including, check-out; a stay inside one day holds that day.
  bool holds(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final from = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final to = DateTime(endsAt.year, endsAt.month, endsAt.day);

    return to == from ? d == from : (!d.isBefore(from) && d.isBefore(to));
  }

  factory OccBooking.fromJson(Map<String, dynamic> json) => OccBooking(
    id: (json['id'] as num).toInt(),
    status: json['status'] as String? ?? '',
    startsAt: _at(json['starts_at'] as String?),
    endsAt: _at(json['ends_at'] as String?),
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    guest: json['guest'] as String?,
    source: json['source'] as String? ?? 'direct',
    partner: json['partner'] as String?,
    roomNumber: json['room_number'] as String?,
    guestOrigin: json['guest_origin'] as String?,
  );
}

class OccUnit {
  final int id;
  final String label;
  final int stock;
  final String guestScope;
  final int heldForPartners;
  final List<int> booked;
  final List<int> viaPartner;
  final List<OccBooking> bookings;

  const OccUnit({
    required this.id,
    required this.label,
    required this.stock,
    this.guestScope = 'all',
    this.heldForPartners = 0,
    this.booked = const [],
    this.viaPartner = const [],
    this.bookings = const [],
  });

  factory OccUnit.fromJson(Map<String, dynamic> json) => OccUnit(
    id: (json['id'] as num).toInt(),
    label: json['label'] as String? ?? '',
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    guestScope: json['guest_scope'] as String? ?? 'all',
    heldForPartners: (json['held_for_partners'] as num?)?.toInt() ?? 0,
    booked: [for (final v in (json['booked'] as List<dynamic>? ?? const [])) (v as num).toInt()],
    viaPartner: [for (final v in (json['via_partner'] as List<dynamic>? ?? const [])) (v as num).toInt()],
    bookings: [for (final b in (json['bookings'] as List<dynamic>? ?? const [])) OccBooking.fromJson(b as Map<String, dynamic>)],
  );
}

class OccKind {
  final String name;
  final List<OccUnit> units;

  const OccKind({required this.name, this.units = const []});

  factory OccKind.fromJson(Map<String, dynamic> json) => OccKind(
    name: json['name'] as String? ?? '',
    units: [for (final u in (json['units'] as List<dynamic>? ?? const [])) OccUnit.fromJson(u as Map<String, dynamic>)],
  );
}

class OccupancyBoardData {
  final DateTime month;
  final int days;

  /// 0 = Sunday … 6 = Saturday, the weekday of the 1st.
  final int firstWeekday;
  final List<OccKind> kinds;

  const OccupancyBoardData({required this.month, required this.days, required this.firstWeekday, this.kinds = const []});

  factory OccupancyBoardData.fromJson(Map<String, dynamic> json) {
    final parts = (json['month'] as String? ?? '').split('-');

    return OccupancyBoardData(
      month: DateTime(int.tryParse(parts.first) ?? DateTime.now().year, parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1),
      days: (json['days'] as num?)?.toInt() ?? 30,
      firstWeekday: (json['first_weekday'] as num?)?.toInt() ?? 0,
      kinds: [for (final k in (json['kinds'] as List<dynamic>? ?? const [])) OccKind.fromJson(k as Map<String, dynamic>)],
    );
  }
}
