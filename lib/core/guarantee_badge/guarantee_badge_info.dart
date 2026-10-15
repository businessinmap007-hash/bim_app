/// The guarantee level an account wears beside its name — mirrors one entry of `GET /guarantee-badges`
/// (App\Services\Guarantees\GuaranteeBadgeService). Public on purpose: the other side of a deal sees what level it
/// deals with and what that guarantee covers up to.
class GuaranteeBadgeInfo {
  /// `bronze` · `silver` · `gold` · `platinum` · `diamond` · `elite` · `royal`
  final String code;
  final String nameAr;
  final String nameEn;

  /// The total coverage the guarantee stands for.
  final double coversUpTo;

  /// `client` or `business`
  final String targetType;

  const GuaranteeBadgeInfo({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.coversUpTo,
    this.targetType = 'client',
  });

  String name(bool arabic) => (arabic ? nameAr : nameEn).isNotEmpty ? (arabic ? nameAr : nameEn) : code;

  static GuaranteeBadgeInfo? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final code = json['code'] as String?;
    if (code == null || code.isEmpty) return null;

    return GuaranteeBadgeInfo(
      code: code,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      coversUpTo: (json['covers_up_to'] as num?)?.toDouble() ?? 0,
      targetType: json['target_type'] as String? ?? 'client',
    );
  }
}
