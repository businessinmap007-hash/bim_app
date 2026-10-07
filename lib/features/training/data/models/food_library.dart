/// A section of the food catalogue — bread and starches, legumes, dairy, meat, fruit…
class FoodSection {
  final int id;
  final String name;

  const FoodSection({required this.id, required this.name});

  factory FoodSection.fromJson(Map<String, dynamic> json) =>
      FoodSection(id: (json['id'] as num).toInt(), name: json['name'] as String? ?? '');
}

/// One food of «جدول التغذية»: its numbers are for the serving its label names («رغيف (90 جم)» = 245 سعرة).
class LibraryFood {
  final int id;
  final int categoryId;
  final String name;
  final String serving;
  final int? servingGrams;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  /// the specialist's own entry — they may correct and delete it; the shared catalogue is read-only
  final bool mine;

  const LibraryFood({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.serving,
    this.servingGrams,
    required this.calories,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.mine = false,
  });

  /// the calories of [servings] servings — the same math the server uses to store the meal
  int caloriesFor(double servings) => (calories * servings).round();

  factory LibraryFood.fromJson(Map<String, dynamic> json) => LibraryFood(
    id: (json['id'] as num).toInt(),
    categoryId: (json['category_id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    serving: json['serving'] as String? ?? '',
    servingGrams: (json['serving_grams'] as num?)?.toInt(),
    calories: (json['calories'] as num?)?.toInt() ?? 0,
    proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
    carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
    fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
    mine: json['mine'] as bool? ?? false,
  );
}

/// `GET /business/training/food-library` — the shared catalogue plus the specialist's own foods, filtered on the device.
class FoodLibrary {
  final List<FoodSection> sections;
  final List<LibraryFood> foods;

  const FoodLibrary({this.sections = const [], this.foods = const []});

  factory FoodLibrary.fromJson(Map<String, dynamic> json) => FoodLibrary(
    sections: (json['categories'] as List<dynamic>? ?? [])
        .map((e) => FoodSection.fromJson(e as Map<String, dynamic>))
        .toList(),
    foods: (json['foods'] as List<dynamic>? ?? [])
        .map((e) => LibraryFood.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  String? sectionName(int id) {
    for (final s in sections) {
      if (s.id == id) return s.name;
    }
    return null;
  }
}

/// What the picker hands back: the food and how many servings of it.
class PickedFood {
  final LibraryFood food;
  final double servings;

  const PickedFood(this.food, this.servings);

  int get calories => food.caloriesFor(servings);
}
