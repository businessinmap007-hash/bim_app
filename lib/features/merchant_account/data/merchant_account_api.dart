import '../../../core/network/api_client.dart';
import 'models/merchant_account_status.dart';

/// /merchant-account — see Api\V2\MerchantAccountController.
class MerchantAccountApi {
  final ApiClient _client;
  const MerchantAccountApi(this._client);

  Future<MerchantAccountStatus> status() async {
    final data = await _client.get('/merchant-account') as Map<String, dynamic>;
    return MerchantAccountStatus.fromJson(data);
  }

  Future<void> apply({String? note}) async {
    await _client.post(
      '/merchant-account/request',
      data: {if (note != null && note.isNotEmpty) 'note': note},
    );
  }
}
