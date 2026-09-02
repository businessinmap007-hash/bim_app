class ConductSection {
  final String title;
  final List<String> clauses;
  const ConductSection({required this.title, this.clauses = const []});

  factory ConductSection.fromJson(Map<String, dynamic> json) => ConductSection(
    title: json['title'] as String? ?? '',
    clauses: (json['clauses'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
  );
}

/// The dispute room's conduct rules a party must accept before posting —
/// see `ThreadService::conductCharter()`.
class ConductCharter {
  final int version;
  final String title;
  final List<ConductSection> sections;
  final bool accepted;

  const ConductCharter({
    required this.version,
    required this.title,
    this.sections = const [],
    this.accepted = false,
  });

  factory ConductCharter.fromJson(Map<String, dynamic> json) => ConductCharter(
    version: (json['version'] as num?)?.toInt() ?? 1,
    title: json['title'] as String? ?? '',
    sections: (json['sections'] as List<dynamic>? ?? [])
        .map((e) => ConductSection.fromJson(e as Map<String, dynamic>))
        .toList(),
    accepted: json['accepted'] as bool? ?? false,
  );
}
