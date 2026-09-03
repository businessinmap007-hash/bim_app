import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/my_rating.dart';
import 'models/operation_review.dart';

/// /ratings — see Api\V2\RatingController.
class RatingsApi {
  final ApiClient _client;
  const RatingsApi(this._client);

  Future<MyRating> me() async {
    final data = await _client.get('/ratings/me') as Map<String, dynamic>;
    return MyRating.fromJson(data);
  }

  /// Opens the caller's own rating, which also makes THEM liable for
  /// service fees on their own operations from now on (never the
  /// counterparty).
  Future<void> enable() async {
    await _client.post('/ratings/enable');
  }

  /// Closes it again — the exact reverse: stops new fee liability and hides
  /// the operation record/reviews again, same as before ever opening it.
  Future<void> disable() async {
    await _client.post('/ratings/disable');
  }

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
