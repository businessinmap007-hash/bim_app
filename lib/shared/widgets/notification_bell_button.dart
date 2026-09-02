import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../features/notifications/application/notifications_providers.dart';

/// Bell icon + unread badge for a home screen's AppBar. Reads
/// [unreadNotificationCountProvider] rather than the full notifications list
/// so it costs one lightweight `/notifications/unread-count` call, not the
/// whole feed. Re-fetched whenever that provider is invalidated (opening the
/// notifications screen, marking read/archiving) — see notifications_providers.dart.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return IconButton(
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
        backgroundColor: AppColors.accentGold,
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () => context.push('/notifications'),
    );
  }
}
