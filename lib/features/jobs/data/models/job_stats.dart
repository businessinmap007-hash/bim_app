/// The four job counters — `GET /jobs/mine/stats` (one business) and
/// `GET /jobs/stats` (whole platform, which also carries `businesses_hiring`).
class JobStats {
  final int jobsPosted;
  final int jobsOpen;
  final int applicantsTotal;
  final int approvedTotal;
  final int businessesHiring;

  const JobStats({
    this.jobsPosted = 0,
    this.jobsOpen = 0,
    this.applicantsTotal = 0,
    this.approvedTotal = 0,
    this.businessesHiring = 0,
  });

  factory JobStats.fromJson(Map<String, dynamic> json) => JobStats(
    jobsPosted: (json['jobs_posted'] as num?)?.toInt() ?? 0,
    jobsOpen: (json['jobs_open'] as num?)?.toInt() ?? 0,
    applicantsTotal: (json['applicants_total'] as num?)?.toInt() ?? 0,
    approvedTotal: (json['approved_total'] as num?)?.toInt() ?? 0,
    businessesHiring: (json['businesses_hiring'] as num?)?.toInt() ?? 0,
  );
}
