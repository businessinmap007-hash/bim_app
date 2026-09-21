import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../posts/data/models/job_post.dart';
import 'models/job_category.dart';
import 'models/job_follow.dart';
import 'models/job_stats.dart';
import 'models/job_title.dart';

/// /jobs, /jobs/follows — the job-seeker's side of Api\V2\JobController +
/// JobFollowController. Posting a vacancy (store), seeing who applied
/// (applicants/approve), and closing a job are the posting BUSINESS's own
/// actions (already wired via PostsApi.createJob/mineJobs) — out of scope
/// here, same as everywhere else this session draws the customer/business
/// line.
class JobsApi {
  final ApiClient _client;
  const JobsApi(this._client);

  Future<Paginated<JobPost>> browse({
    String? q,
    int? categoryId,
    int? categoryChildId,
    int? jobTitleId,
    int page = 1,
  }) async {
    final data =
        await _client.get(
              '/jobs',
              query: {
                if (q != null && q.isNotEmpty) 'q': q,
                'category_id': ?categoryId,
                'category_child_id': ?categoryChildId,
                'job_title_id': ?jobTitleId,
                'page': page,
              },
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, JobPost.fromJson);
  }

  Future<JobPost> show(int id) async {
    final data = await _client.get('/jobs/$id') as Map<String, dynamic>;
    return JobPost.fromJson(data);
  }

  Future<List<JobCategoryGroup>> categories() async {
    final data = await _client.get('/jobs/categories') as List<dynamic>;
    return data
        .map((e) => JobCategoryGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /jobs/mine/stats — the signed-in business's own counters.
  Future<JobStats> myStats() async =>
      JobStats.fromJson(await _client.get('/jobs/mine/stats') as Map<String, dynamic>);

  /// GET /jobs/stats — public platform-wide counters (aggregates only).
  Future<JobStats> platformStats() async =>
      JobStats.fromJson(await _client.get('/jobs/stats') as Map<String, dynamic>);

  /// The closed title list for a field: its own + its root's + the general ones.
  Future<List<JobTitle>> titles({int? categoryId, int? categoryChildId}) async {
    final data =
        await _client.get(
              '/jobs/titles',
              query: {'category_id': ?categoryId, 'category_child_id': ?categoryChildId},
            )
            as List<dynamic>;
    return data.map((e) => JobTitle.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns the application's created-at timestamp on success.
  Future<DateTime?> apply(int jobId) async {
    final data =
        await _client.post('/jobs/$jobId/apply') as Map<String, dynamic>;
    final appliedAt = data['applied_at'] as String?;
    return appliedAt != null ? DateTime.tryParse(appliedAt) : null;
  }

  Future<Paginated<JobFollow>> follows({int page = 1}) async {
    final data =
        await _client.get('/jobs/follows', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, JobFollow.fromJson);
  }

  Future<void> follow({int? categoryId, int? categoryChildId}) async {
    await _client.post(
      '/jobs/follows',
      data: {'category_id': ?categoryId, 'category_child_id': ?categoryChildId},
    );
  }

  Future<void> unfollow(int followId) async {
    await _client.delete('/jobs/follows/$followId');
  }
}
