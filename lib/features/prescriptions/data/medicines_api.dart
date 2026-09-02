import '../../../core/network/api_client.dart';
import 'models/medicine.dart';

/// /medicines — the shared drug dictionary a doctor searches while writing a
/// prescription, and adds to when a drug isn't there yet. See
/// Api\V2\MedicineController.
class MedicinesApi {
  final ApiClient _client;
  const MedicinesApi(this._client);

  Future<List<Medicine>> search(String q, {int limit = 20}) async {
    final data = await _client.get('/medicines', query: {'q': q, 'limit': limit}) as List<dynamic>;
    return data.map((e) => Medicine.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Medicine> add({required String name, String? strength}) async {
    final data = await _client.post(
      '/medicines',
      data: {'name': name, if (strength != null && strength.isNotEmpty) 'strength': strength},
    ) as Map<String, dynamic>;
    return Medicine.fromJson(data);
  }
}
