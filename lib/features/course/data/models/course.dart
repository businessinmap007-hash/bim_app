/// One run of a course — when it starts, when it meets, how many seats are left.
class CourseGroup {
  final int id;
  final int offeringId;
  final String name;
  final String? level;
  final String? scheduleText;
  final DateTime? startsOn;
  final DateTime? endsOn;
  final int seats;
  final int seatsTaken;
  final int seatsLeft;
  final bool isActive;

  const CourseGroup({
    required this.id,
    required this.offeringId,
    required this.name,
    this.level,
    this.scheduleText,
    this.startsOn,
    this.endsOn,
    this.seats = 0,
    this.seatsTaken = 0,
    this.seatsLeft = 0,
    this.isActive = true,
  });

  bool get isFull => seatsLeft <= 0;

  factory CourseGroup.fromJson(Map<String, dynamic> json) => CourseGroup(
    id: (json['id'] as num).toInt(),
    offeringId: (json['offering_id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    level: (json['level'] as String?)?.trim().isEmpty ?? true ? null : (json['level'] as String).trim(),
    scheduleText: json['schedule_text'] as String?,
    startsOn: DateTime.tryParse(json['starts_on'] as String? ?? ''),
    endsOn: DateTime.tryParse(json['ends_on'] as String? ?? ''),
    seats: (json['seats'] as num?)?.toInt() ?? 0,
    seatsTaken: (json['seats_taken'] as num?)?.toInt() ?? 0,
    seatsLeft: (json['seats_left'] as num?)?.toInt() ?? 0,
    isActive: json['is_active'] as bool? ?? true,
  );
}

/// A course of a business with the groups it runs in.
class CourseInfo {
  final int id;
  final int? serviceId;
  final String name;
  final double price;
  final String currency;
  final List<CourseGroup> groups;

  const CourseInfo({required this.id, this.serviceId, required this.name, this.price = 0, this.currency = 'EGP', this.groups = const []});

  factory CourseInfo.fromJson(Map<String, dynamic> json) => CourseInfo(
    id: (json['id'] as num).toInt(),
    serviceId: (json['service_id'] as num?)?.toInt(),
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'EGP',
    groups: (json['groups'] as List<dynamic>? ?? []).map((e) => CourseGroup.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

/// What the business sees: its courses and every group it opened.
class BusinessCourses {
  final List<CourseInfo> courses;
  final List<CourseGroup> groups;

  const BusinessCourses({this.courses = const [], this.groups = const []});

  factory BusinessCourses.fromJson(Map<String, dynamic> json) => BusinessCourses(
    courses: (json['courses'] as List<dynamic>? ?? []).map((e) => CourseInfo.fromJson(e as Map<String, dynamic>)).toList(),
    groups: (json['groups'] as List<dynamic>? ?? []).map((e) => CourseGroup.fromJson(e as Map<String, dynamic>)).toList(),
  );
}
