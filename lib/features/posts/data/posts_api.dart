import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../business/data/models/business_post.dart';
import 'models/followed_account.dart';
import 'models/job_post.dart';

class PostsPage {
  final List<BusinessPost> items;
  final bool hasMore;
  const PostsPage({required this.items, required this.hasMore});
}

class JobsPage {
  final List<JobPost> items;
  final bool hasMore;
  const JobsPage({required this.items, required this.hasMore});
}

/// GET /posts/mine, POST /posts, POST /jobs — publishing and reading back
/// the caller's own content. GET /posts/mine is a bare Laravel resource
/// collection (no {success,data} envelope), same shape as
/// GET /businesses/{id}/posts, so this reads it the same way
/// (ApiClient.getForBody + meta.current_page/last_page).
class PostsApi {
  final ApiClient _client;
  const PostsApi(this._client);

  Future<PostsPage> mine({int page = 1, int perPage = 15}) =>
      _page('/posts/mine', page, perPage);

  /// The personal feed (GET /posts): every post from an account the caller
  /// follows, or whose category the caller belongs to/follows — see
  /// PostAudienceService::authorIdsFor. Same follow relationship
  /// FollowApi.follow()/unfollow() writes to.
  Future<PostsPage> feed({int page = 1, int perPage = 15}) =>
      _page('/posts', page, perPage);

  Future<PostsPage> _page(String path, int page, int perPage) async {
    final body = await _client.getForBody(
      path,
      query: {'page': page, 'per_page': perPage},
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => BusinessPost.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return PostsPage(items: items, hasMore: currentPage < lastPage);
  }

  /// GET /jobs/mine — this business's own vacancies, any status. Unlike
  /// [_page], the envelope here is a raw paginator under `data`
  /// (JobController::mine has no Resource, just response()->json(['data' =>
  /// $paginator])), so pagination fields sit at the top of `data` itself,
  /// not under a nested `meta`.
  Future<JobsPage> mineJobs({int page = 1, int perPage = 20}) async {
    final data =
        await _client.get(
              '/jobs/mine',
              query: {'page': page, 'per_page': perPage},
            )
            as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>? ?? [])
        .map((e) => JobPost.fromJson(e as Map<String, dynamic>))
        .toList();
    final currentPage = (data['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (data['last_page'] as num?)?.toInt() ?? 1;
    return JobsPage(items: items, hasMore: currentPage < lastPage);
  }

  /// POST /posts/{id}/react — like (1) or clear (0). Dislike (-1) has no UI
  /// yet; the feed only ever shows a heart.
  Future<void> react(int postId, int reaction) async {
    await _client.post('/posts/$postId/react', data: {'reaction': reaction});
  }

  Future<void> deletePost(int postId) async {
    await _client.delete('/posts/$postId');
  }

  Future<void> createPost({
    String? title,
    required String body,
    List<Uint8List> images = const [],
  }) async {
    await _client.post(
      '/posts',
      data: FormData.fromMap({
        if (title != null && title.isNotEmpty) 'title': title,
        'body': body,
        for (var i = 0; i < images.length; i++)
          'images[$i]': MultipartFile.fromBytes(
            images[i],
            filename: 'photo_$i.png',
          ),
      }),
    );
  }

  /// GET /follows — accounts feeding [feed]'s audience. See
  /// BusinessPageApi.follow/unfollow, which write the same relationship
  /// from a business's own page; this is where it's reviewed afterward.
  Future<List<FollowedAccount>> follows() async {
    final data = await _client.get('/follows') as List<dynamic>;
    return data
        .map((e) => FollowedAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> unfollow(int businessId) async {
    await _client.delete('/follows/$businessId');
  }

  Future<void> createJob({
    required int categoryId,
    int? categoryChildId,
    required String title,
    required String body,
    String? requirements,
    String? salary,
  }) async {
    await _client.post(
      '/jobs',
      data: {
        'category_id': categoryId,
        'category_child_id': ?categoryChildId,
        'title': title,
        'body': body,
        if (requirements != null && requirements.isNotEmpty)
          'requirements': requirements,
        if (salary != null && salary.isNotEmpty) 'salary': salary,
      },
    );
  }
}
