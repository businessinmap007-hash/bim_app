import '../../../core/env/env.dart';
import '../../../core/network/api_client.dart';
import '../../../core/time/egypt_time.dart';

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

  /// The moderator dealing with it (recorded when he opened it), and whether that is me / somebody else.
  final String? handlerName;
  final bool claimedByMe;
  final bool locked;

  /// Handled list only: who closed it.
  final String? handledBy;

  /// An ACCOUNT row: the moderators' case on it (its chat is `operation-chats/moderation/{caseId}`) and until when it is frozen.
  final int? caseId;
  final DateTime? frozenUntil;

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
    this.handlerName,
    this.claimedByMe = false,
    this.locked = false,
    this.handledBy,
    this.caseId,
    this.frozenUntil,
  });

  bool get isPost => type == 'post';
  bool get isAccount => type == 'account';

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
    handlerName: (json['handler'] as Map<String, dynamic>?)?['name'] as String?,
    claimedByMe: json['claimed_by_me'] as bool? ?? false,
    locked: json['locked'] as bool? ?? false,
    handledBy: json['handled_by'] as String?,
    caseId: ((json['case'] as Map<String, dynamic>?)?['id'] as num?)?.toInt(),
    frozenUntil: EgyptTime.tryParse(json['frozen_until'] as String?),
  );
}

/// The moderators' case on a reported ACCOUNT, as that account sees it: the chat to answer in, and whether it is frozen.
class MyAccountCase {
  final int id;
  final DateTime? frozenUntil;
  const MyAccountCase({required this.id, this.frozenUntil});

  factory MyAccountCase.fromJson(Map<String, dynamic> json) => MyAccountCase(
    id: (json['id'] as num).toInt(),
    frozenUntil: EgyptTime.tryParse(json['frozen_until'] as String?),
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

  /// One page of the moderator's queue (50 rows) and whether more follow.
  Future<({List<ReportedItem> items, bool hasMore})> queue({
    required bool handled,
    int page = 1,
  }) async {
    final body = await _client.getForBody(
      '/moderation/reports',
      query: {
        'scope': handled ? 'handled' : 'open',
        'per_page': 50,
        'page': page,
      },
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};

    return (
      items: [
        for (final r in (data['items'] as List<dynamic>? ?? const []))
          ReportedItem.fromJson(r as Map<String, dynamic>),
      ],
      hasMore:
          ((meta['current_page'] as num?) ?? 1) <
          ((meta['last_page'] as num?) ?? 1),
    );
  }

  /// The account's own open case (null when there is none).
  Future<MyAccountCase?> myCase() async {
    final data =
        await _client.get('/moderation/my-case') as Map<String, dynamic>;
    final c = data['case'] as Map<String, dynamic>?;

    return c == null ? null : MyAccountCase.fromJson(c);
  }

  /// Open the chat with a reported account; returns the case id (the chat is `operation-chats/moderation/{id}`).
  Future<int> accountChat(ReportedItem i) async {
    final data =
        await _client.post('/moderation/reports/account/${i.id}/chat')
            as Map<String, dynamic>;
    return (data['case_id'] as num).toInt();
  }

  Future<void> freezeAccount(ReportedItem i) =>
      _client.post('/moderation/reports/account/${i.id}/freeze');

  Future<void> unfreezeAccount(ReportedItem i) =>
      _client.post('/moderation/reports/account/${i.id}/unfreeze');

  Future<void> claim(ReportedItem i) =>
      _client.post('/moderation/reports/${i.type}/${i.id}/claim');

  Future<void> release(ReportedItem i) =>
      _client.post('/moderation/reports/${i.type}/${i.id}/release');

  Future<void> dismiss(ReportedItem i) =>
      _client.post('/moderation/reports/${i.type}/${i.id}/dismiss');

  /// The rules a listing is removed for: `(key, name)` pairs.
  Future<List<({String key, String name})>> violations() async {
    final data =
        await _client.get('/moderation/violations') as Map<String, dynamic>;
    return [
      for (final v in (data['violations'] as List<dynamic>? ?? const []))
        (
          key: (v as Map<String, dynamic>)['key'] as String? ?? '',
          name: v['name'] as String? ?? '',
        ),
    ];
  }

  /// Remove the item. For a listing: the rule it broke, and whether the stake behind it is confiscated (the default).
  Future<void> remove(
    ReportedItem i, {
    String? violation,
    bool confiscate = true,
  }) => _client.post(
    '/moderation/reports/${i.type}/${i.id}/remove',
    data: {'violation': ?violation, 'confiscate': confiscate},
  );

  Future<void> restore(ReportedItem i) =>
      _client.post('/moderation/reports/${i.type}/${i.id}/restore');
}
