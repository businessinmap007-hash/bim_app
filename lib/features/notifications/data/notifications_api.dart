import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/app_notification.dart';

/// Talks to /notifications — see Api\V2\NotificationCenterController.
class NotificationsApi {
  final ApiClient _client;

  const NotificationsApi(this._client);

  Future<({Paginated<AppNotification> page, int unreadCount})> list({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final data =
        await _client.get(
              '/notifications',
              query: {
                if (status != null) 'status': status,
                'page': page,
                'per_page': perPage,
              },
            )
            as Map<String, dynamic>;
    return (
      page: Paginated.fromJson(
        data['notifications'] as Map<String, dynamic>,
        AppNotification.fromJson,
      ),
      unreadCount: (data['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<int> unreadCount() async {
    final data = await _client.get('/notifications/unread-count') as Map<String, dynamic>;
    return (data['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int id) => _client.post('/notifications/$id/read');

  Future<void> markAllRead() => _client.post('/notifications/mark-all-read');

  Future<void> archive(int id) => _client.post('/notifications/$id/archive');
}
