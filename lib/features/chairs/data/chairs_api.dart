import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/service_chair.dart';

class ChairsApi {
  final ApiClient _client;
  ChairsApi(this._client);

  /// The active chairs of a business with the person at each (public) — empty = one line.
  Future<List<ServiceChair>> discover(int businessId) async {
    final data = await _client.get('/discovery/appointments/$businessId/chairs') as Map<String, dynamic>;

    return (data['chairs'] as List<dynamic>? ?? [])
        .map((e) => ServiceChair.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceChair>> mine() async {
    final data = await _client.get('/business/chairs') as Map<String, dynamic>;

    return (data['chairs'] as List<dynamic>? ?? [])
        .map((e) => ServiceChair.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The staff of the business that may sit at a chair (accepted, active).
  Future<List<ChairStaffMember>> staff() async {
    final data = await _client.get('/business/chairs/staff') as Map<String, dynamic>;

    return (data['staff'] as List<dynamic>? ?? [])
        .map((e) => ChairStaffMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({String? name, String? personName, String? photoPath, int? staffUserId}) async {
    await _client.post(
      '/business/chairs',
      data: FormData.fromMap({
        if (name != null && name.isNotEmpty) 'name': name,
        if (personName != null && personName.isNotEmpty) 'person_name': personName,
        'staff_user_id': ?staffUserId,
        if (photoPath != null) 'photo': await MultipartFile.fromFile(photoPath),
      }),
    );
  }

  /// A file cannot ride a PUT, so the change is a multipart POST: the fields sent are the fields changed.
  Future<void> update(
    int id, {
    String? name,
    String? personName,
    String? photoPath,
    bool? isActive,
    bool removePhoto = false,
    int? staffUserId,
  }) async {
    await _client.post(
      '/business/chairs/$id',
      data: FormData.fromMap({
        'name': name ?? '',
        'person_name': personName ?? '',
        // empty clears the link to a staff account
        'staff_user_id': staffUserId?.toString() ?? '',
        if (photoPath != null) 'photo': await MultipartFile.fromFile(photoPath),
        if (isActive != null) 'is_active': isActive ? 1 : 0,
        if (removePhoto) 'remove_photo': 1,
      }),
    );
  }

  Future<void> delete(int id) => _client.delete('/business/chairs/$id');

  // ───────────── the queue the business runs ─────────────

  /// `businessId` is the employer when a staff member works the queue; `mine` is «كرسيي» — only the chairs they sit at.
  Future<BusinessQueue> queue({int? businessId, bool mine = false}) async {
    final data =
        await _client.get('/business/queue', query: {'business_id': ?businessId, if (mine) 'mine': 1})
            as Map<String, dynamic>;

    return BusinessQueue.fromJson(data);
  }

  /// A staff member names the business they act for in the query, as every business endpoint expects.
  String _acting(String path, int? businessId) => businessId == null ? path : '$path?business_id=$businessId';

  Future<void> call(int bookingId, {int? businessId}) =>
      _client.post(_acting('/business/queue/$bookingId/call', businessId));

  Future<void> start(int bookingId, {int? businessId}) =>
      _client.post(_acting('/business/queue/$bookingId/start', businessId));

  Future<void> finish(int bookingId, {int? businessId}) =>
      _client.post(_acting('/business/queue/$bookingId/finish', businessId));

  /// A customer with no booking: the staff add a turn for him. Returns the turn number he was given.
  Future<int> walkIn({
    required String name,
    String? phone,
    required int offeringId,
    int? chairId,
    int? businessId,
  }) async {
    final data =
        await _client.post(
              _acting('/business/queue/walk-in', businessId),
              data: {
                'name': name,
                if (phone != null && phone.isNotEmpty) 'phone': phone,
                'offering_id': offeringId,
                'chair_id': ?chairId,
              },
            )
            as Map<String, dynamic>;

    return (data['turn'] as num?)?.toInt() ?? 0;
  }
}
