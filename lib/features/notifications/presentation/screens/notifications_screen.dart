import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/notifications_providers.dart';
import '../../data/models/app_notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationsControllerProvider);
    final hasUnread = state.items.any((n) => n.isUnread);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsControllerProvider.notifier).markAllRead(),
              child: Text(
                l10n.notificationsMarkAllRead,
                style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(notificationsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            );
          }
          if (state.items.isEmpty) {
            return Center(child: Text(l10n.notificationsEmpty));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsControllerProvider.notifier).load(),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final notification = state.items[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final actor = notification.actor;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.error,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        child: const Icon(Icons.archive_outlined, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(notificationsControllerProvider.notifier).archive(notification),
      child: Container(
        color: notification.isUnread
            ? AppColors.accentGold.withValues(alpha: 0.08)
            : null,
        child: ListTile(
          onTap: () =>
              ref.read(notificationsControllerProvider.notifier).markRead(notification),
          leading: CircleAvatar(
            backgroundImage: actor?.imageUrl != null
                ? NetworkImage(actor!.imageUrl!)
                : null,
            child: actor?.imageUrl == null
                ? Icon(_iconFor(notification.type))
                : null,
          ),
          title: Text(
            notification.title(languageCode),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: notification.isUnread ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            notification.body(languageCode),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _timeAgo(notification.createdAt, languageCode),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    return switch (type) {
      'booking' => Icons.event_available_outlined,
      'wallet' => Icons.account_balance_wallet_outlined,
      'guarantee' => Icons.shield_outlined,
      'dispute' => Icons.gavel_outlined,
      'offer' => Icons.local_offer_outlined,
      'message' => Icons.mail_outline,
      _ => Icons.notifications_outlined,
    };
  }
}

String _timeAgo(DateTime dateTime, String languageCode) {
  final diff = DateTime.now().difference(dateTime);
  final ar = languageCode == 'ar';

  if (diff.inMinutes < 1) return ar ? 'الآن' : 'now';
  if (diff.inMinutes < 60) {
    return ar ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return ar ? 'منذ ${diff.inHours} س' : '${diff.inHours}h ago';
  }
  if (diff.inDays < 30) {
    return ar ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
  }
  final months = (diff.inDays / 30).floor();
  return ar ? 'منذ $months شهر' : '${months}mo ago';
}
