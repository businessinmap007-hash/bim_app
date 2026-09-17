/// One recorded staff action from StaffActivityLogger on the backend — an
/// order or booking action attributed to the real acting user, never the
/// business alone. Mirrors Api\V2\BusinessStaffController::activity().
class StaffActivityEntry {
  final int id;
  final DateTime? createdAt;
  final int userId;
  final String userName;
  final bool isOwner;
  final String capability;
  final List<String> actions;
  final String subjectType; // 'order' | 'booking'
  final int subjectId;

  const StaffActivityEntry({
    required this.id,
    this.createdAt,
    required this.userId,
    required this.userName,
    required this.isOwner,
    required this.capability,
    required this.actions,
    required this.subjectType,
    required this.subjectId,
  });

  factory StaffActivityEntry.fromJson(Map<String, dynamic> json) => StaffActivityEntry(
    id: json['id'] as int? ?? 0,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    userId: json['user_id'] as int? ?? 0,
    userName: json['user_name'] as String? ?? '',
    isOwner: json['is_owner'] as bool? ?? false,
    capability: json['capability'] as String? ?? '',
    actions: (json['actions'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    subjectType: json['subject_type'] as String? ?? '',
    subjectId: json['subject_id'] as int? ?? 0,
  );
}

/// One staff member's total operation count for the whole filtered period
/// (not just the current page) — what lets the owner see who did the most
/// at a glance, end of shift.
class StaffActivitySummaryEntry {
  final int userId;
  final String name;
  final bool isOwner;
  final int count;

  const StaffActivitySummaryEntry({
    required this.userId,
    required this.name,
    required this.isOwner,
    required this.count,
  });

  factory StaffActivitySummaryEntry.fromJson(Map<String, dynamic> json) => StaffActivitySummaryEntry(
    userId: json['user_id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    isOwner: json['is_owner'] as bool? ?? false,
    count: json['count'] as int? ?? 0,
  );
}

class StaffActivityPage {
  final List<StaffActivityEntry> rows;
  final List<StaffActivitySummaryEntry> summary;
  final bool hasMore;

  const StaffActivityPage({required this.rows, required this.summary, required this.hasMore});

  factory StaffActivityPage.fromJson(Map<String, dynamic> json) {
    final rowsPage = json['rows'] as Map<String, dynamic>? ?? const {};
    final currentPage = rowsPage['current_page'] as int? ?? 1;
    final lastPage = rowsPage['last_page'] as int? ?? 1;
    return StaffActivityPage(
      rows: (rowsPage['data'] as List<dynamic>? ?? [])
          .map((e) => StaffActivityEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: (json['summary'] as List<dynamic>? ?? [])
          .map((e) => StaffActivitySummaryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: currentPage < lastPage,
    );
  }
}
