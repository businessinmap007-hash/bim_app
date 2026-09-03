import '../../../core/network/api_client.dart';

/// A chat participant's own decision on whether admins may ever read the
/// thread — see Api\V2\ThreadAccessController. Shared by operation chat and
/// general chat/DMs, both of which are the same `Thread` concept server-side.
class ThreadAccessStatus {
  final String? myDecision;
  final bool pending;

  const ThreadAccessStatus({required this.myDecision, required this.pending});

  bool get isApproved => myDecision == 'approved';
  bool get isDeclined => myDecision == 'declined';
  bool get needsResponse => myDecision == null;

  factory ThreadAccessStatus.fromJson(Map<String, dynamic> json) => ThreadAccessStatus(
    myDecision: json['my_decision'] as String?,
    pending: json['pending'] as bool? ?? false,
  );
}

class ThreadAccessApi {
  final ApiClient _client;
  const ThreadAccessApi(this._client);

  Future<ThreadAccessStatus> status(int threadId) async {
    final data = await _client.get('/threads/$threadId/access-status') as Map<String, dynamic>;
    return ThreadAccessStatus.fromJson(data);
  }

  Future<void> respond(int threadId, {required bool approve}) async {
    await _client.post(
      '/threads/$threadId/access-consent',
      data: {'decision': approve ? 'approved' : 'declined'},
    );
  }
}
