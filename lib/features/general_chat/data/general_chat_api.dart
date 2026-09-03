import '../../../core/network/api_client.dart';
import '../../chat/data/models/thread_message.dart';
import 'models/chat_thread_summary.dart';
import 'models/direct_chat_thread.dart';

typedef ChatThreadPage = ({List<ThreadMessage> messages, DirectChatThread thread});

/// /chats — general person-to-person chat (DMs and small groups), reusing
/// the same thread machinery as operation chat and training chat. See
/// Api\V2\ChatController / DirectChatService.
class GeneralChatApi {
  final ApiClient _client;
  const GeneralChatApi(this._client);

  Future<List<ChatThreadSummary>> list() async {
    final data = await _client.get('/chats') as List<dynamic>;
    return data.map((e) => ChatThreadSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DirectChatThread> startWith(int userId) async {
    final data = await _client.post('/chats', data: {'user_id': userId}) as Map<String, dynamic>;
    return DirectChatThread.fromJson(data);
  }

  Future<DirectChatThread> createGroup(String title, List<int> userIds) async {
    final data = await _client.post(
      '/chats/group',
      data: {'title': title, 'user_ids': userIds},
    ) as Map<String, dynamic>;
    return DirectChatThread.fromJson(data);
  }

  Future<ChatThreadPage> show(int threadId, {int perPage = 30}) async {
    final body = await _client.getForBody('/chats/$threadId', query: {'per_page': perPage});
    final messages = (body['data'] as List<dynamic>? ?? [])
        .map((e) => ThreadMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final thread = meta['thread'] != null
        ? DirectChatThread.fromJson(meta['thread'] as Map<String, dynamic>)
        : const DirectChatThread(id: 0, type: 'direct', isOwner: false);
    return (messages: messages, thread: thread);
  }

  Future<ThreadMessage> postMessage(int threadId, String body) async {
    final data = await _client.post(
      '/chats/$threadId/messages',
      data: {'body': body},
    ) as Map<String, dynamic>;
    return ThreadMessage.fromJson(data);
  }

  Future<DirectChatThread> addMember(int threadId, int userId) async {
    final data = await _client.post(
      '/chats/$threadId/members',
      data: {'user_id': userId},
    ) as Map<String, dynamic>;
    return DirectChatThread.fromJson(data);
  }

  Future<DirectChatThread> removeMember(int threadId, int userId) async {
    final data = await _client.delete('/chats/$threadId/members/$userId') as Map<String, dynamic>;
    return DirectChatThread.fromJson(data);
  }

  Future<DirectChatThread> rename(int threadId, String title) async {
    final data = await _client.patch('/chats/$threadId', data: {'title': title}) as Map<String, dynamic>;
    return DirectChatThread.fromJson(data);
  }

  Future<void> leave(int threadId) => _client.post('/chats/$threadId/leave');

  Future<void> delete(int threadId) => _client.delete('/chats/$threadId');
}
