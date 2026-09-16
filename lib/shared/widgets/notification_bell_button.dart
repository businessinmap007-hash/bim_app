import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../features/notifications/application/notifications_providers.dart';

/// Bell icon + unread badge for a home screen's AppBar. Reads
/// [unreadNotificationCountProvider] rather than the full notifications list
/// so it costs one lightweight `/notifications/unread-count` call, not the
/// whole feed. No periodic poll behind it (a fixed interval x every signed-in
/// device is real server load) — it re-fetches on each tap, right before
/// navigating in, plus whenever the provider is invalidated elsewhere
/// (marking read/archiving, the notifications screen's own refresh button) —
/// see notifications_providers.dart.
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
      onPressed: () {
        ref.invalidate(unreadNotificationCountProvider);
        context.push('/notifications');
      },
    );
  }
}
