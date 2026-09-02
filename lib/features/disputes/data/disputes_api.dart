import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../chat/data/models/thread_message.dart';
import 'models/conduct_charter.dart';
import 'models/dispute.dart';
import 'models/dispute_settlement.dart';

typedef DisputeRoomPage = ({
  List<ThreadMessage> messages,
  int threadId,
  bool locked,
  bool conductAccepted,
  int conductVersion,
  bool purged,
});

typedef SettlementPaymentsPage = ({
  DisputeSettlementProposal? current,
  List<DisputeSettlementProposal> history,
});

typedef ObligationsSummary = ({
  bool blocked,
  double outstanding,
  List<DisputeObligation> owedByMe,
  List<DisputeObligation> owedToMe,
});

/// The customer's side of Api\V2\DisputeController + DisputeObligationController.
/// Ruling (who's right, and moving the escrow) is deliberately not here — that
/// stays admin/arbitrator-only on the backend; nothing an app account can call
/// decides a case. Everything wired here either negotiates (cooperate,
/// settlement, arbitration request, room) or reads/pays what a party already
/// owes from their own wallet balance.
class DisputesApi {
  final ApiClient _client;
  const DisputesApi(this._client);

  Future<List<String>> reasonCodes() async {
    final data = await _client.get('/disputes/reason-codes') as List<dynamic>;
    return data.map((e) => e.toString()).toList();
  }

  Future<Paginated<Dispute>> myDisputes({String? status, String? role, int page = 1}) async {
    final body = await _client.getForBody(
      '/disputes',
      query: {if (status != null) 'status': status, if (role != null) 'role': role, 'page': page},
    );
    return Paginated.fromJson(body, Dispute.fromJson);
  }

  Future<DisputeDetail> show(int id) async {
    final body = await _client.getForBody('/disputes/$id');
    return DisputeDetail.fromJson(body);
  }

  Future<Dispute> openForBooking(int bookingId, {required String reasonCode, String? reasonText}) async {
    final data = await _client.post(
      '/bookings/$bookingId/disputes',
      data: {'reason_code': reasonCode, if (reasonText != null && reasonText.isNotEmpty) 'reason_text': reasonText},
    ) as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<Dispute> openForOrder(int orderId, {required String reasonCode, String? reasonText}) async {
    final data = await _client.post(
      '/orders/$orderId/disputes',
      data: {'reason_code': reasonCode, if (reasonText != null && reasonText.isNotEmpty) 'reason_text': reasonText},
    ) as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<Dispute> openForTrip(int reservationId, {required String reasonCode, String? reasonText}) async {
    final data = await _client.post(
      '/schedules/reservations/$reservationId/disputes',
      data: {'reason_code': reasonCode, if (reasonText != null && reasonText.isNotEmpty) 'reason_text': reasonText},
    ) as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<Dispute> cooperate(int id) async {
    final data = await _client.post('/disputes/$id/cooperate') as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<Dispute> requestArbitration(int id) async {
    final data = await _client.post('/disputes/$id/request-arbitration') as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<Dispute> agreeSettlement(int id) async {
    final data = await _client.post('/disputes/$id/settlement') as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<Dispute> withdrawSettlement(int id) async {
    final data = await _client.delete('/disputes/$id/settlement') as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<Dispute> confirmClosurePurge(int id) async {
    final data = await _client.post('/disputes/$id/closure-confirmation') as Map<String, dynamic>;
    return Dispute.fromJson(data);
  }

  Future<SettlementPaymentsPage> settlementPayments(int id) async {
    final data = await _client.get('/disputes/$id/settlement-payments') as Map<String, dynamic>;
    return (
      current: data['current'] != null
          ? DisputeSettlementProposal.fromJson(data['current'] as Map<String, dynamic>)
          : null,
      history: (data['history'] as List<dynamic>? ?? [])
          .map((e) => DisputeSettlementProposal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<DisputeSettlementProposal> proposeSettlementPayment(
    int id, {
    required String payerSide,
    required double amount,
    String? method,
    String? note,
  }) async {
    final data = await _client.post(
      '/disputes/$id/settlement-payments',
      data: {
        'payer_side': payerSide,
        'amount': amount,
        if (method != null && method.isNotEmpty) 'method': method,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    ) as Map<String, dynamic>;
    return DisputeSettlementProposal.fromJson(data);
  }

  Future<DisputeSettlementProposal> acceptSettlementPayment(int id, int settlementId) async {
    final data =
        await _client.post('/disputes/$id/settlement-payments/$settlementId/accept') as Map<String, dynamic>;
    return DisputeSettlementProposal.fromJson(data);
  }

  Future<DisputeSettlementProposal> rejectSettlementPayment(int id, int settlementId) async {
    final data =
        await _client.post('/disputes/$id/settlement-payments/$settlementId/reject') as Map<String, dynamic>;
    return DisputeSettlementProposal.fromJson(data);
  }

  Future<DisputeSettlementProposal> confirmSettlementReceived(int id, int settlementId) async {
    final data =
        await _client.post('/disputes/$id/settlement-payments/$settlementId/received') as Map<String, dynamic>;
    return DisputeSettlementProposal.fromJson(data);
  }

  Future<void> withdrawSettlementPayment(int id, int settlementId) async {
    await _client.delete('/disputes/$id/settlement-payments/$settlementId');
  }

  Future<DisputeRoomPage> room(int id, {int perPage = 30}) async {
    final body = await _client.getForBody('/disputes/$id/room', query: {'per_page': perPage});
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final thread = meta['thread'] as Map<String, dynamic>? ?? const {};
    final messages = (body['data'] as List<dynamic>? ?? [])
        .map((e) => ThreadMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    return (
      messages: messages,
      threadId: (thread['id'] as num?)?.toInt() ?? 0,
      locked: thread['locked'] as bool? ?? false,
      conductAccepted: thread['conduct_accepted'] as bool? ?? false,
      conductVersion: (thread['conduct_version'] as num?)?.toInt() ?? 1,
      purged: thread['purged'] as bool? ?? false,
    );
  }

  Future<ConductCharter> conduct(int id) async {
    final data = await _client.get('/disputes/$id/room/conduct') as Map<String, dynamic>;
    return ConductCharter.fromJson(data);
  }

  Future<void> acceptConduct(int id) async {
    await _client.post('/disputes/$id/room/conduct');
  }

  Future<void> declineConduct(int id) async {
    await _client.delete('/disputes/$id/room/conduct');
  }

  Future<ThreadMessage> postMessage(int id, String body, {String? imagePath}) async {
    final data = await _client.post(
      '/disputes/$id/room/messages',
      data: FormData.fromMap({
        'body': body,
        if (imagePath != null) 'attachments[]': await MultipartFile.fromFile(imagePath),
      }),
    ) as Map<String, dynamic>;
    return ThreadMessage.fromJson(data);
  }

  Future<ObligationsSummary> obligationsSummary() async {
    final data = await _client.get('/me/dispute-obligations') as Map<String, dynamic>;
    return (
      blocked: data['blocked'] as bool? ?? false,
      outstanding: (data['outstanding'] as num?)?.toDouble() ?? 0,
      owedByMe: (data['owed_by_me'] as List<dynamic>? ?? [])
          .map((e) => DisputeObligation.fromJson(e as Map<String, dynamic>))
          .toList(),
      owedToMe: (data['owed_to_me'] as List<dynamic>? ?? [])
          .map((e) => DisputeObligation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns {settled, still_pending, outstanding, blocked}.
  Future<Map<String, dynamic>> settleObligations() async {
    final data = await _client.post('/me/dispute-obligations/settle') as Map<String, dynamic>;
    return data;
  }
}
