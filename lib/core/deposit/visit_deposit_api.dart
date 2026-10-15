import '../network/api_client.dart';
import 'guarantor.dart';
import 'visit_deposit.dart';

/// «عربون الجدية» of a health visit over HTTP — see Api\V2\VisitDepositController. The same four calls serve a clinic
/// appointment, a lab/radiology order and a hospital procedure.
class VisitDepositApi {
  final ApiClient _client;
  const VisitDepositApi(this._client);

  /// The business got the deposit owed outside the platform — [method] is `cash` or `transfer`.
  Future<VisitDeposit?> confirmReceived(VisitKind kind, int id, String method) =>
      _answer(kind, id, 'confirm-received', {'method': method});

  /// The business accepts the visit without the deposit owed outside.
  Future<VisitDeposit?> waive(VisitKind kind, int id) => _answer(kind, id, 'waive');

  /// The business returns a held wallet deposit (after a no-show, for instance).
  Future<VisitDeposit?> giveBack(VisitKind kind, int id) => _answer(kind, id, 'give-back');

  /// Either party opens a dispute over the held deposit.
  Future<void> openDispute(VisitKind kind, int id, {required String reasonCode, String? reasonText}) async {
    await _client.post(
      '/visit-deposits/${kind.slug}/$id/disputes',
      data: {'reason_code': reasonCode, if (reasonText != null && reasonText.isNotEmpty) 'reason_text': reasonText},
    );
  }

  // ── a friend stands for the deposit ──────────────────────────────────────────────────────────────────────────

  /// The friends invited for this operation, and what is still missing.
  Future<GuarantorList> guarantors(VisitKind kind, int id) async {
    final data = await _client.get('/visit-deposits/${kind.slug}/$id/guarantors') as Map<String, dynamic>;

    return GuarantorList(
      items: [for (final g in (data['guarantors'] as List<dynamic>? ?? const [])) Guarantor.fromJson(g as Map<String, dynamic>)],
      need: GuarantorNeed.fromJsonOrNull(data['need']),
    );
  }

  /// Invites a friend by phone or email (or account id).
  Future<Guarantor> inviteGuarantor(VisitKind kind, int id, {String? phone, String? email, int? userId}) async {
    final data = await _client.post(
      '/visit-deposits/${kind.slug}/$id/guarantors',
      data: {'phone': ?phone, 'email': ?email, 'guarantor_user_id': ?userId},
    ) as Map<String, dynamic>;

    return Guarantor.fromJson(data['guarantor'] as Map<String, dynamic>);
  }

  /// One request, read by the invited friend.
  Future<Guarantor> guarantor(int id) async {
    final data = await _client.get('/guarantors/$id') as Map<String, dynamic>;

    return Guarantor.fromJson(data['guarantor'] as Map<String, dynamic>);
  }

  Future<Guarantor> acceptGuarantor(int id, double amount) async {
    final data = await _client.post('/guarantors/$id/accept', data: {'amount': amount}) as Map<String, dynamic>;

    return Guarantor.fromJson(data['guarantor'] as Map<String, dynamic>);
  }

  Future<Guarantor> declineGuarantor(int id) async {
    final data = await _client.post('/guarantors/$id/decline') as Map<String, dynamic>;

    return Guarantor.fromJson(data['guarantor'] as Map<String, dynamic>);
  }

  Future<VisitDeposit?> _answer(VisitKind kind, int id, String action, [Map<String, dynamic>? data]) async {
    final body = await _client.post('/business/${kind.businessPath}/$id/deposit/$action', data: data) as Map<String, dynamic>;

    return VisitDeposit.fromJsonOrNull(body['deposit']);
  }
}
