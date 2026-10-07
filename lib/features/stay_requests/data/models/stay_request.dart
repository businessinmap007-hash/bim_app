/// A guest's request during a running hotel stay — a problem with the room (`issue`) or something to bring
/// (`service`). Api\V2\StayRequestController / BusinessStayRequestController.
class StayRequest {
  static const kindIssue = 'issue';
  static const kindService = 'service';

  final int id;
  final int bookingId;
  final String kind;
  final String? category;
  final String title;

  /// [title] in the reader's language (the server translates the platform's own wording).
  final String label;
  final String? note;
  final String status;
  final DateTime? createdAt;

  // the hotel's view only
  final String? roomNumber;
  final String? unitTitle;
  final String? guestName;

  const StayRequest({
    required this.id,
    required this.bookingId,
    required this.kind,
    this.category,
    required this.title,
    required this.label,
    this.note,
    required this.status,
    this.createdAt,
    this.roomNumber,
    this.unitTitle,
    this.guestName,
  });

  bool get isIssue => kind == kindIssue;
  bool get isOpen => status == 'new' || status == 'in_progress';
  bool get isNew => status == 'new';

  factory StayRequest.fromJson(Map<String, dynamic> json) => StayRequest(
    id: json['id'] as int,
    bookingId: json['booking_id'] as int? ?? 0,
    kind: json['kind'] as String? ?? kindService,
    category: json['category'] as String?,
    title: json['title'] as String? ?? '',
    label: json['label'] as String? ?? json['title'] as String? ?? '',
    note: json['note'] as String?,
    status: json['status'] as String? ?? 'new',
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    roomNumber: json['room_number'] as String?,
    unitTitle: json['unit_title'] as String?,
    guestName: json['guest_name'] as String?,
  );
}

/// One choice on a guest's two buttons: an issue category (`value` = its key) or a service (`value` = its title).
class StayChoice {
  final String value;
  final String label;
  const StayChoice({required this.value, required this.label});
}

/// What a guest's two buttons offer, and this stay's own requests.
class StayRequestOptions {
  final bool canRequest;
  final List<StayChoice> issues;
  final List<StayChoice> services;
  final List<StayRequest> requests;

  const StayRequestOptions({this.canRequest = false, this.issues = const [], this.services = const [], this.requests = const []});

  factory StayRequestOptions.fromJson(Map<String, dynamic> json) => StayRequestOptions(
    canRequest: json['can_request'] as bool? ?? false,
    issues: (json['issues'] as List<dynamic>? ?? [])
        .map((e) => StayChoice(value: (e as Map<String, dynamic>)['key'] as String, label: e['label'] as String? ?? ''))
        .toList(),
    services: (json['services'] as List<dynamic>? ?? [])
        .map((e) => StayChoice(value: (e as Map<String, dynamic>)['title'] as String, label: e['label'] as String? ?? e['title'] as String))
        .toList(),
    requests: (json['requests'] as List<dynamic>? ?? []).map((e) => StayRequest.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

/// The hotel's list of requests: the open ones are what waits on the front desk.
class StayRequestsPayload {
  final List<StayRequest> requests;
  final int openCount;
  const StayRequestsPayload({this.requests = const [], this.openCount = 0});

  factory StayRequestsPayload.fromJson(Map<String, dynamic> json) => StayRequestsPayload(
    requests: (json['requests'] as List<dynamic>? ?? []).map((e) => StayRequest.fromJson(e as Map<String, dynamic>)).toList(),
    openCount: (json['open_count'] as num?)?.toInt() ?? 0,
  );
}

class StayServiceRow {
  /// null while the hotel is still on the platform's starting list (nothing to edit yet).
  final int? id;
  final String title;
  final bool isActive;
  const StayServiceRow({this.id, required this.title, this.isActive = true});

  factory StayServiceRow.fromJson(Map<String, dynamic> json) => StayServiceRow(
    id: json['id'] as int?,
    title: json['title'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? true,
  );
}

class StayServicesPayload {
  /// whether the hotel has written its own list (false = the platform's starting list)
  final bool custom;
  final List<StayServiceRow> services;
  const StayServicesPayload({this.custom = false, this.services = const []});

  factory StayServicesPayload.fromJson(Map<String, dynamic> json) => StayServicesPayload(
    custom: json['custom'] as bool? ?? false,
    services: (json['services'] as List<dynamic>? ?? []).map((e) => StayServiceRow.fromJson(e as Map<String, dynamic>)).toList(),
  );
}
