import '../../../core/network/api_client.dart';
import 'models/comment.dart';

typedef CommentsPage = ({List<Comment> items, bool hasMore});

/// /posts/{post}/comments, /comments/{comment}/... — see Api\V2\CommentController.
/// Reading is public; writing needs auth. Unlike most endpoints in this app,
/// index()/replies() return a bare Laravel resource collection (no
/// {success,data} envelope, pagination under `meta`), so this reads the raw
/// body instead of going through ApiClient's usual unwrap.
class CommentsApi {
  final ApiClient _client;
  const CommentsApi(this._client);

  Future<CommentsPage> forPost(int postId, {int page = 1}) async {
    final body = await _client.getForBody('/posts/$postId/comments', query: {'page': page});
    return _parsePage(body);
  }

  Future<CommentsPage> replies(int commentId, {int page = 1}) async {
    final body = await _client.getForBody('/comments/$commentId/replies', query: {'page': page});
    return _parsePage(body);
  }

  Future<Comment> add(int postId, String body, {bool private = false}) async {
    final data = await _client.post(
      '/posts/$postId/comments',
      data: {'comment': body, if (private) 'status': 'private'},
    ) as Map<String, dynamic>;
    return Comment.fromJson(data);
  }

  Future<Comment> reply(int commentId, String body) async {
    final data = await _client.post('/comments/$commentId/replies', data: {'comment': body})
        as Map<String, dynamic>;
    return Comment.fromJson(data);
  }

  Future<Comment> update(int commentId, String body) async {
    final data = await _client.put('/comments/$commentId', data: {'comment': body}) as Map<String, dynamic>;
    return Comment.fromJson(data);
  }

  Future<void> delete(int commentId) async {
    await _client.delete('/comments/$commentId');
  }

  CommentsPage _parsePage(Map<String, dynamic> body) {
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return (items: items, hasMore: currentPage < lastPage);
  }
}
