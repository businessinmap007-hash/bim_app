import '../../../core/env/env.dart';
import '../../../core/network/api_client.dart';

/// One reason the report sheet offers (the server names them in the request language).
class ReportReason {
  final String key;
  final String name;
  const ReportReason({required this.key, required this.name});

  factory ReportReason.fromJson(Map<String, dynamic> json) => ReportReason(
    key: json['key'] as String? ?? 'other',
    name: json['name'] as String? ?? '',
  );
}

/// How many people gave one reason.
class ReasonCount {
  final String name;
  final int count;
  const ReasonCount({required this.name, required this.count});

  factory ReasonCount.fromJson(Map<String, dynamic> json) => ReasonCount(
    name: json['name'] as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}

/// One reported item in the moderator's queue (one row per item, not per report).
class ReportedItem {
  /// `post` | `owner_listing`
  final String type;
  final int id;
  final int reports;

  /// `live` | `hidden` | `gone`
  final String state;
  final String title;
  final String excerpt;
  final String? imageUrl;
  final String? authorName;
  final double? price;
  final List<ReasonCount> reasons;
  final List<String> details;

  const ReportedItem({
    required this.type,
    required this.id,
    required this.reports,
    required this.state,
    required this.title,
    required this.excerpt,
    this.imageUrl,
    this.authorName,
    this.price,
    this.reasons = const [],
    this.details = const [],
  });

  bool get isPost => type == 'post';

  factory ReportedItem.fromJson(Map<String, dynamic> json) => ReportedItem(
    type: json['type'] as String? ?? 'post',
    id: (json['id'] as num).toInt(),
    reports: (json['reports'] as num?)?.toInt() ?? 0,
    state: json['state'] as String? ?? 'live',
    title: json['title'] as String? ?? '',
    excerpt: json['excerpt'] as String? ?? '',
    imageUrl: Env.assetUrl(json['image'] as String?),
    authorName: (json['author'] as Map<String, dynamic>?)?['name'] as String?,
    price: (json['price'] as num?)?.toDouble(),
    reasons: [
      for (final r in (json['reasons'] as List<dynamic>? ?? const []))
        ReasonCount.fromJson(r as Map<String, dynamic>),
    ],
    details: [
      for (final d in (json['details'] as List<dynamic>? ?? const [])) '$d',
    ],
  );
}

/// «الإبلاغ» and the moderator's queue. See `ContentReportController` on the backend.
class ModerationApi {
  final ApiClient _client;
  ModerationApi(this._client);

  Future<List<ReportReason>> reasons() async {
    final data = await _client.get('/reports/reasons') as Map<String, dynamic>;
    return [
      for (final r in (data['reasons'] as List<dynamic>? ?? const []))
        ReportReason.fromJson(r as Map<String, dynamic>),
    ];
  }

  Future<void> report({
    required String type,
    required int id,
    required String reason,
    String? details,
  }) => _client.post(
    '/reports',
    data: {
      'type': type,
      'id': id,
      'reason': reason,
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
    },
  );

  Future<List<ReportedItem>> queue({required bool handled}) async {
    final data =
        await _client.get(
              '/moderation/reports',
              query: {'scope': handled ? 'handled' : 'open', 'per_page': 50},
            )
            as Map<String, dynamic>;
    return [
      for (final r in (data['items'] as List<dynamic>? ?? const []))
        ReportedItem.fromJson(r as Map<String, dynamic>),
    ];
  }

  Future<void> dismiss(ReportedItem i) =>
      _client.post('/moderation/reports/${i.type}/${i.id}/dismiss');

  Future<void> remove(ReportedItem i) =>
      _client.post('/moderation/reports/${i.type}/${i.id}/remove');

  Future<void> restore(ReportedItem i) =>
      _client.post('/moderation/reports/${i.type}/${i.id}/restore');
}
