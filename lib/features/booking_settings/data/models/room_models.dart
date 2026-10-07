/// One numbered room behind a room type — the hotel's own list (Api\V2\BusinessBookableRoomController).
class RoomRow {
  final int id;
  final String number;
  final String status;
  final bool occupied;

  const RoomRow({required this.id, required this.number, this.status = 'available', this.occupied = false});

  bool get isMaintenance => status == 'maintenance';

  factory RoomRow.fromJson(Map<String, dynamic> json) => RoomRow(
    id: json['id'] as int,
    number: json['number'] as String? ?? '',
    status: json['status'] as String? ?? 'available',
    occupied: json['occupied'] as bool? ?? false,
  );
}

class RoomsPayload {
  final List<RoomRow> rooms;
  final int openCount;
  const RoomsPayload({this.rooms = const [], this.openCount = 0});

  factory RoomsPayload.fromJson(Map<String, dynamic> json) => RoomsPayload(
    rooms: (json['rooms'] as List<dynamic>? ?? []).map((e) => RoomRow.fromJson(e as Map<String, dynamic>)).toList(),
    openCount: (json['open_count'] as num?)?.toInt() ?? 0,
  );
}

/// The rooms a stay could be put in, and the one it has.
class BookingRoomsPayload {
  final bool usesRooms;
  final RoomRow? room;
  final List<RoomRow> free;
  const BookingRoomsPayload({this.usesRooms = false, this.room, this.free = const []});

  factory BookingRoomsPayload.fromJson(Map<String, dynamic> json) => BookingRoomsPayload(
    usesRooms: json['uses_rooms'] as bool? ?? false,
    room: json['room'] is Map<String, dynamic> ? RoomRow.fromJson(json['room'] as Map<String, dynamic>) : null,
    free: (json['free'] as List<dynamic>? ?? []).map((e) => RoomRow.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

/// «101، 102، 110-115» → ['101','102','110',…,'115']. A numeric range is expanded (at most 200 rooms in one go);
/// anything else is kept as typed, so «A1» or «س301» are rooms too.
List<String> parseRoomNumbers(String input) {
  final out = <String>[];
  for (final raw in input.split(RegExp(r'[,،;\s]+'))) {
    final part = raw.trim();
    if (part.isEmpty) continue;
    final range = RegExp(r'^(\d+)\s*[-–]\s*(\d+)$').firstMatch(part);
    if (range != null) {
      final from = int.parse(range.group(1)!);
      final to = int.parse(range.group(2)!);
      if (to >= from && to - from < 200) {
        for (var n = from; n <= to; n++) {
          out.add('$n');
        }
        continue;
      }
    }
    out.add(part);
  }

  return out.toSet().toList();
}
