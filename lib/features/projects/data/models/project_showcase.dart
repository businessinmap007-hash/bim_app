import '../../../../core/env/env.dart';

/// One stage (or month) the customer is asked about in the stage-by-stage mode.
class ShowcaseUnit {
  /// The main stage's id, or the month «2026-10».
  final String key;
  final String? title;

  /// pending | approved | declined
  final String status;

  const ShowcaseUnit({required this.key, this.title, required this.status});

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
}

/// The business's request to show a project as a post, and the customer's answer — mirrors `ProjectShowcaseService::block()`.
class ShowcaseRequest {
  final int id;

  /// requested | approved | declined | withdrawn
  final String status;
  final String publicTitle;
  final String? note;
  final bool showPhotos;
  final String? decisionNote;

  /// For a plan: training | nutrition | combined.
  final String? kind;

  /// `once` (one approval covers every stage) or `each` (he approves each stage / month).
  final String consentMode;
  final List<ShowcaseUnit> units;

  const ShowcaseRequest({required this.id, required this.status, required this.publicTitle, this.note, this.showPhotos = false, this.decisionNote, this.kind, this.consentMode = 'once', this.units = const []});

  bool get isEach => consentMode == 'each';
  bool get isRequested => status == 'requested';
  bool get isLive => status == 'approved';

  /// May the business ask (again)? Not while one is waiting or live.
  bool get canAsk => !isRequested && !isLive;

  static ShowcaseRequest? fromJsonOrNull(Object? json) => json is Map<String, dynamic>
      ? ShowcaseRequest(
          id: (json['id'] as num).toInt(),
          status: json['status'] as String? ?? 'requested',
          publicTitle: json['public_title'] as String? ?? '',
          note: json['note'] as String?,
          showPhotos: json['show_photos'] as bool? ?? false,
          decisionNote: json['decision_note'] as String?,
          kind: json['kind'] as String?,
          consentMode: json['consent_mode'] as String? ?? 'once',
          units: [
            for (final u in (json['units'] as List<dynamic>? ?? const []))
              ShowcaseUnit(key: '${(u as Map<String, dynamic>)['key']}', title: u['title'] as String?, status: u['status'] as String? ?? 'pending'),
          ],
        )
      : null;
}

/// One main stage as the public reads it: only what the customer confirmed, with the date of his latest approval inside it.
class ShowcaseStage {
  final String title;
  final int progress;
  final int works;
  final int worksConfirmed;
  final String? confirmedOn;

  const ShowcaseStage({required this.title, required this.progress, required this.works, required this.worksConfirmed, this.confirmedOn});

  factory ShowcaseStage.fromJson(Map<String, dynamic> json) => ShowcaseStage(
    title: json['title'] as String? ?? '',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    works: (json['works'] as num?)?.toInt() ?? 0,
    worksConfirmed: (json['works_confirmed'] as num?)?.toInt() ?? 0,
    confirmedOn: json['confirmed_on'] as String?,
  );
}

class ShowcasePhoto {
  final String url;
  final String stage;
  final String? on;

  const ShowcasePhoto({required this.url, required this.stage, this.on});
}

/// The live, anonymous results a post carries (`showcase` on PostResource): no name, address, floor or unit.
class PostShowcase {
  final int progress;
  final List<ShowcaseStage> stages;
  final List<ShowcasePhoto> photos;
  final String? updatedOn;

  const PostShowcase({required this.progress, required this.stages, required this.photos, this.updatedOn});

  static PostShowcase? fromJsonOrNull(Object? json) {
    if (json is! Map<String, dynamic>) return null;

    return PostShowcase(
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      stages: [for (final s in (json['stages'] as List<dynamic>? ?? const [])) ShowcaseStage.fromJson(s as Map<String, dynamic>)],
      photos: [
        for (final p in (json['photos'] as List<dynamic>? ?? const []))
          if (Env.assetUrl((p as Map<String, dynamic>)['url'] as String?) case final url?) ShowcasePhoto(url: url, stage: p['stage'] as String? ?? '', on: p['on'] as String?),
      ],
      updatedOn: json['updated_on'] as String?,
    );
  }
}

/// A month of the programme, as the public reads it: how far each measure moved since the first confirmed reading.
class PlanShowcaseMonth {
  final String month;
  final String? measuredOn;
  final Map<String, double> change;

  const PlanShowcaseMonth({required this.month, this.measuredOn, required this.change});
}

/// The live, anonymous results of a training / nutrition plan (`plan_showcase` on PostResource): changes only — no names, no
/// absolute weights, no photos.
class PlanShowcasePost {
  /// training | nutrition | combined
  final String kind;
  final int? weeks;
  final int confirmedMonths;
  final List<PlanShowcaseMonth> months;
  final Map<String, double> totalChange;
  final String? updatedOn;

  const PlanShowcasePost({required this.kind, this.weeks, required this.confirmedMonths, required this.months, required this.totalChange, this.updatedOn});

  static Map<String, double> _changes(Object? raw) => {
    if (raw is Map<String, dynamic>)
      for (final e in raw.entries)
        if (e.value is num) e.key: (e.value as num).toDouble(),
  };

  static PlanShowcasePost? fromJsonOrNull(Object? json) {
    if (json is! Map<String, dynamic>) return null;

    return PlanShowcasePost(
      kind: json['kind'] as String? ?? 'combined',
      weeks: (json['weeks'] as num?)?.toInt(),
      confirmedMonths: (json['confirmed_months'] as num?)?.toInt() ?? 0,
      months: [
        for (final m in (json['months'] as List<dynamic>? ?? const []))
          PlanShowcaseMonth(month: (m as Map<String, dynamic>)['month'] as String? ?? '', measuredOn: m['measured_on'] as String?, change: _changes(m['change'])),
      ],
      totalChange: _changes(json['total_change']),
      updatedOn: json['updated_on'] as String?,
    );
  }
}
