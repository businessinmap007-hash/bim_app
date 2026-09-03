import '../../../../core/env/env.dart';

/// One image owned by an exercise or a meal — the trainer's illustration,
/// read-only from the client's side.
class PlanImage {
  final int id;
  final String url;
  const PlanImage({required this.id, required this.url});

  factory PlanImage.fromJson(Map<String, dynamic> json) => PlanImage(
    id: json['id'] as int,
    url: Env.assetUrl(json['image'] as String?) ?? '',
  );
}

/// day_of_week uses the same 0=Sunday..6=Saturday convention as business
/// working hours.
class PlanExercise {
  final int id;
  final int? dayOfWeek;
  final String name;
  final int? sets;
  final String? reps;
  final int? restSeconds;
  final String? notes;
  final List<PlanImage> images;
  final int completedRoundsToday;

  const PlanExercise({
    required this.id,
    this.dayOfWeek,
    required this.name,
    this.sets,
    this.reps,
    this.restSeconds,
    this.notes,
    this.images = const [],
    this.completedRoundsToday = 0,
  });

  bool get isDoneToday => sets != null && completedRoundsToday >= sets!;

  factory PlanExercise.fromJson(Map<String, dynamic> json) => PlanExercise(
    id: json['id'] as int,
    dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
    name: json['name'] as String? ?? '',
    sets: (json['sets'] as num?)?.toInt(),
    reps: json['reps'] as String?,
    restSeconds: (json['rest_seconds'] as num?)?.toInt(),
    notes: json['notes'] as String?,
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => PlanImage.fromJson(e as Map<String, dynamic>))
        .toList(),
    completedRoundsToday: (json['completed_rounds_today'] as num?)?.toInt() ?? 0,
  );
}

/// meal_type is one of PlanMeal::TYPES on the backend: breakfast/lunch/dinner/snack.
class PlanMeal {
  final int id;
  final String mealType;
  final String name;
  final int? calories;
  final String? notes;
  final List<PlanImage> images;

  const PlanMeal({
    required this.id,
    required this.mealType,
    required this.name,
    this.calories,
    this.notes,
    this.images = const [],
  });

  factory PlanMeal.fromJson(Map<String, dynamic> json) => PlanMeal(
    id: (json['id'] as num?)?.toInt() ?? 0,
    mealType: json['meal_type'] as String? ?? '',
    name: json['name'] as String? ?? '',
    calories: (json['calories'] as num?)?.toInt(),
    notes: json['notes'] as String?,
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => PlanImage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class PlanProgressLog {
  final DateTime? loggedOn;
  final double? weight;
  final String? notes;

  const PlanProgressLog({this.loggedOn, this.weight, this.notes});

  factory PlanProgressLog.fromJson(Map<String, dynamic> json) => PlanProgressLog(
    loggedOn: json['logged_on'] != null ? DateTime.tryParse(json['logged_on'] as String) : null,
    weight: (json['weight'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
  );
}

/// Mirrors `ClientTrainingController::serialize()`. The list endpoint leaves
/// exercises/meals/progress null; only `show()` populates them.
class TrainingPlan {
  final int id;
  final String title;
  final String? goal;
  final String status;
  final DateTime? startsOn;
  final DateTime? endsOn;
  final String? notes;
  final int trainerId;
  final String? trainerName;
  final String? trainerLogoUrl;
  // Only present when parsed from the TRAINER's own side (business/training-
  // plans) — that response carries `client`, not `trainer`.
  final int? clientId;
  final String? clientName;
  final int? exercisesCount;
  final int? mealsCount;
  final List<PlanExercise>? exercises;
  final List<PlanMeal>? meals;
  final List<PlanProgressLog>? progress;

  const TrainingPlan({
    required this.id,
    required this.title,
    this.goal,
    required this.status,
    this.startsOn,
    this.endsOn,
    this.notes,
    required this.trainerId,
    this.trainerName,
    this.trainerLogoUrl,
    this.clientId,
    this.clientName,
    this.exercisesCount,
    this.mealsCount,
    this.exercises,
    this.meals,
    this.progress,
  });

  bool get isActive => status == 'active';

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    final trainer = json['trainer'] as Map<String, dynamic>?;
    final client = json['client'] as Map<String, dynamic>?;
    return TrainingPlan(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      goal: json['goal'] as String?,
      status: json['status'] as String? ?? 'active',
      startsOn: json['starts_on'] != null ? DateTime.tryParse(json['starts_on'] as String) : null,
      endsOn: json['ends_on'] != null ? DateTime.tryParse(json['ends_on'] as String) : null,
      notes: json['notes'] as String?,
      trainerId: (trainer?['id'] as int?) ?? 0,
      trainerName: trainer?['name'] as String?,
      trainerLogoUrl: Env.assetUrl(trainer?['logo'] as String?),
      clientId: (client?['id'] as num?)?.toInt(),
      clientName: client?['name'] as String?,
      exercisesCount: (json['exercises_count'] as num?)?.toInt(),
      mealsCount: (json['meals_count'] as num?)?.toInt(),
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      meals: (json['meals'] as List<dynamic>?)
          ?.map((e) => PlanMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
      progress: (json['progress'] as List<dynamic>?)
          ?.map((e) => PlanProgressLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
