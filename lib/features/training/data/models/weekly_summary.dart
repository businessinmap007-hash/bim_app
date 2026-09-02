class WeeklySummaryDay {
  final DateTime date;
  final int completedRounds;
  const WeeklySummaryDay({required this.date, required this.completedRounds});

  factory WeeklySummaryDay.fromJson(Map<String, dynamic> json) => WeeklySummaryDay(
    date: DateTime.parse(json['date'] as String),
    completedRounds: (json['completed_rounds'] as num?)?.toInt() ?? 0,
  );
}

/// Mirrors `TrainingPlanService::weeklySummary()`'s payload.
class TrainingWeeklySummary {
  final DateTime from;
  final DateTime to;
  final int weeklyTargetRounds;
  final int completedRounds;
  final int? adherencePercent;
  final int activeDays;
  final List<WeeklySummaryDay> days;
  final int checkIns;
  final double? latestWeight;

  const TrainingWeeklySummary({
    required this.from,
    required this.to,
    required this.weeklyTargetRounds,
    required this.completedRounds,
    this.adherencePercent,
    required this.activeDays,
    this.days = const [],
    required this.checkIns,
    this.latestWeight,
  });

  factory TrainingWeeklySummary.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>? ?? const {};
    return TrainingWeeklySummary(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      weeklyTargetRounds: (json['weekly_target_rounds'] as num?)?.toInt() ?? 0,
      completedRounds: (json['completed_rounds'] as num?)?.toInt() ?? 0,
      adherencePercent: (json['adherence_percent'] as num?)?.toInt(),
      activeDays: (json['active_days'] as num?)?.toInt() ?? 0,
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => WeeklySummaryDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkIns: (progress['check_ins'] as num?)?.toInt() ?? 0,
      latestWeight: (progress['latest_weight'] as num?)?.toDouble(),
    );
  }
}
