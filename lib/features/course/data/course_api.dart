import '../../../core/network/api_client.dart';
import 'models/course.dart';

class CourseApi {
  final ApiClient _client;
  CourseApi(this._client);

  /// The courses of a business with the groups still open to join (public).
  Future<List<CourseInfo>> discover(int businessId) async {
    final data = await _client.get('/discovery/courses/$businessId') as Map<String, dynamic>;

    return (data['courses'] as List<dynamic>? ?? []).map((e) => CourseInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BusinessCourses> mine() async {
    final data = await _client.get('/business/course-groups') as Map<String, dynamic>;

    return BusinessCourses.fromJson(data);
  }

  Map<String, dynamic> _body({
    required int offeringId,
    required String name,
    String? level,
    String? scheduleText,
    required DateTime startsOn,
    DateTime? endsOn,
    required int seats,
    bool? isActive,
  }) => {
    'offering_id': offeringId,
    'name': name,
    'level': level,
    'schedule_text': scheduleText,
    'starts_on': _day(startsOn),
    'ends_on': endsOn == null ? null : _day(endsOn),
    'seats': seats,
    'is_active': ?isActive,
  };

  String _day(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> create({
    required int offeringId,
    required String name,
    String? level,
    String? scheduleText,
    required DateTime startsOn,
    DateTime? endsOn,
    required int seats,
  }) => _client.post(
    '/business/course-groups',
    data: _body(offeringId: offeringId, name: name, level: level, scheduleText: scheduleText, startsOn: startsOn, endsOn: endsOn, seats: seats),
  );

  Future<void> update(
    int id, {
    required int offeringId,
    required String name,
    String? level,
    String? scheduleText,
    required DateTime startsOn,
    DateTime? endsOn,
    required int seats,
    bool? isActive,
  }) => _client.put(
    '/business/course-groups/$id',
    data: _body(offeringId: offeringId, name: name, level: level, scheduleText: scheduleText, startsOn: startsOn, endsOn: endsOn, seats: seats, isActive: isActive),
  );

  Future<void> delete(int id) => _client.delete('/business/course-groups/$id');
}
