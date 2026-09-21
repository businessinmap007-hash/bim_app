/// One client's week in the trainer overview — mirrors an entry of
/// `TrainingPlanService::weeklySummaryForTrainer()`'s `clients`.
class ClientWeekAdherence {
  final int planId;
  final int weeklyTargetRounds;
  final int completedRounds;
  final int? adherencePercent;
  final int activeDays;
  final int checkIns;

  const ClientWeekAdherence({
    required this.planId,
    this.weeklyTargetRounds = 0,
    this.completedRounds = 0,
    this.adherencePercent,
    this.activeDays = 0,
    this.checkIns = 0,
  });

  factory ClientWeekAdherence.fromJson(Map<String, dynamic> json) => ClientWeekAdherence(
    planId: json['plan_id'] as int,
    weeklyTargetRounds: (json['weekly_target_rounds'] as num?)?.toInt() ?? 0,
    completedRounds: (json['completed_rounds'] as num?)?.toInt() ?? 0,
    adherencePercent: (json['adherence_percent'] as num?)?.toInt(),
    activeDays: (json['active_days'] as num?)?.toInt() ?? 0,
    checkIns: (json['check_ins'] as num?)?.toInt() ?? 0,
  );
}

/// `GET /business/training-plans/weekly-summary` — every active client's
/// adherence for one 7-day window, plus the trainer's average.
class TrainerWeeklySummary {
  final DateTime from;
  final DateTime to;
  final int? averageAdherence;
  final Map<int, ClientWeekAdherence> byPlan;

  const TrainerWeeklySummary({
    required this.from,
    required this.to,
    this.averageAdherence,
    this.byPlan = const {},
  });

  factory TrainerWeeklySummary.fromJson(Map<String, dynamic> json) {
    final clients = (json['clients'] as List<dynamic>? ?? [])
        .map((e) => ClientWeekAdherence.fromJson(e as Map<String, dynamic>));
    return TrainerWeeklySummary(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      averageAdherence: (json['average_adherence'] as num?)?.toInt(),
      byPlan: {for (final c in clients) c.planId: c},
    );
  }
}
