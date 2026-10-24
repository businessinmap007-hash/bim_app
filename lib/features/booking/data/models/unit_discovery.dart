import '../../../promotions/data/models/promotion.dart';
import '../../../../core/env/env.dart';
import '../../../../core/time/egypt_time.dart';

/// One priced add-on offered alongside a kind of unit («إفطار +٥٠»).
/// «محجوزة لك»: the hold this guest still has on a room, so they find it as they left it when they come back.
class MyHold {
  final int id;
  final DateTime startsAt;
  final DateTime endsAt;
  final int quantity;

  /// When it ends, worked out from the seconds left at the moment the answer arrived.
  final DateTime until;

  const MyHold({required this.id, required this.startsAt, required this.endsAt, this.quantity = 1, required this.until});

  Duration get left => until.difference(DateTime.now());

  bool get isLive => left.inSeconds > 0;

  /// «09:41»
  String get leftLabel {
    final s = left.inSeconds.clamp(0, 99999);

    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  static MyHold? fromJsonOrNull(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final starts = DateTime.tryParse((json['starts_at'] as String? ?? '').replaceFirst(' ', 'T'));
    final ends = DateTime.tryParse((json['ends_at'] as String? ?? '').replaceFirst(' ', 'T'));
    if (starts == null || ends == null) return null;

    return MyHold(
      id: (json['id'] as num).toInt(),
      startsAt: starts,
      endsAt: ends,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      until: DateTime.now().add(Duration(seconds: (json['seconds_left'] as num?)?.toInt() ?? 0)),
    );
  }
}

class UnitChoice {
  final int optionId;
  final String? name;
  final String adjustType; // 'amount' | 'percent'
  final double adjustValue;
  final bool perPerson;
  final double amount;

  const UnitChoice({
    required this.optionId,
    this.name,
    required this.adjustType,
    required this.adjustValue,
    required this.perPerson,
    required this.amount,
  });

  factory UnitChoice.fromJson(Map<String, dynamic> json) => UnitChoice(
    optionId: (json['option_id'] as num).toInt(),
    name: json['name'] as String?,
    adjustType: json['adjust_type'] as String? ?? 'amount',
    adjustValue: (json['adjust_value'] as num?)?.toDouble() ?? 0,
    perPerson: json['per_person'] as bool? ?? false,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
  );
}

/// One bookable unit as returned by Api\V2\UnitDiscoveryController — a real
/// room/table/pitch, with its own image and (when a date window was asked
/// for) whether it is actually free for it.
/// «Day use» — the room type is also sold through the day: a window and a flat price.
class DayUseOffer {
  final String from;
  final String to;
  final double price;
  const DayUseOffer({required this.from, required this.to, required this.price});

  factory DayUseOffer.fromJson(Map<String, dynamic> json) => DayUseOffer(
    from: json['from'] as String? ?? '09:00',
    to: json['to'] as String? ?? '18:00',
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );
}

class DiscoveredUnit {
  final int id;
  final String? code;
  final String? title;
  final String? label;
  final String? description;
  final int? capacity;
  final List<String> images;
  final double? price;
  final double? total;
  final int? periods;
  final String? periodUnit;
  final bool? available;
  final String? reason;

  /// «تحت التعامل»: someone else is filling in a booking for it right now (it frees itself if they walk away).
  final bool held;

  /// Promised to one of the hotel's partners: the guest may ask for it to be released.
  final bool heldForPartner;

  /// The hold this guest has on it right now, if any.
  final MyHold? myHold;

  /// null unless the hotel sells this room type through the day as well
  final DayUseOffer? dayUse;

  /// what this room carries that is already inside its price («إطلالة على المسبح») — the hotel ticked it on the room
  final List<String> features;

  /// «أسعار للمصريين والمقيمين فقط»: `all`, `locals` or `foreigners`.
  final String guestScope;

  /// What a guest may add to this room — the hotel's meal plan at its listed price (a room sold through a partner carries them here).
  final List<UnitChoice> choices;

  /// A card of a room type whose numbered rooms differ («غرفة فردية · إطلالة بحر»): the features it was priced with. The booking is made
  /// with them, and the hotel gives a number that carries them when the stay starts.
  final List<int> variantOptionIds;

  const DiscoveredUnit({
    required this.id,
    this.code,
    this.title,
    this.label,
    this.description,
    this.capacity,
    this.images = const [],
    this.price,
    this.total,
    this.periods,
    this.periodUnit,
    this.available,
    this.reason,
    this.held = false,
    this.heldForPartner = false,
    this.myHold,
    this.dayUse,
    this.features = const [],
    this.guestScope = 'all',
    this.choices = const [],
    this.variantOptionIds = const [],
  });

  /// Two cards of one room type share an id; what tells them apart is the features they carry.
  String get selectionKey => '$id:${variantOptionIds.join(',')}';

  String get displayTitle => (title != null && title!.isNotEmpty) ? title! : (label ?? code ?? '#$id');

  factory DiscoveredUnit.fromJson(Map<String, dynamic> json) => DiscoveredUnit(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String?,
    title: json['title'] as String?,
    label: json['label'] as String?,
    description: json['description'] as String?,
    capacity: (json['capacity'] as num?)?.toInt(),
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => Env.assetUrl((e as Map<String, dynamic>)['image'] as String?))
        .whereType<String>()
        .toList(),
    price: (json['price'] as num?)?.toDouble(),
    total: (json['total'] as num?)?.toDouble(),
    periods: (json['periods'] as num?)?.toInt(),
    periodUnit: json['period_unit'] as String?,
    available: json['available'] as bool?,
    reason: json['reason'] as String?,
    held: json['held'] as bool? ?? false,
    heldForPartner: json['held_for_partner'] as bool? ?? false,
    myHold: MyHold.fromJsonOrNull(json['my_hold']),
    guestScope: json['guest_scope'] as String? ?? 'all',
    variantOptionIds: [for (final v in json['option_ids'] as List<dynamic>? ?? const []) (v as num).toInt()],
    dayUse: json['day_use'] is Map<String, dynamic> ? DayUseOffer.fromJson(json['day_use'] as Map<String, dynamic>) : null,
    features: (json['modifiers'] as List<dynamic>? ?? [])
        .map((e) => (e as Map<String, dynamic>)['name'] as String?)
        .whereType<String>()
        .where((n) => n.isNotEmpty)
        .toList(),
  );
}

/// One kind of unit at a business («جناح», «غرفة مفردة») grouped by its line
/// option, with the price that kind sells at and every individual unit of
/// it.
class UnitKindGroup {
  final int? lineOptionId;
  final String? name;
  final String itemType;
  final int unitsCount;
  final int? availableCount;
  final double? price;
  final String? currency;
  final int? offeringId;

  /// «عروض الحجز»: the hotel's offer on this kind (the night after it, or the words of the rule).
  final ItemOffer? offer;
  final List<UnitChoice> choices;
  final List<DiscoveredUnit> units;

  const UnitKindGroup({
    this.lineOptionId,
    this.name,
    required this.itemType,
    required this.unitsCount,
    this.availableCount,
    this.price,
    this.currency,
    this.offeringId,
    this.offer,
    this.choices = const [],
    this.units = const [],
  });

  factory UnitKindGroup.fromJson(Map<String, dynamic> json) => UnitKindGroup(
    lineOptionId: (json['line_option_id'] as num?)?.toInt(),
    name: json['name'] as String?,
    itemType: json['item_type'] as String? ?? '',
    unitsCount: (json['units_count'] as num?)?.toInt() ?? 0,
    availableCount: (json['available_count'] as num?)?.toInt(),
    price: (json['price'] as num?)?.toDouble(),
    currency: json['currency'] as String?,
    offeringId: (json['offering_id'] as num?)?.toInt(),
    offer: ItemOffer.fromJsonOrNull(json['offer']),
    choices: (json['choices'] as List<dynamic>? ?? [])
        .map((e) => UnitChoice.fromJson(e as Map<String, dynamic>))
        .toList(),
    units: (json['units'] as List<dynamic>? ?? [])
        .map((e) => DiscoveredUnit.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// «شكل الحجز» — how this business's booking page is drawn, as the admin arranged it (`data.shape` of
/// `/discovery/units/{business}`; null for a trade nobody has put on a shape, which the app draws as it always did).
class UnitShape {
  final String code;
  final String name;
  final String pattern;
  final Map<String, dynamic> settings;

  const UnitShape({required this.code, required this.name, required this.pattern, this.settings = const {}});

  bool _flag(String key, bool fallback) => settings[key] is bool ? settings[key] as bool : fallback;

  /// rooms grouped under their kind, like the menu's sections — otherwise one flat list
  bool get sectioned => (settings['layout'] as String? ?? 'sections') == 'sections';
  bool get showPhotos => _flag('show_photos', true);
  bool get showPrice => _flag('show_price', true);
  bool get showCapacity => _flag('show_capacity', true);
  bool get showAvailability => _flag('show_availability', true);

  /// the unit first, then the add-ons, then the dates (the hotel's way) — or the dates first
  bool get unitFirst => (settings['pick_order'] as String? ?? 'unit_then_dates') == 'unit_then_dates';
  bool get askGuestCounts => _flag('ask_guest_counts', true);
  bool get askChildren => _flag('ask_children', true);
  bool get offerDayUse => _flag('offer_day_use', false);
  bool get pickProvider => _flag('pick_provider', false);
  bool get multiSelect => _flag('multi_select', false);
  bool get askAttachment => _flag('ask_attachment', false);
  bool get offerHomeService => _flag('offer_home_service', false);

  factory UnitShape.fromJson(Map<String, dynamic> json) => UnitShape(
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    pattern: json['pattern'] as String? ?? '',
    settings: (json['settings'] as Map<String, dynamic>?) ?? const {},
  );
}

/// A room another business (a hotel) gave this one to sell, at THIS business's own price — `partner_rooms` of the same answer.
/// The contract price and the quantities are the two parties' alone and never arrive here.
class PartnerRoom {
  final int allocationId;
  final int unitId;
  final int serviceId;
  final String itemType;
  final String label;
  final String? kind;
  final String? description;
  final int? capacity;
  final List<String> images;
  final List<String> features;
  final double price;
  final String currency;
  final String? fromName;
  final int availableQuantity;
  final bool available;
  final String? reason;
  final String guestScope;
  final List<UnitChoice> choices;
  final ItemOffer? offer;
  final MyHold? myHold;

  const PartnerRoom({
    required this.allocationId,
    required this.unitId,
    required this.serviceId,
    required this.itemType,
    required this.label,
    this.kind,
    this.description,
    this.capacity,
    this.images = const [],
    this.features = const [],
    required this.price,
    this.currency = 'EGP',
    this.fromName,
    this.availableQuantity = 0,
    this.available = true,
    this.reason,
    this.guestScope = 'all',
    this.choices = const [],
    this.offer,
    this.myHold,
  });

  factory PartnerRoom.fromJson(Map<String, dynamic> json) => PartnerRoom(
    allocationId: (json['allocation_id'] as num).toInt(),
    unitId: (json['bookable_id'] as num).toInt(),
    serviceId: (json['service_id'] as num?)?.toInt() ?? 0,
    itemType: json['item_type'] as String? ?? '',
    label: json['label'] as String? ?? '',
    kind: json['kind'] as String?,
    description: json['description'] as String?,
    capacity: (json['capacity'] as num?)?.toInt(),
    images: [
      for (final i in (json['images'] as List<dynamic>? ?? const [])) ?Env.assetUrl(i is Map<String, dynamic> ? i['image'] as String? : i.toString()),
    ],
    features: [for (final f in (json['features'] as List<dynamic>? ?? const [])) f.toString()],
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    fromName: (json['from'] is Map<String, dynamic>) ? (json['from'] as Map<String, dynamic>)['name'] as String? : null,
    availableQuantity: (json['available_quantity'] as num?)?.toInt() ?? 0,
    available: json['available'] as bool? ?? true,
    reason: json['reason'] as String?,
    guestScope: json['guest_scope'] as String? ?? 'all',
    choices: [for (final c in (json['choices'] as List<dynamic>? ?? const [])) UnitChoice.fromJson(c as Map<String, dynamic>)],
    offer: ItemOffer.fromJsonOrNull(json['offer']),
    myHold: MyHold.fromJsonOrNull(json['my_hold']),
  );
}

/// Everything `/discovery/units/{business}` says: the kinds with their units, and the shape the page is drawn in.
class UnitCatalog {
  final int? serviceId;
  final List<UnitKindGroup> kinds;
  final UnitShape? shape;

  /// «غرف الشركاء»: rooms of another business this one sells at its own price.
  final List<PartnerRoom> partnerRooms;

  /// How the business takes its appointments: `slots` (the customer picks a time) or `queue` (the next turn of the day).
  final String flow;

  const UnitCatalog({this.serviceId, this.kinds = const [], this.shape, this.flow = 'slots', this.partnerRooms = const []});

  bool get isQueue => flow == 'queue';

  bool get hasUnits => kinds.any((k) => k.units.isNotEmpty);

  factory UnitCatalog.fromJson(Map<String, dynamic> json) => UnitCatalog(
    serviceId: (json['service_id'] as num?)?.toInt(),
    kinds: (json['kinds'] as List<dynamic>? ?? [])
        .map((e) => UnitKindGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    shape: json['shape'] is Map<String, dynamic> ? UnitShape.fromJson(json['shape'] as Map<String, dynamic>) : null,
    flow: json['flow'] as String? ?? 'slots',
    partnerRooms: [for (final r in (json['partner_rooms'] as List<dynamic>? ?? const [])) PartnerRoom.fromJson(r as Map<String, dynamic>)],
  );
}

/// The turn a customer would get on a day, and when it should come — `GET /discovery/appointments/{id}/queue`.
class QueuePreview {
  final bool full;
  final bool closed;
  final int turn;
  final int ahead;
  final DateTime? expectedAt;
  final int durationMinutes;

  const QueuePreview({this.full = false, this.closed = false, this.turn = 1, this.ahead = 0, this.expectedAt, this.durationMinutes = 30});

  factory QueuePreview.fromJson(Map<String, dynamic> json) => QueuePreview(
    full: json['full'] as bool? ?? false,
    closed: json['closed'] as bool? ?? false,
    turn: (json['turn'] as num?)?.toInt() ?? 1,
    ahead: (json['ahead'] as num?)?.toInt() ?? 0,
    expectedAt: EgyptTime.tryParse((json['expected_at'] as String? ?? '').replaceFirst(' ', 'T')),
    durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
  );
}

/// One start time of a day grid: how many of the business's units are free for the asked duration from it.
class DayGridSlot {
  final DateTime startsAt;
  final DateTime endsAt;
  final int free;
  final List<int> unitIds;

  const DayGridSlot({required this.startsAt, required this.endsAt, required this.free, this.unitIds = const []});

  bool get isFree => free > 0;

  factory DayGridSlot.fromJson(Map<String, dynamic> json) => DayGridSlot(
    // wall-clock strings of the business's own day — read as they are, never shifted
    startsAt: EgyptTime.parse((json['starts_at'] as String).replaceFirst(' ', 'T')),
    endsAt: EgyptTime.parse((json['ends_at'] as String).replaceFirst(' ', 'T')),
    free: (json['free'] as num?)?.toInt() ?? 0,
    unitIds: (json['unit_ids'] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList(),
  );
}

/// `GET /discovery/units/{business}/day-grid` — «ملاعب وقاعات» and «طاولة»: one day as a grid of start times.
class DayGrid {
  final bool closed;
  final bool hoursKnown;
  final int unitsTotal;
  final String? opens;
  final String? closes;
  final List<DayGridSlot> slots;

  const DayGrid({this.closed = false, this.hoursKnown = false, this.unitsTotal = 0, this.opens, this.closes, this.slots = const []});

  factory DayGrid.fromJson(Map<String, dynamic> json) => DayGrid(
    closed: json['closed'] as bool? ?? false,
    hoursKnown: json['hours_known'] as bool? ?? false,
    unitsTotal: (json['units_total'] as num?)?.toInt() ?? 0,
    opens: json['opens'] as String?,
    closes: json['closes'] as String?,
    slots: (json['slots'] as List<dynamic>? ?? []).map((e) => DayGridSlot.fromJson(e as Map<String, dynamic>)).toList(),
  );
}
