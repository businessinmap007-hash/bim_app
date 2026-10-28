/// One age band of a hotel's «سياسة الأطفال»: a child of [from]–[to] years pays [percent] of every night's price (0 = free).
class ChildBand {
  final int from;
  final int to;

  /// what the room's FIRST child of these ages pays (0 = free: «طفل واحد مجانًا لكل غرفة»)
  final double percent;

  /// what each FURTHER child of these ages pays
  final double secondPercent;

  const ChildBand({required this.from, required this.to, required this.percent, double? secondPercent}) : secondPercent = secondPercent ?? percent;

  factory ChildBand.fromJson(Map<String, dynamic> json) => ChildBand(
    from: (json['from'] as num?)?.toInt() ?? 0,
    to: (json['to'] as num?)?.toInt() ?? 0,
    percent: (json['percent'] as num?)?.toDouble() ?? 0,
    secondPercent: (json['second_percent'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {'from': from, 'to': to, 'percent': percent, 'second_percent': secondPercent};

  ChildBand copyWith({int? from, int? to, double? percent, double? secondPercent}) =>
      ChildBand(from: from ?? this.from, to: to ?? this.to, percent: percent ?? this.percent, secondPercent: secondPercent ?? this.secondPercent);
}

/// A hotel's «سياسة الأطفال»: who is an adult, from which age a child takes a place in the room, what each age pays, and whether a
/// child's meals follow the same percentage.
class ChildPolicy {
  final int adultFromAge;
  final int countsFromAge;
  final bool mealsFollow;
  final List<ChildBand> bands;

  /// «سرير إضافي»: its price a night — null when the hotel sells none (a stay over the capacity is then refused)
  final double? extraBedPrice;
  final int extraBedsMax;

  /// «بالغ واحد مع طفل»: what the child in the second adult's place of a one-adult room pays of one person's night (0 = free) —
  /// null when the hotel keeps the normal share
  final double? singleParentPercent;

  const ChildPolicy({
    this.adultFromAge = 12,
    this.countsFromAge = 6,
    this.mealsFollow = true,
    this.bands = const [],
    this.extraBedPrice,
    this.extraBedsMax = 1,
    this.singleParentPercent,
  });

  /// How many extra beds a stay of [rooms] rooms may take.
  int extraBedsAllowed(int rooms) => extraBedPrice == null ? 0 : extraBedsMax * (rooms < 1 ? 1 : rooms);

  bool isAdult(int age) => age >= adultFromAge;

  /// Does a child of this age take a place in the room's capacity?
  bool counts(int age) => age >= countsFromAge;

  /// The percentage of the night a child of this age pays; an age no band covers pays nothing, an adult is inside the room's price.
  double percentFor(int age, {bool first = true}) {
    if (isAdult(age)) return 0;
    for (final b in bands) {
      if (age >= b.from && age <= b.to) return first ? b.percent : b.secondPercent;
    }
    return 0;
  }

  static ChildPolicy? fromJsonOrNull(Object? json) => json is Map<String, dynamic>
      ? ChildPolicy(
          adultFromAge: (json['adult_from_age'] as num?)?.toInt() ?? 12,
          countsFromAge: (json['counts_from_age'] as num?)?.toInt() ?? 6,
          mealsFollow: json['meals_follow'] as bool? ?? true,
          extraBedPrice: (json['extra_bed_price'] as num?)?.toDouble(),
          extraBedsMax: (json['extra_beds_max'] as num?)?.toInt() ?? 1,
          singleParentPercent: (json['single_parent_percent'] as num?)?.toDouble(),
          bands: [for (final b in json['bands'] as List<dynamic>? ?? const []) ChildBand.fromJson(b as Map<String, dynamic>)],
        )
      : null;

  Map<String, dynamic> toJson() => {
    'adult_from_age': adultFromAge,
    'counts_from_age': countsFromAge,
    'meals_follow': mealsFollow,
    'extra_bed_price': extraBedPrice,
    'extra_beds_max': extraBedsMax,
    'single_parent_percent': singleParentPercent,
    'bands': [for (final b in bands) b.toJson()],
  };
}
