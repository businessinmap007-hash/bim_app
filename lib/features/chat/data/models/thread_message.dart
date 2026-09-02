/// Mirrors `ThreadMessageResource` — one line in an operation chat. A
/// `kind == 'system'` message (thread opened/closed, ...) has no sender and
/// must never render as if someone sent it.
class ThreadMessage {
  final int id;
  final String kind;
  final String? body;
  final bool isMine;
  final String? senderName;
  final DateTime? createdAt;

  const ThreadMessage({
    required this.id,
    required this.kind,
    this.body,
    required this.isMine,
    this.senderName,
    this.createdAt,
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
