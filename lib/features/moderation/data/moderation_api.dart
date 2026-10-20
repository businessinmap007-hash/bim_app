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

  /// An account row: how many times it was frozen already, and the count at which it is deleted.
  final int freezeCount;
  final int freezesToDelete;

  /// A conversation row (type `conversation`).
  final ConversationInfo? conversation;

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
    this.freezeCount = 0,
    this.freezesToDelete = 5,
    this.conversation,
  });

  bool get isConversation => type == 'conversation';
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
    freezeCount: (json['freeze_count'] as num?)?.toInt() ?? 0,
    freezesToDelete: (json['freezes_to_delete'] as num?)?.toInt() ?? 5,
    conversation: json['conversation'] is Map<String, dynamic> ? ConversationInfo.fromJson(json['conversation'] as Map<String, dynamic>) : null,
  );
}

/// A message as a moderator sees it (the ones the reporter chose, or the whole chat once it is open).
class ConvMessage {
  final int id;
  final String? senderName;
  final String body;
  final DateTime? createdAt;

  const ConvMessage({required this.id, this.senderName, required this.body, this.createdAt});

  factory ConvMessage.fromJson(Map<String, dynamic> json) => ConvMessage(
    id: (json['id'] as num).toInt(),
    senderName: (json['sender'] as Map<String, dynamic>?)?['name'] as String?,
    body: json['body'] as String? ?? '',
    createdAt: EgyptTime.tryParse(json['created_at'] as String?),
  );
}

/// Where each way of reading a reported conversation stands.
class ConvAccess {
  final bool accessible;
  final bool allConsented;
  final bool anyDeclined;
  final int approvals;
  final int quorum;
  final bool iVouched;

  const ConvAccess({
    this.accessible = false,
    this.allConsented = false,
    this.anyDeclined = false,
    this.approvals = 0,
    this.quorum = 3,
    this.iVouched = false,
  });

  factory ConvAccess.fromJson(Map<String, dynamic> json) => ConvAccess(
    accessible: json['accessible'] as bool? ?? false,
    allConsented: json['all_consented'] as bool? ?? false,
    anyDeclined: json['any_declined'] as bool? ?? false,
    approvals: (json['approvals'] as num?)?.toInt() ?? 0,
    quorum: (json['quorum'] as num?)?.toInt() ?? 3,
    iVouched: json['i_vouched'] as bool? ?? false,
  );
}

/// A reported CONVERSATION on the queue: who talks, the messages the reporter chose to show, and the three ways to read the rest.
class ConversationInfo {
  final int threadId;
  final List<({int id, String name})> parties;
  final List<ConvMessage> selected;
  final ConvAccess access;

  const ConversationInfo({
    required this.threadId,
    this.parties = const [],
    this.selected = const [],
    this.access = const ConvAccess(),
  });

  factory ConversationInfo.fromJson(Map<String, dynamic> json) => ConversationInfo(
    threadId: (json['thread_id'] as num).toInt(),
    parties: [
      for (final p in (json['parties'] as List<dynamic>? ?? const []))
        (
          id: ((p as Map<String, dynamic>)['id'] as num).toInt(),
          name: p['name'] as String? ?? '',
        ),
    ],
    selected: [
      for (final m in (json['selected'] as List<dynamic>? ?? const []))
        ConvMessage.fromJson(m as Map<String, dynamic>),
    ],
    access: ConvAccess.fromJson(json['access'] as Map<String, dynamic>? ?? const {}),
  );
}

/// Where the deletion of a frozen account stands, as that account sees it: `review` (the moderators' panel is deciding) or
/// `scheduled` (approved; runs at [executeAfter] unless the account objects in writing).
class AccountDeletionState {
  final String state;
  final DateTime? executeAfter;
  final bool canObject;
  final bool objected;

  const AccountDeletionState({
    required this.state,
    this.executeAfter,
    this.canObject = false,
    this.objected = false,
  });

  bool get isScheduled => state == 'scheduled';

  factory AccountDeletionState.fromJson(Map<String, dynamic> json) =>
      AccountDeletionState(
        state: json['state'] as String? ?? 'review',
        executeAfter: EgyptTime.tryParse(json['execute_after'] as String?),
        canObject: json['can_object'] as bool? ?? false,
        objected: json['objected'] as bool? ?? false,
      );
}

/// The moderators' case on a reported ACCOUNT, as that account sees it: the chat to answer in, and whether it is frozen.
class MyAccountCase {
  final int id;
  final DateTime? frozenUntil;
  final AccountDeletionState? deletion;
  const MyAccountCase({required this.id, this.frozenUntil, this.deletion});

  factory MyAccountCase.fromJson(Map<String, dynamic> json) => MyAccountCase(
    id: (json['id'] as num).toInt(),
    frozenUntil: EgyptTime.tryParse(json['frozen_until'] as String?),
  );
}

/// A deletion waiting for the moderators' panel (an account's fifth recent freeze). Votes carry no moderator names.
class DeletionProposal {
  final int id;
  final int round;
  final String accountName;
  final List<({String? reason, DateTime? at})> freezes;
  final String? objection;
  final int approvals;
  final int rejections;
  final int approvalsNeeded;
  final int rejectionsNeeded;
  final bool canVote;

  const DeletionProposal({
    required this.id,
    required this.round,
    required this.accountName,
    this.freezes = const [],
    this.objection,
    this.approvals = 0,
    this.rejections = 0,
    this.approvalsNeeded = 3,
    this.rejectionsNeeded = 2,
    this.canVote = false,
  });

  factory DeletionProposal.fromJson(Map<String, dynamic> json) =>
      DeletionProposal(
        id: (json['id'] as num).toInt(),
        round: (json['round'] as num?)?.toInt() ?? 1,
        accountName:
            (json['account'] as Map<String, dynamic>?)?['name'] as String? ??
            '',
        freezes: [
          for (final f in (json['freezes'] as List<dynamic>? ?? const []))
            (
              reason: (f as Map<String, dynamic>)['reason'] as String?,
              at: EgyptTime.tryParse(f['at'] as String?),
            ),
        ],
        objection: json['objection'] as String?,
        approvals: (json['approvals'] as num?)?.toInt() ?? 0,
        rejections: (json['rejections'] as num?)?.toInt() ?? 0,
        approvalsNeeded: (json['approvals_needed'] as num?)?.toInt() ?? 3,
        rejectionsNeeded: (json['rejections_needed'] as num?)?.toInt() ?? 2,
        canVote: json['can_vote'] as bool? ?? false,
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
    List<int>? messageIds,
  }) => _client.post(
    '/reports',
    data: {
      'type': type,
      'id': id,
      'reason': reason,
      if (messageIds != null && messageIds.isNotEmpty) 'message_ids': messageIds,
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

  // ── a reported conversation: the three ways to read it, and acting on one of its people ──

  /// Way 2: ask both parties to allow the moderators to read it.
  Future<void> requestConsent(ReportedItem i) =>
      _client.post('/moderation/reports/conversation/${i.id}/request-consent');

  /// Way 3: this moderator's vote toward the quorum.
  Future<void> vouch(ReportedItem i) =>
      _client.post('/moderation/reports/conversation/${i.id}/vouch');

  /// The whole conversation, once open (an ApiException with the lock message otherwise).
  Future<List<ConvMessage>> conversationMessages(ReportedItem i) async {
    final data =
        await _client.get('/moderation/reports/conversation/${i.id}/messages')
            as Map<String, dynamic>;
    return [
      for (final m in (data['messages'] as List<dynamic>? ?? const []))
        ConvMessage.fromJson(m as Map<String, dynamic>),
    ];
  }

  Future<int> partyChat(ReportedItem i, int userId) async {
    final data =
        await _client.post('/moderation/reports/conversation/${i.id}/party/$userId/chat')
            as Map<String, dynamic>;
    return (data['case_id'] as num).toInt();
  }

  Future<void> partyFreeze(ReportedItem i, int userId) => _client.post(
    '/moderation/reports/conversation/${i.id}/party/$userId/freeze',
  );

  /// The account's own open case (null when there is none).
  Future<MyAccountCase?> myCase() async {
    final data =
        await _client.get('/moderation/my-case') as Map<String, dynamic>;
    final c = data['case'] as Map<String, dynamic>?;
    final d = data['deletion'] as Map<String, dynamic>?;

    if (c == null) return null;
    final base = MyAccountCase.fromJson(c);

    return MyAccountCase(
      id: base.id,
      frozenUntil: base.frozenUntil,
      deletion: d == null ? null : AccountDeletionState.fromJson(d),
    );
  }

  /// A frozen account objects in writing to an approved deletion.
  Future<void> objectToDeletion(String text) =>
      _client.post('/moderation/my-case/objection', data: {'objection': text});

  /// The deletions waiting for the moderators' panel.
  Future<List<DeletionProposal>> deletionProposals() async {
    final data =
        await _client.get('/moderation/deletion-proposals')
            as Map<String, dynamic>;
    return [
      for (final p in (data['items'] as List<dynamic>? ?? const []))
        DeletionProposal.fromJson(p as Map<String, dynamic>),
    ];
  }

  Future<void> voteOnDeletion(int id, bool approve) => _client.post(
    '/moderation/deletion-proposals/$id/vote',
    data: {'vote': approve ? 'approve' : 'reject'},
  );

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
