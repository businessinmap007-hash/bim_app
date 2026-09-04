import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../features/general_chat/application/general_chat_providers.dart';
import '../../features/general_chat/presentation/screens/chats_list_screen.dart';

/// Chat bubble + unread badge for a home screen's AppBar, next to
/// [NotificationBellButton] — a message is news the same way a notification
/// is, so it gets the same at-a-glance visibility rather than staying
/// buried inside My Services. Reads [unreadChatCountProvider] (one lightweight
/// `/chats/unread-count` call), re-fetched whenever that provider is
/// invalidated (opening a conversation marks it read).
class ChatIconButton extends ConsumerWidget {
  const ChatIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadChatCountProvider).valueOrNull ?? 0;

    return IconButton(
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
        backgroundColor: AppColors.accentGold,
        child: const Icon(Icons.chat_bubble_outline),
      ),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatsListScreen()),
      ),
    );
  }
}
