import '../../../core/network/api_client.dart';
import 'models/guarantee_level.dart';

typedef GuaranteeMe = ({UserGuarantee? guarantee, bool hasUsableGuarantee});
typedef ActivateResult = ({
  bool changed,
  String reason,
  UserGuarantee? guarantee,
});
typedef UnlockResult = ({double unlockedAmount, UserGuarantee guarantee});
typedef TransactionsPage = ({List<GuaranteeTransaction> items, bool hasMore});

/// /guarantees — the caller's own buyer/seller-protection coverage
/// (Api\V2\GuaranteeController). `target_type` is never sent explicitly:
/// the backend infers client vs business from the account itself, which is
/// exactly right for a customer app that only ever acts as the client side.
/// `check-operation` isn't wired here — it's a booking-time utility another
/// flow would call before creating an operation, not a screen of its own.
class GuaranteeApi {
  final ApiClient _client;
  const GuaranteeApi(this._client);

  Future<List<GuaranteeLevel>> levels() async {
    final data =
        await _client.get('/guarantees/levels') as Map<String, dynamic>;
    return (data['levels'] as List<dynamic>? ?? [])
        .map((e) => GuaranteeLevel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GuaranteeMe> me() async {
    final data = await _client.get('/guarantees/me') as Map<String, dynamic>;
    return (
      guarantee: data['guarantee'] != null
          ? UserGuarantee.fromJson(data['guarantee'] as Map<String, dynamic>)
          : null,
      hasUsableGuarantee: data['has_usable_guarantee'] as bool? ?? false,
    );
  }

  Future<TransactionsPage> transactions({int page = 1}) async {
    final data =
        await _client.get('/guarantees/transactions', query: {'page': page})
            as Map<String, dynamic>;
    final items = (data['transactions'] as List<dynamic>? ?? [])
        .map((e) => GuaranteeTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>? ?? const {};
    final currentPage = (pagination['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
    return (items: items, hasMore: currentPage < lastPage);
  }

  Future<ActivateResult> activate({int? levelId}) async {
    final data =
        await _client.post('/guarantees/activate', data: {'level_id': ?levelId})
            as Map<String, dynamic>;
    return (
      changed: data['changed'] as bool? ?? false,
      reason: data['reason'] as String? ?? '',
      guarantee: data['guarantee'] != null
          ? UserGuarantee.fromJson(data['guarantee'] as Map<String, dynamic>)
          : null,
    );
  }

  Future<UnlockResult> unlock() async {
    final data =
        await _client.post('/guarantees/unlock') as Map<String, dynamic>;
    return (
      unlockedAmount: (data['unlocked_amount'] as num?)?.toDouble() ?? 0,
      guarantee: UserGuarantee.fromJson(
        data['guarantee'] as Map<String, dynamic>,
      ),
    );
  }
}
