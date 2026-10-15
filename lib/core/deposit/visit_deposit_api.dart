import '../network/api_client.dart';
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

  Future<VisitDeposit?> _answer(VisitKind kind, int id, String action, [Map<String, dynamic>? data]) async {
    final body = await _client.post('/business/${kind.businessPath}/$id/deposit/$action', data: data) as Map<String, dynamic>;

    return VisitDeposit.fromJsonOrNull(body['deposit']);
  }
}
