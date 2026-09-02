/// A file attached to a message (see ThreadAttachmentResource). `url` is
/// already an absolute API URL — never pass it through `Env.assetUrl`.
class ThreadAttachment {
  final int id;
  final String url;
  final String? name;
  final String? mime;
  final int? size;

  const ThreadAttachment({required this.id, required this.url, this.name, this.mime, this.size});

  bool get isImage => mime?.startsWith('image/') ?? false;

  factory ThreadAttachment.fromJson(Map<String, dynamic> json) => ThreadAttachment(
    id: json['id'] as int,
    url: json['url'] as String? ?? '',
    name: json['name'] as String?,
    mime: json['mime'] as String?,
    size: (json['size'] as num?)?.toInt(),
  );
}

/// Mirrors `ThreadMessageResource` — one line in an operation chat. A
/// `kind == 'system'` message (thread opened/closed, ...) has no sender and
/// must never render as if someone sent it. `attachments` is empty for the
/// text-only threads (operation/training chat); the dispute room is the one
/// caller that populates it.
class ThreadMessage {
  final int id;
  final String kind;
  final String? body;
  final bool isMine;
  final String? senderName;
  final DateTime? createdAt;
  final List<ThreadAttachment> attachments;

  const ThreadMessage({
    required this.id,
    required this.kind,
    this.body,
    required this.isMine,
    this.senderName,
    this.createdAt,
    this.attachments = const [],
  });

  bool get isSystem => kind == 'system';

  factory ThreadMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return ThreadMessage(
      id: json['id'] as int,
      kind: json['kind'] as String? ?? 'message',
      body: json['body'] as String?,
      isMine: json['is_mine'] as bool? ?? false,
      senderName: sender?['name'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => ThreadAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// The `meta.thread` object alongside the message list — whether the caller
/// can still post to it.
class ChatThread {
  final int id;
  final String status;
  final bool locked;
  final bool expired;

  const ChatThread({
    required this.id,
    required this.status,
    required this.locked,
    required this.expired,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
    id: json['id'] as int,
    status: json['status'] as String? ?? 'open',
    locked: json['locked'] as bool? ?? false,
    expired: json['expired'] as bool? ?? false,
  );
}
