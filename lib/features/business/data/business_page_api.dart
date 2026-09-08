import '../../../core/network/api_client.dart';
import 'models/business_post.dart';
import 'models/business_profile.dart';
import 'models/menu_section_group.dart';
import 'models/offering_item.dart';

/// One post page: the items plus whether another page exists — read off
/// the Laravel resource collection's `meta.current_page`/`meta.last_page`,
/// since PostController::business returns a bare resource collection, not
/// the `{success, data}` envelope [ApiClient.get] unwraps.
class BusinessPostsPage {
  final List<BusinessPost> items;
  final bool hasMore;

  const BusinessPostsPage({required this.items, required this.hasMore});
}

/// A business's menu, plus how the merchant chose to display it — see
/// MenuDiscoveryController::show()'s `business.menu_display_mode`.
class MenuPageData {
  final List<MenuSectionGroup> sections;
  /// 'list' (the default, a plain row per item) or 'grid' (a photo-first
  /// 2-column card grid) — see BusinessMenuSetting::DISPLAY_MODES.
  final String displayMode;
  const MenuPageData({required this.sections, required this.displayMode});

  bool get isGrid => displayMode == 'grid';
}

/// Everything the public business page (GET /businesses/{id} and its
/// sub-resources) needs. See BusinessPageController, PostController::business,
/// MenuDiscoveryController, BusinessOfferingsController on the backend.
class BusinessPageApi {
  final ApiClient _client;

  const BusinessPageApi(this._client);

  Future<BusinessProfile> profile(int businessId) async {
    final data = await _client.get('/businesses/$businessId');
    return BusinessProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<BusinessPostsPage> posts(int businessId, {int page = 1, int perPage = 15}) async {
    final body = await _client.getForBody(
      '/businesses/$businessId/posts',
      query: {'page': page, 'per_page': perPage},
    );
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((e) => BusinessPost.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    return BusinessPostsPage(items: items, hasMore: currentPage < lastPage);
  }

  Future<MenuPageData> menu(int businessId) async {
    final data = await _client.get('/discovery/menu/$businessId') as Map<String, dynamic>;
    final sections = data['sections'] as List<dynamic>? ?? [];
    final business = data['business'] as Map<String, dynamic>? ?? const {};
    return MenuPageData(
      sections: sections.map((e) => MenuSectionGroup.fromJson(e as Map<String, dynamic>)).toList(),
      displayMode: business['menu_display_mode'] as String? ?? 'list',
    );
  }

  Future<List<OfferingItem>> offerings(int businessId) async {
    final data = await _client.get('/discovery/offerings/$businessId') as Map<String, dynamic>;
    final offerings = data['offerings'] as Map<String, dynamic>? ?? const {};
    final rows = offerings['data'] as List<dynamic>? ?? [];
    return rows.map((e) => OfferingItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /follows — same `follow_user` row PostAudienceService reads to
  /// build the personal feed, so following here is what makes this
  /// business's posts start showing up in that feed.
  Future<void> follow(int businessId) async {
    await _client.post('/follows', data: {'follow_id': businessId});
  }

  Future<void> unfollow(int businessId) async {
    await _client.delete('/follows/$businessId');
  }
}
