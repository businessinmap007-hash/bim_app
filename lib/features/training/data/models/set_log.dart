/// One confirmed set with what was actually done in it. Reps and weight are
/// optional: a set can be confirmed without numbers.
class LoggedSet {
  final int id;
  final int roundNumber;
  final int? reps;
  final double? weight;

  const LoggedSet({required this.id, required this.roundNumber, this.reps, this.weight});

  factory LoggedSet.fromJson(Map<String, dynamic> json) => LoggedSet(
    id: json['id'] as int,
    roundNumber: (json['round_number'] as num?)?.toInt() ?? 0,
    reps: (json['reps'] as num?)?.toInt(),
    weight: (json['weight'] as num?)?.toDouble(),
  );

  /// "10 × 60" — a dash stands in for a number that was not recorded.
  String get label => '${reps ?? '–'} × ${formatWeight(weight) ?? '–'}';
}

/// Weights are kg and usually whole: 60, not 60.0; 42.5 stays 42.5.
String? formatWeight(double? w) {
  if (w == null) return null;
  return w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toString();
}

/// «20 · 25 · 30» — per-set weights for one week.
String formatWeightList(List<double> weights) => weights.map((w) => formatWeight(w) ?? '').join(' · ');

/// Reads «20-25-30» / «20,25,30» / «20 25 30» into numbers; only a dot is a decimal point.
List<double> parseWeightList(String text) =>
    RegExp(r'\d+(?:\.\d+)?').allMatches(text).map((m) => double.parse(m.group(0)!)).toList();

/// The result of confirming a set.
class SetConfirmation {
  final LoggedSet round;
  final int completedRounds;
  final int? totalSets;

  /// True only for the confirmation that finished every exercise owed that day
  /// (the trainer has just been told).
  final bool sessionCompleted;

  const SetConfirmation({
    required this.round,
    required this.completedRounds,
    this.totalSets,
    this.sessionCompleted = false,
  });
}

class ExerciseMonthStat {
  final int exerciseId;
  final String name;
  final int setsDone;
  final int totalReps;
  final double? maxWeight;
  final double volumeKg;

  const ExerciseMonthStat({
    required this.exerciseId,
    required this.name,
    this.setsDone = 0,
    this.totalReps = 0,
    this.maxWeight,
    this.volumeKg = 0,
  });

  factory ExerciseMonthStat.fromJson(Map<String, dynamic> json) => ExerciseMonthStat(
    exerciseId: (json['exercise_id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    setsDone: (json['sets_done'] as num?)?.toInt() ?? 0,
    totalReps: (json['total_reps'] as num?)?.toInt() ?? 0,
    maxWeight: (json['max_weight'] as num?)?.toDouble(),
    volumeKg: (json['volume_kg'] as num?)?.toDouble() ?? 0,
  );
}

/// A finished day inside the month.
class FinishedDay {
  final DateTime date;
  final int exercisesCount;
  final int setsCount;
  final int totalReps;
  final double volumeKg;

  const FinishedDay({
    required this.date,
    this.exercisesCount = 0,
    this.setsCount = 0,
    this.totalReps = 0,
    this.volumeKg = 0,
  });

  factory FinishedDay.fromJson(Map<String, dynamic> json) => FinishedDay(
    date: DateTime.parse(json['date'] as String),
    exercisesCount: (json['exercises_count'] as num?)?.toInt() ?? 0,
    setsCount: (json['sets_count'] as num?)?.toInt() ?? 0,
    totalReps: (json['total_reps'] as num?)?.toInt() ?? 0,
    volumeKg: (json['volume_kg'] as num?)?.toDouble() ?? 0,
  );
}

/// `GET .../monthly-summary` — the month rolled up from the confirmed sets.
class TrainingMonthlySummary {
  final String month; // yyyy-MM
  final int sessionsCompleted;
  final int activeDays;
  final int totalSets;
  final int totalReps;
  final double volumeKg;
  final List<ExerciseMonthStat> exercises;
  final List<FinishedDay> sessions;
  final int checkIns;
  final double? firstWeight;
  final double? latestWeight;

  const TrainingMonthlySummary({
    required this.month,
    this.sessionsCompleted = 0,
    this.activeDays = 0,
    this.totalSets = 0,
    this.totalReps = 0,
    this.volumeKg = 0,
    this.exercises = const [],
    this.sessions = const [],
    this.checkIns = 0,
    this.firstWeight,
    this.latestWeight,
  });

  bool get isEmpty => totalSets == 0 && checkIns == 0;

  factory TrainingMonthlySummary.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>? ?? const {};
    return TrainingMonthlySummary(
      month: json['month'] as String? ?? '',
      sessionsCompleted: (json['sessions_completed'] as num?)?.toInt() ?? 0,
      activeDays: (json['active_days'] as num?)?.toInt() ?? 0,
      totalSets: (json['total_sets'] as num?)?.toInt() ?? 0,
      totalReps: (json['total_reps'] as num?)?.toInt() ?? 0,
      volumeKg: (json['volume_kg'] as num?)?.toDouble() ?? 0,
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => ExerciseMonthStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((e) => FinishedDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkIns: (progress['check_ins'] as num?)?.toInt() ?? 0,
      firstWeight: (progress['first_weight'] as num?)?.toDouble(),
      latestWeight: (progress['latest_weight'] as num?)?.toDouble(),
    );
  }
}

/// One exercise's sets on a given day, next to the prescription — the trainer's
/// day view (`GET business/training-plans/{id}/log`).
class DayLogExercise {
  final String name;
  final int? targetSets;
  final String? targetReps;
  final double? targetWeight;
  final List<LoggedSet> sets;

  const DayLogExercise({
    required this.name,
    this.targetSets,
    this.targetReps,
    this.targetWeight,
    this.sets = const [],
  });

  factory DayLogExercise.fromJson(Map<String, dynamic> json) => DayLogExercise(
    name: json['name'] as String? ?? '',
    targetSets: (json['target_sets'] as num?)?.toInt(),
    targetReps: json['target_reps'] as String?,
    targetWeight: (json['target_weight'] as num?)?.toDouble(),
    sets: (json['sets'] as List<dynamic>? ?? []).map((e) => LoggedSet.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class LibraryPhoto {
  final int id;
  final String? caption;
  final String url;

  const LibraryPhoto({required this.id, this.caption, required this.url});
}
