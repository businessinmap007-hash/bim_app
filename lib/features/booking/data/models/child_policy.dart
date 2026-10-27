/// One age band of a hotel's «سياسة الأطفال»: a child of [from]–[to] years pays [percent] of every night's price (0 = free).
class ChildBand {
  final int from;
  final int to;
  final double percent;

  const ChildBand({required this.from, required this.to, required this.percent});

  factory ChildBand.fromJson(Map<String, dynamic> json) => ChildBand(
    from: (json['from'] as num?)?.toInt() ?? 0,
    to: (json['to'] as num?)?.toInt() ?? 0,
    percent: (json['percent'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {'from': from, 'to': to, 'percent': percent};

  ChildBand copyWith({int? from, int? to, double? percent}) => ChildBand(from: from ?? this.from, to: to ?? this.to, percent: percent ?? this.percent);
}

/// A hotel's «سياسة الأطفال»: who is an adult, from which age a child takes a place in the room, what each age pays, and whether a
/// child's meals follow the same percentage.
class ChildPolicy {
  final int adultFromAge;
  final int countsFromAge;
  final bool mealsFollow;
  final List<ChildBand> bands;

  const ChildPolicy({this.adultFromAge = 12, this.countsFromAge = 6, this.mealsFollow = true, this.bands = const []});

  bool isAdult(int age) => age >= adultFromAge;

  /// Does a child of this age take a place in the room's capacity?
  bool counts(int age) => age >= countsFromAge;

  /// The percentage of the night a child of this age pays; an age no band covers pays nothing, an adult is inside the room's price.
  double percentFor(int age) {
    if (isAdult(age)) return 0;
    for (final b in bands) {
      if (age >= b.from && age <= b.to) return b.percent;
    }
    return 0;
  }

  static ChildPolicy? fromJsonOrNull(Object? json) => json is Map<String, dynamic>
      ? ChildPolicy(
          adultFromAge: (json['adult_from_age'] as num?)?.toInt() ?? 12,
          countsFromAge: (json['counts_from_age'] as num?)?.toInt() ?? 6,
          mealsFollow: json['meals_follow'] as bool? ?? true,
          bands: [for (final b in json['bands'] as List<dynamic>? ?? const []) ChildBand.fromJson(b as Map<String, dynamic>)],
        )
      : null;

  Map<String, dynamic> toJson() => {
    'adult_from_age': adultFromAge,
    'counts_from_age': countsFromAge,
    'meals_follow': mealsFollow,
    'bands': [for (final b in bands) b.toJson()],
  };
}
