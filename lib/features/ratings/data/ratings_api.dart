import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/operation_review.dart';

/// /ratings — see Api\V2\RatingController. Only [reviews] and [submitReview]
/// are used by this app; `me`/`enable`/`show` (the operational trust-score
/// surface) aren't wired up yet — this feature is just the subjective star
/// review, the one thing the business page already showed a summary of with
/// nowhere to read or add to it.
class RatingsApi {
  final ApiClient _client;
  const RatingsApi(this._client);

  Future<Paginated<OperationReview>> reviews(int userId, {int page = 1, int perPage = 20}) async {
    final data = await _client.get(
      '/ratings/user/$userId/reviews',
      query: {'page': page, 'per_page': perPage},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data['reviews'] as Map<String, dynamic>, OperationReview.fromJson);
  }

  /// `operationType` is 'booking' | 'order'. Only allowed once that operation
  /// is `completed` and the caller was a party to it (enforced server-side).
  Future<OperationReview> submitReview({
    required String operationType,
    required int operationId,
    required int stars,
    String? comment,
  }) async {
    final data = await _client.post(
      '/ratings/review',
      data: {
        'operation_type': operationType,
        'operation_id': operationId,
        'stars': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    ) as Map<String, dynamic>;
    return OperationReview.fromJson(data['review'] as Map<String, dynamic>);
  }
}
