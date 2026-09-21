/// A key + label pair — an exercise kind (strength, cardio…) or a piece of
/// equipment, labelled by the server in the request locale.
class LibraryOption {
  final String key;
  final String label;

  const LibraryOption({required this.key, required this.label});

  factory LibraryOption.fromJson(Map<String, dynamic> json) =>
      LibraryOption(key: json['key'] as String, label: json['label'] as String? ?? '');
}

/// A section of the catalogue — chest, back, legs, cardio…
class ExerciseSection {
  final int id;
  final String name;

  const ExerciseSection({required this.id, required this.name});

  factory ExerciseSection.fromJson(Map<String, dynamic> json) =>
      ExerciseSection(id: json['id'] as int, name: json['name'] as String? ?? '');
}

/// One catalogue exercise a trainer can pick.
class LibraryExercise {
  final int id;
  final int categoryId;
  final String name;
  final String kind;
  final String? equipment;
  final int? defaultSets;
  final String? defaultReps;

  const LibraryExercise({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.kind,
    this.equipment,
    this.defaultSets,
    this.defaultReps,
  });

  factory LibraryExercise.fromJson(Map<String, dynamic> json) => LibraryExercise(
    id: json['id'] as int,
    categoryId: json['category_id'] as int,
    name: json['name'] as String? ?? '',
    kind: json['kind'] as String? ?? 'strength',
    equipment: json['equipment'] as String?,
    defaultSets: (json['default_sets'] as num?)?.toInt(),
    defaultReps: json['default_reps'] as String?,
  );
}

/// `GET /business/training/exercise-library` — the whole active catalogue,
/// filtered on the device (a few hundred short rows).
class ExerciseLibrary {
  final List<ExerciseSection> sections;
  final List<LibraryOption> kinds;
  final List<LibraryOption> equipment;
  final List<LibraryExercise> exercises;

  const ExerciseLibrary({
    this.sections = const [],
    this.kinds = const [],
    this.equipment = const [],
    this.exercises = const [],
  });

  factory ExerciseLibrary.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        (json[key] as List<dynamic>? ?? []).map((e) => f(e as Map<String, dynamic>)).toList();

    return ExerciseLibrary(
      sections: list('categories', ExerciseSection.fromJson),
      kinds: list('kinds', LibraryOption.fromJson),
      equipment: list('equipment', LibraryOption.fromJson),
      exercises: list('exercises', LibraryExercise.fromJson),
    );
  }

  String? sectionName(int id) {
    for (final s in sections) {
      if (s.id == id) return s.name;
    }
    return null;
  }

  String? equipmentLabel(String? key) {
    if (key == null) return null;
    for (final e in equipment) {
      if (e.key == key) return e.label;
    }
    return null;
  }
}
