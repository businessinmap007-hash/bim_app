/// «الشراكات والحصص» — mirrors Api\V2\PartnershipController / PartnershipService::present() / AllocationService::present().
library;

import '../../../../core/env/env.dart';

class PartnershipKind {
  static const agency = 'agency';
  static const reseller = 'reseller';
  static const supplier = 'supplier';
  static const corporate = 'corporate';
  static const hotelAllotment = 'hotel_allotment';

  static const all = [agency, reseller, supplier, corporate, hotelAllotment];
}

class PartnershipStatus {
  static const pending = 'pending';
  static const active = 'active';
  static const paused = 'paused';
  static const rejected = 'rejected';
  static const cancelled = 'cancelled';
}

class PartyBrief {
  final int id;
  final String name;
  final String? logo;

  const PartyBrief({required this.id, required this.name, this.logo});

  factory PartyBrief.fromJson(Map<String, dynamic> json) => PartyBrief(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    logo: json['logo'] as String?,
  );
}

class Partnership {
  final int id;

  /// `owner` (gave the invitation / the rooms) or `partner` (sells them).
  final String role;
  final String status;
  final String relationshipType;
  final PartyBrief? other;
  final String? note;
  final bool awaitingMyAnswer;

  const Partnership({
    required this.id,
    required this.role,
    required this.status,
    required this.relationshipType,
    this.other,
    this.note,
    this.awaitingMyAnswer = false,
  });

  bool get isOwner => role == 'owner';
  bool get isActive => status == PartnershipStatus.active;
  bool get isOpen => status == PartnershipStatus.pending || status == PartnershipStatus.active || status == PartnershipStatus.paused;

  factory Partnership.fromJson(Map<String, dynamic> json) => Partnership(
    id: (json['id'] as num).toInt(),
    role: json['role'] as String? ?? 'partner',
    status: json['status'] as String? ?? '',
    relationshipType: json['relationship_type'] as String? ?? '',
    other: json['other'] is Map<String, dynamic> ? PartyBrief.fromJson(json['other'] as Map<String, dynamic>) : null,
    note: (json['terms'] is Map<String, dynamic>) ? (json['terms'] as Map<String, dynamic>)['note'] as String? : null,
    awaitingMyAnswer: json['awaiting_my_answer'] as bool? ?? false,
  );
}

/// A room as a card: what it is, its photos and what it carries — the thing a trip programme places. Never a price.
class RoomCard {
  final int unitId;
  final String label;
  final String? kind;
  final String? description;
  final int? capacity;
  final List<String> images;
  final List<String> features;

  const RoomCard({required this.unitId, required this.label, this.kind, this.description, this.capacity, this.images = const [], this.features = const []});

  factory RoomCard.fromJson(Map<String, dynamic> json) => RoomCard(
    unitId: (json['unit_id'] as num).toInt(),
    label: json['label'] as String? ?? '',
    kind: json['kind'] as String?,
    description: json['description'] as String?,
    capacity: (json['capacity'] as num?)?.toInt(),
    images: [for (final i in (json['images'] as List<dynamic>? ?? const [])) ?Env.assetUrl(i is Map<String, dynamic> ? i['image'] as String? : i.toString())],
    features: [for (final f in (json['features'] as List<dynamic>? ?? const [])) f.toString()],
  );
}

class Allocation {
  final int id;
  final int partnershipId;
  final String status;
  final int quantityTotal;
  final int quantitySold;
  final int quantityReserved;
  final int quantityAvailable;
  final double contractPrice;
  final String markupType;
  final double markupValue;
  final double finalPrice;
  final String currency;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? minNights;
  final int? maxNights;
  final int releaseDaysBefore;

  /// `guaranteed` holds the rooms for the partner alone; the default `non_guaranteed` shares the pool with the hotel's own guests.
  final String allocationType;
  final RoomCard? room;

  /// Stays sold from it that are still ahead, and those the hotel has yet to answer — they stand when the allocation ends or stops.
  final int upcomingBookings;
  final int pendingBookings;

  const Allocation({
    required this.id,
    required this.partnershipId,
    required this.status,
    required this.quantityTotal,
    this.quantitySold = 0,
    this.quantityReserved = 0,
    this.quantityAvailable = 0,
    required this.contractPrice,
    this.markupType = 'none',
    this.markupValue = 0,
    required this.finalPrice,
    this.currency = 'EGP',
    this.startsAt,
    this.endsAt,
    this.minNights,
    this.maxNights,
    this.releaseDaysBefore = 0,
    this.allocationType = 'non_guaranteed',
    this.room,
    this.upcomingBookings = 0,
    this.pendingBookings = 0,
  });

  bool get isActive => status == 'active';

  factory Allocation.fromJson(Map<String, dynamic> json) => Allocation(
    id: (json['id'] as num).toInt(),
    partnershipId: (json['partnership_id'] as num).toInt(),
    status: json['status'] as String? ?? '',
    quantityTotal: (json['quantity_total'] as num?)?.toInt() ?? 0,
    quantitySold: (json['quantity_sold'] as num?)?.toInt() ?? 0,
    quantityReserved: (json['quantity_reserved'] as num?)?.toInt() ?? 0,
    quantityAvailable: (json['quantity_available'] as num?)?.toInt() ?? 0,
    contractPrice: (json['contract_price'] as num?)?.toDouble() ?? 0,
    markupType: json['markup_type'] as String? ?? 'none',
    markupValue: (json['markup_value'] as num?)?.toDouble() ?? 0,
    finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    // wall-clock nights of the stay («Y-m-d H:i:s»): read as they are, never shifted by an offset
    startsAt: DateTime.tryParse((json['starts_at'] as String? ?? '').replaceFirst(' ', 'T')),
    endsAt: DateTime.tryParse((json['ends_at'] as String? ?? '').replaceFirst(' ', 'T')),
    minNights: (json['min_nights'] as num?)?.toInt(),
    maxNights: (json['max_nights'] as num?)?.toInt(),
    releaseDaysBefore: (json['release_days_before'] as num?)?.toInt() ?? 0,
    allocationType: json['allocation_type'] as String? ?? 'non_guaranteed',
    room: json['room'] is Map<String, dynamic> ? RoomCard.fromJson(json['room'] as Map<String, dynamic>) : null,
    upcomingBookings: (json['upcoming_bookings'] as num?)?.toInt() ?? 0,
    pendingBookings: (json['pending_bookings'] as num?)?.toInt() ?? 0,
  );
}

class PartnershipDetail {
  final Partnership partnership;
  final List<Allocation> allocations;

  const PartnershipDetail({required this.partnership, this.allocations = const []});

  factory PartnershipDetail.fromJson(Map<String, dynamic> json) => PartnershipDetail(
    partnership: Partnership.fromJson(json['partnership'] as Map<String, dynamic>),
    allocations: [for (final a in (json['allocations'] as List<dynamic>? ?? const [])) Allocation.fromJson(a as Map<String, dynamic>)],
  );
}

/// One of the owner's rooms it may grant, with how many of it are still ungranted.
class GrantableRoom {
  final RoomCard card;
  final int capacityTotal;
  final int ungranted;

  const GrantableRoom({required this.card, required this.capacityTotal, required this.ungranted});

  factory GrantableRoom.fromJson(Map<String, dynamic> json) => GrantableRoom(
    card: RoomCard.fromJson(json),
    capacityTotal: (json['capacity_total'] as num?)?.toInt() ?? 0,
    ungranted: (json['ungranted'] as num?)?.toInt() ?? 0,
  );
}

/// A business found by name, to invite.
class BusinessHit {
  final int id;
  final String name;
  final String? logo;

  const BusinessHit({required this.id, required this.name, this.logo});

  factory BusinessHit.fromJson(Map<String, dynamic> json) => BusinessHit(id: (json['id'] as num).toInt(), name: json['name'] as String? ?? '', logo: json['logo'] as String?);
}

/// A guest of the hotel asks for a room held for this partner: the room and the dates, never who asks.
class ReleaseRequest {
  final int id;
  final String room;
  final DateTime startsAt;
  final DateTime endsAt;
  final int quantity;

  const ReleaseRequest({required this.id, required this.room, required this.startsAt, required this.endsAt, this.quantity = 1});

  factory ReleaseRequest.fromJson(Map<String, dynamic> json) => ReleaseRequest(
    id: (json['id'] as num).toInt(),
    room: json['room'] as String? ?? '',
    startsAt: DateTime.parse((json['starts_at'] as String? ?? '').replaceFirst(' ', 'T')),
    endsAt: DateTime.parse((json['ends_at'] as String? ?? '').replaceFirst(' ', 'T')),
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  );
}
