import '../../../core/network/api_client.dart';
import 'models/fine.dart';

class FinesPage {
  final List<Fine> items;
  final bool hasMore;
  const FinesPage({required this.items, required this.hasMore});
}

/// /fines — see Api\V2\FineController. `index` is a bare Laravel resource
/// collection (no {success,data} envelope, pagination under `meta`); the
/// list already carries everything `show` would (same FineResource shape),
/// so this app never calls `show` separately. `appeal` carries
/// {success,message,data}.
class FinesApi {
  final ApiClient _client;
  const FinesApi(this._client);

  Future<FinesPage> list({int page = 1}) async {
    final body = await _client.getForBody('/fines', query: {'page': page});
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => Fine.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return FinesPage(items: items, hasMore: currentPage < lastPage);
  }

  Future<Fine> appeal(int id, String statement) async {
    final data = await _client.post(
      '/fines/$id/appeal',
      data: {'statement': statement},
    ) as Map<String, dynamic>;
    return Fine.fromJson(data);
  }
}
