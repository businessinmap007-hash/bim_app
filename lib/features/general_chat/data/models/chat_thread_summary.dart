/// One row in the conversation list — see DirectChatService::listFor.
class ChatParticipant {
  final int userId;
  final String? name;
  const ChatParticipant({required this.userId, this.name});

  factory ChatParticipant.fromJson(Map<String, dynamic> json) => ChatParticipant(
    userId: (json['user_id'] as num).toInt(),
    name: json['name'] as String?,
  );
}

class ChatLastMessage {
  final String? body;
  final bool isMine;
  final DateTime? createdAt;
  const ChatLastMessage({this.body, required this.isMine, this.createdAt});

  factory ChatLastMessage.fromJson(Map<String, dynamic> json) => ChatLastMessage(
    body: json['body'] as String?,
    isMine: json['is_mine'] as bool? ?? false,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}

class ChatThreadSummary {
  final int id;
  final String type;
  final String? title;
  final List<ChatParticipant> participants;
  final ChatLastMessage? lastMessage;
  final int unreadCount;

  const ChatThreadSummary({
    required this.id,
    required this.type,
    this.title,
    this.participants = const [],
    this.lastMessage,
    this.unreadCount = 0,
  });

  bool get isGroup => type == 'group';

  /// A DM's display name is the other person; a group shows its own title.
  String displayTitle() {
    if (isGroup) return title ?? '';
    return participants.isNotEmpty ? (participants.first.name ?? '') : '';
  }

  factory ChatThreadSummary.fromJson(Map<String, dynamic> json) => ChatThreadSummary(
    id: (json['id'] as num).toInt(),
    type: json['type'] as String? ?? 'direct',
    title: json['title'] as String?,
    participants: (json['participants'] as List<dynamic>? ?? [])
        .map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastMessage: json['last_message'] != null
        ? ChatLastMessage.fromJson(json['last_message'] as Map<String, dynamic>)
        : null,
    unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
  );
}
