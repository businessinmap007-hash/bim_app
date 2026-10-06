import '../../../core/network/api_client.dart';

/// One category of notification with its switch: on = active, off = silent (still in the inbox, no push, no sound).
class NotificationCategory {
  final String key;
  final String label;
  final bool enabled;
  const NotificationCategory({required this.key, required this.label, required this.enabled});

  NotificationCategory copyWith({bool? enabled}) => NotificationCategory(key: key, label: label, enabled: enabled ?? this.enabled);

  factory NotificationCategory.fromJson(Map<String, dynamic> json) =>
      NotificationCategory(key: '${json['key']}', label: '${json['label']}', enabled: json['enabled'] as bool? ?? true);
}

/// /me/notification-preferences — see Api\V2\NotificationPreferenceController.
class NotificationPreferencesApi {
  final ApiClient _client;
  const NotificationPreferencesApi(this._client);

  Future<List<NotificationCategory>> load() async {
    final data = await _client.get('/me/notification-preferences') as Map<String, dynamic>;
    return _parse(data);
  }

  /// [changes]: category key → active. A category left out is untouched.
  Future<List<NotificationCategory>> save(Map<String, bool> changes) async {
    final data = await _client.put('/me/notification-preferences', data: {'categories': changes}) as Map<String, dynamic>;
    return _parse(data);
  }

  List<NotificationCategory> _parse(Map<String, dynamic> data) => [
    for (final c in data['categories'] as List<dynamic>? ?? const []) NotificationCategory.fromJson(c as Map<String, dynamic>),
  ];
}
