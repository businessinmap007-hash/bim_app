import '../../../core/network/api_client.dart';

/// The relay for a shared medical file — ciphertext only (see MedicalShareController on the server).
class MedicalShareApi {
  final ApiClient _client;
  const MedicalShareApi(this._client);

  Future<({String id, DateTime expiresAt})> create(String ciphertext, {required int minutes}) async {
    final data = await _client.post('/medical-shares', data: {'ciphertext': ciphertext, 'minutes': minutes}) as Map<String, dynamic>;
    return (id: '${data['id']}', expiresAt: DateTime.parse('${data['expires_at']}').toLocal());
  }

  Future<({String ciphertext, String sharedBy, DateTime createdAt})> fetch(String id) async {
    final data = await _client.get('/medical-shares/$id') as Map<String, dynamic>;
    return (
      ciphertext: '${data['ciphertext']}',
      sharedBy: '${data['shared_by'] ?? ''}',
      createdAt: DateTime.parse('${data['created_at']}').toLocal(),
    );
  }

  Future<void> end(String id) => _client.delete('/medical-shares/$id');
}
