import '../../../../core/env/env.dart';

/// Mirrors AppNotification's `actor:id,name,type,logo,image` eager load in
/// NotificationCenterController — whoever triggered the notification, if
/// anyone (a system notification has none).
class NotificationActor {
  final int id;
  final String name;
  final String? imageUrl;

  const NotificationActor({required this.id, required this.name, this.imageUrl});

  factory NotificationActor.fromJson(Map<String, dynamic> json) => NotificationActor(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    imageUrl: Env.assetUrl((json['logo'] as String?) ?? (json['image'] as String?)),
  );
}

/// One row from `app_notifications`, as returned by NotificationCenterController
/// (index/show) — the model's own columns serialized directly, not through an
/// API Resource, so this mirrors AppNotification.php's `$fillable` shape.
/// `action_url` is a backend/admin path (e.g. `/offers/12`) that doesn't
/// correspond to this app's routes and stays unused; `action_type` is a
/// stable app-facing vocabulary (`open_wallet`, `open_business_order`, ...)
/// dispatch() callers already choose deliberately — see
/// NotificationNavigator, which reads it (with `notifiableId`) to route a
/// tap to the right screen.
class AppNotification {
  final int id;
  final String type;
  final String priority;
  final String status;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String? actionType;
  final String? actionUrl;
  final String? notifiableType;
  final int? notifiableId;
  final Map<String, dynamic> meta;
  final NotificationActor? actor;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.priority,
    required this.status,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    this.actionType,
    this.actionUrl,
    this.notifiableType,
    this.notifiableId,
    this.meta = const {},
    this.actor,
    required this.createdAt,
    this.readAt,
  });

  bool get isUnread => status == 'unread';
  bool get isArchived => status == 'archived';

  String title(String languageCode) {
    final primary = languageCode == 'ar' ? titleAr : titleEn;
    if (primary.isNotEmpty) return primary;
    return titleAr.isNotEmpty ? titleAr : titleEn;
  }

  String body(String languageCode) {
    final primary = languageCode == 'ar' ? bodyAr : bodyEn;
    if (primary.isNotEmpty) return primary;
    return bodyAr.isNotEmpty ? bodyAr : bodyEn;
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as int,
    type: json['type'] as String? ?? 'system',
    priority: json['priority'] as String? ?? 'normal',
    status: json['status'] as String? ?? 'unread',
    titleAr: json['title_ar'] as String? ?? '',
    titleEn: json['title_en'] as String? ?? '',
    bodyAr: json['body_ar'] as String? ?? '',
    bodyEn: json['body_en'] as String? ?? '',
    actionType: json['action_type'] as String?,
    actionUrl: json['action_url'] as String?,
    notifiableType: json['notifiable_type'] as String?,
    notifiableId: (json['notifiable_id'] as num?)?.toInt(),
    meta: (json['meta'] as Map<String, dynamic>?) ?? const {},
    actor: json['actor'] != null
        ? NotificationActor.fromJson(json['actor'] as Map<String, dynamic>)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
  );

  AppNotification copyWith({String? status, DateTime? readAt}) => AppNotification(
    id: id,
    type: type,
    priority: priority,
    status: status ?? this.status,
    titleAr: titleAr,
    titleEn: titleEn,
    bodyAr: bodyAr,
    bodyEn: bodyEn,
    actionType: actionType,
    actionUrl: actionUrl,
    notifiableType: notifiableType,
    notifiableId: notifiableId,
    meta: meta,
    actor: actor,
    createdAt: createdAt,
    readAt: readAt ?? this.readAt,
  );
}
