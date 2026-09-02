import 'template_item.dart';

/// A trainer's own reusable training template — see
/// Api\V2\TrainingTemplateController::serialize. `exercises`/`meals` are
/// only populated when the backend eager-loads them (the list endpoint
/// carries just the counts; `show` carries the full rows).
class TrainingTemplate {
  final int id;
  final String title;
  final String? goal;
  final String? notes;
  final int? exercisesCount;
  final int? mealsCount;
  final List<TemplateExercise> exercises;
  final List<TemplateMeal> meals;

  const TrainingTemplate({
    required this.id,
    required this.title,
    this.goal,
    this.notes,
    this.exercisesCount,
    this.mealsCount,
    this.exercises = const [],
    this.meals = const [],
  });

  factory TrainingTemplate.fromJson(Map<String, dynamic> json) => TrainingTemplate(
    id: json['id'] as int,
    title: json['title'] as String,
    goal: json['goal'] as String?,
    notes: json['notes'] as String?,
    exercisesCount: json['exercises_count'] as int?,
    mealsCount: json['meals_count'] as int?,
    exercises: (json['exercises'] as List<dynamic>?)
            ?.map((e) => TemplateExercise.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    meals: (json['meals'] as List<dynamic>?)?.map((e) => TemplateMeal.fromJson(e as Map<String, dynamic>)).toList() ??
        const [],
  );
}
