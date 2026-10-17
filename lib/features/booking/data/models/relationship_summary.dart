/// What a customer and a business have been through together on the app (bookings, orders and clinic visits) — told to
/// BOTH of them: how many dealings, how many succeeded, how many did not complete, and whether there was a dispute.
class RelationshipSummary {
  final int total;
  final int completed;
  final int notCompleted;
  final int ongoing;
  final int disputes;
  final int openDisputes;

  const RelationshipSummary({
    this.total = 0,
    this.completed = 0,
    this.notCompleted = 0,
    this.ongoing = 0,
    this.disputes = 0,
    this.openDisputes = 0,
  });

  /// Nothing to say: no dealings and no dispute.
  bool get isEmpty => total == 0 && disputes == 0;

  factory RelationshipSummary.fromJson(Map<String, dynamic> json) => RelationshipSummary(
    total: (json['total'] as num?)?.toInt() ?? 0,
    completed: (json['completed'] as num?)?.toInt() ?? 0,
    notCompleted: (json['not_completed'] as num?)?.toInt() ?? 0,
    ongoing: (json['ongoing'] as num?)?.toInt() ?? 0,
    disputes: (json['disputes'] as num?)?.toInt() ?? 0,
    openDisputes: (json['open_disputes'] as num?)?.toInt() ?? 0,
  );
}
