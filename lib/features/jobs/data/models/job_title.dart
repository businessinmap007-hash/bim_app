/// One entry of `GET /jobs/titles` — a job title a business can pick when it
/// posts a vacancy, with how many open jobs currently carry it.
class JobTitle {
  final int id;
  final String name;
  final int jobsCount;

  const JobTitle({required this.id, required this.name, this.jobsCount = 0});

  factory JobTitle.fromJson(Map<String, dynamic> json) => JobTitle(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    jobsCount: (json['jobs_count'] as num?)?.toInt() ?? 0,
  );
}
