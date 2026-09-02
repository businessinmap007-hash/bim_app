import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../posts/data/models/job_post.dart';
import 'models/job_category.dart';
import 'models/job_follow.dart';

/// /jobs, /jobs/follows — the job-seeker's side of Api\V2\JobController +
/// JobFollowController. Posting a vacancy (store), seeing who applied
/// (applicants/approve), and closing a job are the posting BUSINESS's own
/// actions (already wired via PostsApi.createJob/mineJobs) — out of scope
/// here, same as everywhere else this session draws the customer/business
/// line.
class JobsApi {
  final ApiClient _client;
  const JobsApi(this._client);

  Future<Paginated<JobPost>> browse({String? q, int? categoryId, int? categoryChildId, int page = 1}) async {
    final data = await _client.get(
      '/jobs',
      query: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (categoryId != null) 'category_id': categoryId,
        if (categoryChildId != null) 'category_child_id': categoryChildId,
        'page': page,
      },
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, JobPost.fromJson);
  }

  Future<JobPost> show(int id) async {
    final data = await _client.get('/jobs/$id') as Map<String, dynamic>;
    return JobPost.fromJson(data);
  }

  Future<List<JobCategoryGroup>> categories() async {
    final data = await _client.get('/jobs/categories') as List<dynamic>;
    return data.map((e) => JobCategoryGroup.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns the application's created-at timestamp on success.
  Future<DateTime?> apply(int jobId) async {
    final data = await _client.post('/jobs/$jobId/apply') as Map<String, dynamic>;
    final appliedAt = data['applied_at'] as String?;
    return appliedAt != null ? DateTime.tryParse(appliedAt) : null;
  }

  Future<Paginated<JobFollow>> follows({int page = 1}) async {
    final data = await _client.get('/jobs/follows', query: {'page': page}) as Map<String, dynamic>;
    return Paginated.fromJson(data, JobFollow.fromJson);
  }

  Future<void> follow({int? categoryId, int? categoryChildId}) async {
    await _client.post(
      '/jobs/follows',
      data: {
        if (categoryId != null) 'category_id': categoryId,
        if (categoryChildId != null) 'category_child_id': categoryChildId,
      },
    );
  }

  Future<void> unfollow(int followId) async {
    await _client.delete('/jobs/follows/$followId');
  }
}
