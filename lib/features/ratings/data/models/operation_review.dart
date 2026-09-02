import '../../../../core/env/env.dart';

/// The `rater:id,name,type,logo,image` eager load on OperationReview — who
/// left the review.
class ReviewAuthor {
  final int id;
  final String name;
  final String? imageUrl;

  const ReviewAuthor({required this.id, required this.name, this.imageUrl});

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) => ReviewAuthor(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    imageUrl: Env.assetUrl((json['logo'] as String?) ?? (json['image'] as String?)),
  );
}

/// Mirrors `OperationReview` as returned by `RatingController::reviews` — a
/// plain Eloquent model, not a Resource.
class OperationReview {
  final int id;
  final int stars;
  final String? comment;
  final DateTime? createdAt;
  final ReviewAuthor? rater;

  const OperationReview({
    required this.id,
    required this.stars,
    this.comment,
    this.createdAt,
    this.rater,
  });

  factory OperationReview.fromJson(Map<String, dynamic> json) => OperationReview(
    id: json['id'] as int,
    stars: (json['stars'] as num?)?.toInt() ?? 0,
    comment: json['comment'] as String?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    rater: json['rater'] != null ? ReviewAuthor.fromJson(json['rater'] as Map<String, dynamic>) : null,
  );
}
