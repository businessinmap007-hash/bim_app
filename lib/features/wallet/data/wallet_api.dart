import '../../../core/network/api_client.dart';
import 'models/wallet_summary.dart';
import 'models/wallet_transaction.dart';

class WalletTransactionsPage {
  final List<WalletTransaction> items;
  final bool hasMore;
  const WalletTransactionsPage({required this.items, required this.hasMore});
}

/// /wallet — see Api\V2\WalletController. Deposit/withdraw/transfer move
/// real money and stay out of this app for now; the PIN methods below are
/// the exception — they don't move money themselves, they gate an
/// already-shipped action elsewhere (guarantee activate/unlock) that started
/// requiring one. See WalletPinPrompt.
class WalletApi {
  final ApiClient _client;
  const WalletApi(this._client);

  Future<WalletSummary> show() async {
    final data = await _client.get('/wallet') as Map<String, dynamic>;
    return WalletSummary.fromJson(data);
  }

  Future<({bool isSet, int length})> pinStatus() async {
    final data = await _client.get('/wallet/pin') as Map<String, dynamic>;
    return (isSet: data['is_set'] as bool? ?? false, length: (data['length'] as num?)?.toInt() ?? 6);
  }

  /// Sets the wallet PIN for the first time, or changes it — [currentPin] is
  /// required by the backend only when one is already set.
  Future<void> setPin({required String pin, String? currentPin}) => _client.post(
        '/wallet/pin',
        data: {'pin': pin, 'pin_confirmation': pin, 'current_pin': ?currentPin},
      );

  Future<WalletTransactionsPage> transactions({int page = 1, int perPage = 20}) async {
    final body = await _client.getForBody(
      '/wallet/transactions',
      query: {'page': page, 'per_page': perPage},
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return WalletTransactionsPage(items: items, hasMore: currentPage < lastPage);
  }
}
