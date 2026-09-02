/// A followed job field (a root category, or one specialty under it) — new
/// vacancies posted there notify the follower live. Mirrors
/// `JobFollowController::index()`'s row shape.
class JobFollow {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final int? categoryChildId;
  final String? categoryChildName;
  final bool isActive;
  final DateTime? lastMatchedAt;

  const JobFollow({
    required this.id,
    this.categoryId,
    this.categoryName,
    this.categoryChildId,
    this.categoryChildName,
    this.isActive = true,
    this.lastMatchedAt,
  });

  String label(String fallback) {
    if (categoryChildName != null && categoryChildName!.isNotEmpty) return categoryChildName!;
    if (categoryName != null && categoryName!.isNotEmpty) return categoryName!;
    return fallback;
  }

  factory JobFollow.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final child = json['category_child'] as Map<String, dynamic>?;
    return JobFollow(
      id: json['id'] as int,
      categoryId: category?['id'] as int?,
      categoryName: category?['name'] as String?,
      categoryChildId: child?['id'] as int?,
      categoryChildName: child?['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastMatchedAt: json['last_matched_at'] != null
          ? DateTime.tryParse(json['last_matched_at'] as String)
          : null,
    );
  }
}
