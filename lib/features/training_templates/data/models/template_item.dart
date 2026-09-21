/// One exercise row on a reusable training template — see
/// Api\V2\TrainingTemplateController::exercise().
class TemplateExercise {
  final int id;
  final int? dayOfWeek;
  final String name;
  final int? sets;
  final String? reps;
  final int? restSeconds;
  final String? notes;
  final int sortOrder;

  /// «Push» / «Pull» / «Legs», per-set base weights, and how they climb.
  final String? dayLabel;
  final List<double> setWeights;
  final int? progressEveryWeeks;
  final double? progressIncrementKg;

  const TemplateExercise({
    required this.id,
    this.dayOfWeek,
    required this.name,
    this.sets,
    this.reps,
    this.restSeconds,
    this.notes,
    required this.sortOrder,
    this.dayLabel,
    this.setWeights = const [],
    this.progressEveryWeeks,
    this.progressIncrementKg,
  });

  factory TemplateExercise.fromJson(Map<String, dynamic> json) => TemplateExercise(
    id: json['id'] as int,
    dayOfWeek: json['day_of_week'] as int?,
    name: json['name'] as String,
    sets: json['sets'] as int?,
    reps: json['reps'] as String?,
    restSeconds: json['rest_seconds'] as int?,
    notes: json['notes'] as String?,
    sortOrder: json['sort_order'] as int,
    dayLabel: json['day_label'] as String?,
    setWeights: (json['set_weights'] as List<dynamic>? ?? const []).map((e) => (e as num).toDouble()).toList(),
    progressEveryWeeks: (json['progress_every_weeks'] as num?)?.toInt(),
    progressIncrementKg: (json['progress_increment_kg'] as num?)?.toDouble(),
  );
}

/// One meal row on a reusable training template — see
/// Api\V2\TrainingTemplateController::meal().
class TemplateMeal {
  final int id;
  final String mealType;
  final String name;
  final int? calories;
  final String? notes;
  final int sortOrder;

  const TemplateMeal({
    required this.id,
    required this.mealType,
    required this.name,
    this.calories,
    this.notes,
    required this.sortOrder,
  });

  factory TemplateMeal.fromJson(Map<String, dynamic> json) => TemplateMeal(
    id: json['id'] as int,
    mealType: json['meal_type'] as String,
    name: json['name'] as String,
    calories: json['calories'] as int?,
    notes: json['notes'] as String?,
    sortOrder: json['sort_order'] as int,
  );
}
