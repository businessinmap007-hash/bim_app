import '../../../../core/env/env.dart';

/// The business's request to show a project as a post, and the customer's answer — mirrors `ProjectShowcaseService::block()`.
class ShowcaseRequest {
  final int id;

  /// requested | approved | declined | withdrawn
  final String status;
  final String publicTitle;
  final String? note;
  final bool showPhotos;
  final String? decisionNote;

  const ShowcaseRequest({required this.id, required this.status, required this.publicTitle, this.note, this.showPhotos = false, this.decisionNote});

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
