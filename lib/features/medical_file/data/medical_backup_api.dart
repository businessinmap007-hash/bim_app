import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// The server's end of the encrypted backup: one opaque blob per account (see MedicalBackupController).
class MedicalBackupApi {
  final ApiClient _client;
  const MedicalBackupApi(this._client);

  Future<DateTime> put(String blob) async {
    final data = await _client.put('/medical-backup', data: {'blob': blob}) as Map<String, dynamic>;
    return DateTime.parse('${data['updated_at']}').toLocal();
  }

  /// null when the account never made a backup.
  Future<({String blob, DateTime updatedAt})?> get() async {
    try {
      final data = await _client.get('/medical-backup') as Map<String, dynamic>;
      return (blob: '${data['blob']}', updatedAt: DateTime.parse('${data['updated_at']}').toLocal());
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> delete() => _client.delete('/medical-backup');
}
