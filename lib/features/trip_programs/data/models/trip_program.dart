/// «برنامج الرحلة» — mirrors Api\V2\TripProgramController / TripProgramService::present().
library;

import '../../../../core/env/env.dart';

class TripItemKind {
  static const text = 'text';
  static const room = 'room';
  static const image = 'image';
}

class TripProgramBrief {
  final int id;
  final String title;
  final String? summary;
  final String status;
  final int daysCount;

  const TripProgramBrief({required this.id, required this.title, this.summary, this.status = 'published', this.daysCount = 0});

  bool get isPublished => status == 'published';

  factory TripProgramBrief.fromJson(Map<String, dynamic> json) => TripProgramBrief(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String? ?? '',
    summary: json['summary'] as String?,
    status: json['status'] as String? ?? 'published',
    daysCount: (json['days_count'] as num?)?.toInt() ?? 0,
  );
}

/// A hotel's room as the company's customer reads it: the card, the company's price, where it comes from, what is left.
class TripRoom {
  final int? allocationId;
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
  final String guestScope;

  const TripRoom({
    this.allocationId,
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
    this.guestScope = 'all',
  });

  factory TripRoom.fromJson(Map<String, dynamic> json) => TripRoom(
    allocationId: (json['allocation_id'] as num?)?.toInt(),
    unitId: (json['bookable_id'] as num?)?.toInt() ?? (json['unit_id'] as num).toInt(),
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
    guestScope: json['guest_scope'] as String? ?? 'all',
  );
}

class TripItem {
  final int id;
  final String kind;
  final String? body;
  final List<String> images;
  final TripRoom? room;

  /// Room items only: false once the hotel stopped the allocation (the item keeps its words).
  final bool roomAvailable;

  const TripItem({required this.id, required this.kind, this.body, this.images = const [], this.room, this.roomAvailable = true});

  factory TripItem.fromJson(Map<String, dynamic> json) => TripItem(
    id: (json['id'] as num).toInt(),
    kind: json['kind'] as String? ?? TripItemKind.text,
    body: json['body'] as String?,
    images: [
      for (final i in (json['images'] as List<dynamic>? ?? const [])) ?Env.assetUrl((i as Map<String, dynamic>)['image'] as String?),
    ],
    room: json['room'] is Map<String, dynamic> ? TripRoom.fromJson(json['room'] as Map<String, dynamic>) : null,
    roomAvailable: json['room_available'] as bool? ?? true,
  );
}

class TripDay {
  final int id;
  final String? title;
  final List<TripItem> items;

  const TripDay({required this.id, this.title, this.items = const []});

  factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String?,
    items: [for (final i in (json['items'] as List<dynamic>? ?? const [])) TripItem.fromJson(i as Map<String, dynamic>)],
  );
}

class TripProgram {
  final int id;
  final int businessId;
  final String title;
  final String? summary;
  final String status;
  final List<TripDay> days;

  const TripProgram({required this.id, required this.businessId, required this.title, this.summary, this.status = 'draft', this.days = const []});

  bool get isPublished => status == 'published';

  factory TripProgram.fromJson(Map<String, dynamic> json) => TripProgram(
    id: (json['id'] as num).toInt(),
    businessId: (json['business_id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    summary: json['summary'] as String?,
    status: json['status'] as String? ?? 'draft',
    days: [for (final d in (json['days'] as List<dynamic>? ?? const [])) TripDay.fromJson(d as Map<String, dynamic>)],
  );
}
