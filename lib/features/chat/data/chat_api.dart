import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/thread_message.dart';

typedef ChatPage = ({List<ThreadMessage> messages, ChatThread thread});

/// /operation-chats/{type}/{id} — the customer↔business chat on one order or
/// booking. `type` is 'order' | 'booking'. See Api\V2\OperationChatController.
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

  /// [attachments] are image bytes only — the only picker this app has
  /// (`image_picker`, via MediaPickerService) — though the backend also
  /// accepts PDFs.
  Future<ThreadMessage> postMessage(
    String type,
    int id,
    String body, {
    List<Uint8List> attachments = const [],
  }) async {
    final data = await _client.post(
      '/operation-chats/$type/$id/messages',
      data: FormData.fromMap({
        if (body.isNotEmpty) 'body': body,
        for (var i = 0; i < attachments.length; i++)
          'attachments[$i]': MultipartFile.fromBytes(attachments[i], filename: 'attachment_$i.jpg'),
      }),
    ) as Map<String, dynamic>;
    return ThreadMessage.fromJson(data);
  }

  /// A party deletes the chat — only once it has expired and only when
  /// there's no dispute on the operation (kept as evidence otherwise); the
  /// backend enforces both and returns a plain validation message if not.
  Future<void> delete(String type, int id) => _client.delete('/operation-chats/$type/$id');

  /// Thread attachments live outside the web root — this is the only way to
  /// fetch one, and it requires the same Bearer auth as every other call, so
  /// a plain `Image.network(url)` can't be used directly.
  Future<Uint8List> fetchAttachmentBytes(String url) async {
    final response = await _client.raw.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }
}
