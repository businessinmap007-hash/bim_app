import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/trip_program.dart';

/// /business/trip-programs (the company writes them) and /businesses/{id}/trip-programs (its customers read them).
class TripProgramsApi {
  final ApiClient _client;
  const TripProgramsApi(this._client);

  String get _base => '/business/trip-programs';

  Future<List<TripProgramBrief>> mine() async {
    final data = await _client.get(_base) as Map<String, dynamic>;
    return [for (final p in (data['programs'] as List<dynamic>? ?? const [])) TripProgramBrief.fromJson(p as Map<String, dynamic>)];
  }

  TripProgram _program(dynamic data) => TripProgram.fromJson((data as Map<String, dynamic>)['program'] as Map<String, dynamic>);

  Future<TripProgram> create(String title, String? summary) async =>
      _program(await _client.post(_base, data: {'title': title, if (summary != null && summary.isNotEmpty) 'summary': summary}));

  Future<TripProgram> show(int id) async => _program(await _client.get('$_base/$id'));

  Future<TripProgram> update(int id, {required String title, String? summary}) async => _program(await _client.put('$_base/$id', data: {'title': title, 'summary': summary}));

  Future<void> delete(int id) => _client.delete('$_base/$id');

  Future<TripProgram> publish(int id, bool publish) async => _program(await _client.post('$_base/$id/${publish ? 'publish' : 'unpublish'}'));

  Future<TripProgram> addDay(int id, String? title) async => _program(await _client.post('$_base/$id/days', data: {'title': title}));

  Future<TripProgram> renameDay(int id, int dayId, String? title) async => _program(await _client.put('$_base/$id/days/$dayId', data: {'title': title}));

  Future<TripProgram> removeDay(int id, int dayId) async => _program(await _client.delete('$_base/$id/days/$dayId'));

  Future<TripProgram> moveDay(int id, int dayId, {required bool up}) async => _program(await _client.post('$_base/$id/days/$dayId/move', data: {'direction': up ? 'up' : 'down'}));

  /// Returns the new item's id with the refreshed programme.
  Future<({int itemId, TripProgram program})> addItem(int id, int dayId, {required String kind, String? body, int? allocationId}) async {
    final data = await _client.post('$_base/$id/days/$dayId/items', data: {'kind': kind, if (body != null && body.isNotEmpty) 'body': body, 'allocation_id': ?allocationId}) as Map<String, dynamic>;
    return (itemId: (data['item_id'] as num).toInt(), program: _program(data));
  }

  Future<TripProgram> updateItem(int id, int itemId, String? body) async => _program(await _client.put('$_base/$id/items/$itemId', data: {'body': body}));

  Future<TripProgram> removeItem(int id, int itemId) async => _program(await _client.delete('$_base/$id/items/$itemId'));

  Future<TripProgram> moveItem(int id, int itemId, {required bool up}) async => _program(await _client.post('$_base/$id/items/$itemId/move', data: {'direction': up ? 'up' : 'down'}));

  Future<TripProgram> setImage(int id, int itemId, File file) async {
    final form = FormData.fromMap({'image': await MultipartFile.fromFile(file.path)});
    return _program(await _client.post('$_base/$id/items/$itemId/image', data: form));
  }

  Future<List<TripRoom>> roomCards() async {
    final data = await _client.get('$_base/room-cards') as Map<String, dynamic>;
    return [for (final r in (data['rooms'] as List<dynamic>? ?? const [])) TripRoom.fromJson(r as Map<String, dynamic>)];
  }

  /// What a business published — its page's «البرامج» tab.
  Future<List<TripProgramBrief>> published(int businessId) async {
    final data = await _client.get('/businesses/$businessId/trip-programs') as Map<String, dynamic>;
    return [for (final p in (data['programs'] as List<dynamic>? ?? const [])) TripProgramBrief.fromJson(p as Map<String, dynamic>)];
  }

  Future<TripProgram> publishedProgram(int businessId, int id) async => _program(await _client.get('/businesses/$businessId/trip-programs/$id'));
}
