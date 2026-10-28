/// «العشاء الإلزامي»: a gala night of the hotel — every stay over it pays the dinner: each adult [adultPrice], each child from
/// [childFreeUnder] years [childPercent] of it, a younger child nothing.
class GalaDinner {
  final int id;
  final DateTime date;
  final String name;
  final double adultPrice;
  final double childPercent;
  final int childFreeUnder;

  const GalaDinner({required this.id, required this.date, required this.name, required this.adultPrice, this.childPercent = 50, this.childFreeUnder = 6});

  factory GalaDinner.fromJson(Map<String, dynamic> json) => GalaDinner(
    id: (json['id'] as num?)?.toInt() ?? 0,
    date: DateTime.parse(json['date'] as String),
    name: json['name'] as String? ?? '',
    adultPrice: (json['adult_price'] as num?)?.toDouble() ?? 0,
    childPercent: (json['child_percent'] as num?)?.toDouble() ?? 50,
    childFreeUnder: (json['child_free_under'] as num?)?.toInt() ?? 6,
  );

  /// the date as the server keeps it — a calendar day, never shifted by a timezone
  String get wireDate => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'date': wireDate,
    'name': name,
    'adult_price': adultPrice,
    'child_percent': childPercent,
    'child_free_under': childFreeUnder,
  };

  static List<GalaDinner> listFrom(Object? json) => [
    for (final g in json is List<dynamic> ? json : const []) GalaDinner.fromJson(g as Map<String, dynamic>),
  ];
}
