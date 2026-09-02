import '../../../core/network/api_client.dart';
import 'models/thread_message.dart';

typedef ChatPage = ({List<ThreadMessage> messages, ChatThread thread});

/// /operation-chats/{type}/{id} — the customer↔business chat on one order or
/// booking. `type` is 'order' | 'booking'. See Api\V2\OperationChatController.
/// File attachments and the party-delete endpoint aren't wired up here —
/// text messages only, for now.
class OperationChatApi {
  final ApiClient _client;
  const OperationChatApi(this._client);

  Future<ChatPage> show(String type, int id, {int perPage = 50}) async {
    final body = await _client.getForBody(
      '/operation-chats/$type/$id',
      query: {'per_page': perPage},
    );
    final messages = (body['data'] as List<dynamic>? ?? [])
        .map((e) => ThreadMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final thread = meta['thread'] != null
        ? ChatThread.fromJson(meta['thread'] as Map<String, dynamic>)
        : const ChatThread(id: 0, status: 'open', locked: false, expired: false);
    return (messages: messages, thread: thread);
  }

  Future<ThreadMessage> postMessage(String type, int id, String body) async {
    final data = await _client.post(
      '/operation-chats/$type/$id/messages',
      data: {'body': body},
    ) as Map<String, dynamic>;
    return ThreadMessage.fromJson(data);
  }
}
