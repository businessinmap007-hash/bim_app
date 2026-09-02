import '../../../core/network/api_client.dart';
import 'models/wallet_summary.dart';
import 'models/wallet_transaction.dart';

class WalletTransactionsPage {
  final List<WalletTransaction> items;
  final bool hasMore;
  const WalletTransactionsPage({required this.items, required this.hasMore});
}

/// /wallet — see Api\V2\WalletController. Only the read surface (balance +
/// ledger) is wired up here; deposit/withdraw/transfer/PIN move real money
/// and stay out of this app for now.
class WalletApi {
  final ApiClient _client;
  const WalletApi(this._client);

  Future<WalletSummary> show() async {
    final data = await _client.get('/wallet') as Map<String, dynamic>;
    return WalletSummary.fromJson(data);
  }

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
