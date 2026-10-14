/// «المسؤول» — the staff member of a business who is responsible for one piece of work (a booking, an order…) and the
/// people a business may choose from. One shape for every business; the title is the person's own at THAT business
/// («حلاق أول», «استشاري باطنة»).
class Assignee {
  final int id;
  final String name;
  final String? title;
  final String? logoUrl;

  const Assignee({required this.id, required this.name, this.title, this.logoUrl});

  factory Assignee.fromJson(Map<String, dynamic> json) => Assignee(
    id: (json['id'] as num).toInt(),
    name: (json['name'] as String?) ?? '',
    title: (json['title'] as String?)?.trim().isEmpty ?? true ? null : (json['title'] as String).trim(),
    logoUrl: json['logo'] as String?,
  );

  /// «أحمد — حلاق أول», or just the name.
  String get line => title == null ? name : '$name — $title';

  @override
  bool operator ==(Object other) => other is Assignee && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
