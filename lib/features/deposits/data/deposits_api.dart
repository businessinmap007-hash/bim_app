import '../../../core/network/api_client.dart';
import 'models/deposit.dart';

class DepositsPage {
  final List<Deposit> items;
  final bool hasMore;
  const DepositsPage({required this.items, required this.hasMore});
}

/// /deposits — see Api\V2\DepositController. Read-only on both endpoints;
/// `index` is a bare Laravel resource collection (no {success,data}
/// envelope, pagination under `meta`), same shape as /fines, and already
/// carries every field `show` would, so this app never calls `show`
/// separately (mirrors FinesApi).
class DepositsApi {
  final ApiClient _client;
  const DepositsApi(this._client);

  Future<DepositsPage> list({String? status, int page = 1}) async {
    final body = await _client.getForBody(
      '/deposits',
      query: {if (status != null) 'status': status, 'page': page},
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => Deposit.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return DepositsPage(items: items, hasMore: currentPage < lastPage);
  }
}
