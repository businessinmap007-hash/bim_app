import 'chat_thread_summary.dart';

/// A single thread's own metadata — Api\V2\ChatController::threadMeta.
class DirectChatThread {
  final int id;
  final String type;
  final String? title;
  final bool isOwner;
  final List<ChatParticipant> participants;

  const DirectChatThread({
    required this.id,
    required this.type,
    this.title,
    required this.isOwner,
    this.participants = const [],
  });

  bool get isGroup => type == 'group';

  String displayTitle() {
    if (isGroup) return title ?? '';
    return participants.isNotEmpty ? (participants.first.name ?? '') : '';
  }

  factory DirectChatThread.fromJson(Map<String, dynamic> json) => DirectChatThread(
    id: (json['id'] as num).toInt(),
    type: json['type'] as String? ?? 'direct',
    title: json['title'] as String?,
    isOwner: json['is_owner'] as bool? ?? false,
    participants: (json['participants'] as List<dynamic>? ?? [])
        .map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
