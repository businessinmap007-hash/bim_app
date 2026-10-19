import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import '../../../core/time/egypt_time.dart';
import '../../media/data/picked_media.dart';

/// One choice of a `select` field.
class OwnerOption {
  final String value;
  final String label;
  const OwnerOption({required this.value, required this.label});

  factory OwnerOption.fromJson(Map<String, dynamic> json) => OwnerOption(
    value: '${json['value']}',
    label: json['label'] as String? ?? '',
  );
}

/// One thing a category asks about the item (the make of a car, the area of a flat…).
class OwnerField {
  final String key;

  /// `text` | `int` | `select`
  final String type;
  final String label;
  final bool required;
  final int? min;
  final int? max;

  /// The deals it applies to (null = every deal): the mileage of a rented car is not asked.
  final List<String>? deals;
  final List<OwnerOption> options;

  const OwnerField({
    required this.key,
    required this.type,
    required this.label,
    required this.required,
    this.min,
    this.max,
    this.deals,
    this.options = const [],
  });

  bool appliesTo(String deal) => deals == null || deals!.contains(deal);

  factory OwnerField.fromJson(Map<String, dynamic> json) => OwnerField(
    key: json['key'] as String,
    type: json['type'] as String? ?? 'text',
    label: json['label'] as String? ?? '',
    required: json['required'] as bool? ?? false,
    min: (json['min'] as num?)?.toInt(),
    max: (json['max'] as num?)?.toInt(),
    deals: (json['deals'] as List<dynamic>?)?.map((e) => e as String).toList(),
    options: (json['options'] as List<dynamic>? ?? const [])
        .map((e) => OwnerOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class OwnerCategory {
  final String key;
  final String name;
  final String icon;
  final List<String> deals;
  final List<OwnerField> fields;

  const OwnerCategory({
    required this.key,
    required this.name,
    required this.icon,
    required this.deals,
    required this.fields,
  });

  factory OwnerCategory.fromJson(Map<String, dynamic> json) => OwnerCategory(
    key: json['key'] as String,
    name: json['name'] as String? ?? '',
    icon: json['icon'] as String? ?? 'category',
    deals: (json['deals'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(),
    fields: (json['fields'] as List<dynamic>? ?? const [])
        .map((e) => OwnerField.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class OwnerImage {
  final int id;
  final String image;
  const OwnerImage({required this.id, required this.image});

  factory OwnerImage.fromJson(Map<String, dynamic> json) => OwnerImage(
    id: (json['id'] as num).toInt(),
    image: json['image'] as String? ?? '',
  );
}

/// A listing as a card of the list (and the base of the full page).
class OwnerListing {
  final int id;
  final String categoryKey;
  final String categoryName;
  final String deal;
  final String title;
  final double? price;
  final String? priceUnit;
  final String currency;
  final String? governorate;
  final String? city;

  /// The place's ids, to put it back into the location picker when editing.
  final int countryId;
  final int governorateId;
  final int? cityId;
  final String? cover;
  final int imagesCount;

  /// `active` | `flagged` | `done` | `expired`
  final String status;
  final bool mine;
  final DateTime? expiresAt;
  final DateTime? purgeAt;

  // the full page only
  final String? description;
  final List<({String label, String value})> attributes;
  final Map<String, dynamic> rawAttributes;
  final List<OwnerImage> images;
  final int? ownerId;
  final String? ownerName;
  final int? myInquiryId;
  final int? inquiriesCount;

  const OwnerListing({
    required this.id,
    required this.categoryKey,
    required this.categoryName,
    required this.deal,
    required this.title,
    required this.currency,
    required this.imagesCount,
    required this.status,
    required this.mine,
    this.countryId = 0,
    this.governorateId = 0,
    this.cityId,
    this.price,
    this.priceUnit,
    this.governorate,
    this.city,
    this.cover,
    this.expiresAt,
    this.purgeAt,
    this.description,
    this.attributes = const [],
    this.rawAttributes = const {},
    this.images = const [],
    this.ownerId,
    this.ownerName,
    this.myInquiryId,
    this.inquiriesCount,
  });

  bool get isLive => status == 'active';
  bool get isFinished => status == 'done' || status == 'expired';
  String get place => [
    city,
    governorate,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

  factory OwnerListing.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>? ?? const {};
    final owner = json['owner'] as Map<String, dynamic>?;
    return OwnerListing(
      id: (json['id'] as num).toInt(),
      categoryKey: category['key'] as String? ?? '',
      categoryName: category['name'] as String? ?? '',
      deal: json['deal'] as String? ?? 'sale',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      priceUnit: json['price_unit'] as String?,
      currency: json['currency'] as String? ?? 'EGP',
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      countryId:
          ((json['place'] as Map<String, dynamic>?)?['country_id'] as num?)
              ?.toInt() ??
          0,
      governorateId:
          ((json['place'] as Map<String, dynamic>?)?['governorate_id'] as num?)
              ?.toInt() ??
          0,
      cityId: ((json['place'] as Map<String, dynamic>?)?['city_id'] as num?)
          ?.toInt(),
      cover: json['cover'] as String?,
      imagesCount: (json['images_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
      mine: json['mine'] as bool? ?? false,
      expiresAt: EgyptTime.tryParse(json['expires_at'] as String?),
      purgeAt: EgyptTime.tryParse(json['purge_at'] as String?),
      description: json['description'] as String?,
      attributes: (json['attributes'] as List<dynamic>? ?? const [])
          .map(
            (e) => (
              label: (e as Map<String, dynamic>)['label'] as String? ?? '',
              value: e['value'] as String? ?? '',
            ),
          )
          .toList(),
      rawAttributes: json['raw_attributes'] is Map<String, dynamic>
          ? json['raw_attributes'] as Map<String, dynamic>
          : const {},
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((e) => OwnerImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      ownerId: (owner?['id'] as num?)?.toInt(),
      ownerName: owner?['name'] as String?,
      myInquiryId: (json['my_inquiry_id'] as num?)?.toInt(),
      inquiriesCount: (json['inquiries_count'] as num?)?.toInt(),
    );
  }
}

/// A buyer's conversation about a listing, with the state of the swap of phone numbers.
class OwnerInquiry {
  final int id;

  /// `open` | `reveal_requested` | `revealed`
  final String status;
  final bool isBuyer;
  final int? listingId;
  final String listingTitle;
  final double? listingPrice;
  final String? listingStatus;
  final String? listingCover;
  final int otherId;
  final String otherName;
  final bool requestedByMe;
  final bool requestedByOther;
  final double feeTotal;
  final double myShare;

  /// The other side's number — only once both said yes and the fee was paid.
  final String? otherPhone;

  const OwnerInquiry({
    required this.id,
    required this.status,
    required this.isBuyer,
    required this.listingTitle,
    required this.otherId,
    required this.otherName,
    required this.requestedByMe,
    required this.requestedByOther,
    required this.feeTotal,
    required this.myShare,
    this.listingId,
    this.listingPrice,
    this.listingStatus,
    this.listingCover,
    this.otherPhone,
  });

  bool get revealed => status == 'revealed';

  factory OwnerInquiry.fromJson(Map<String, dynamic> json) {
    final listing = json['listing'] as Map<String, dynamic>?;
    final other = json['other'] as Map<String, dynamic>? ?? const {};
    final reveal = json['reveal'] as Map<String, dynamic>? ?? const {};
    return OwnerInquiry(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'open',
      isBuyer: json['role'] == 'buyer',
      listingId: (listing?['id'] as num?)?.toInt(),
      listingTitle: listing?['title'] as String? ?? '',
      listingPrice: (listing?['price'] as num?)?.toDouble(),
      listingStatus: listing?['status'] as String?,
      listingCover: listing?['cover'] as String?,
      otherId: (other['id'] as num?)?.toInt() ?? 0,
      otherName: other['name'] as String? ?? '',
      requestedByMe: reveal['requested_by_me'] as bool? ?? false,
      requestedByOther: reveal['requested_by_other'] as bool? ?? false,
      feeTotal: (reveal['fee_total'] as num?)?.toDouble() ?? 0,
      myShare: (reveal['my_share'] as num?)?.toDouble() ?? 0,
      otherPhone: json['other_phone'] as String?,
    );
  }
}

/// What a person narrows the browse by.
class OwnerBrowseQuery {
  final String? category;
  final String? deal;
  final String query;

  const OwnerBrowseQuery({this.category, this.deal, this.query = ''});

  @override
  bool operator ==(Object other) =>
      other is OwnerBrowseQuery &&
      other.category == category &&
      other.deal == deal &&
      other.query == query;

  @override
  int get hashCode => Object.hash(category, deal, query);
}

/// «إعلان من المالك» — see Api\V2\OwnerListingController.
class OwnerListingsApi {
  final ApiClient _client;
  const OwnerListingsApi(this._client);

  Future<List<OwnerCategory>> categories() async {
    final data =
        await _client.get('/owner-listings/categories') as Map<String, dynamic>;
    return (data['categories'] as List<dynamic>? ?? const [])
        .map((e) => OwnerCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<OwnerListing>> browse(OwnerBrowseQuery q) async {
    final data =
        await _client.get(
              '/owner-listings',
              query: {
                if (q.category != null) 'category': q.category,
                if (q.deal != null) 'deal': q.deal,
                if (q.query.trim().isNotEmpty) 'q': q.query.trim(),
                'per_page': 50,
              },
            )
            as Map<String, dynamic>;
    return Paginated.fromJson(data, OwnerListing.fromJson).items;
  }

  Future<List<OwnerListing>> mine() async {
    final data =
        await _client.get('/owner-listings/mine') as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? const [])
        .map((e) => OwnerListing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OwnerListing> show(int id) async {
    final data =
        await _client.get('/owner-listings/$id') as Map<String, dynamic>;
    return OwnerListing.fromJson(data['listing'] as Map<String, dynamic>);
  }

  Map<String, dynamic> _body({
    required String deal,
    required String title,
    String? description,
    double? price,
    String? priceUnit,
    required int governorateId,
    int? cityId,
    required Map<String, dynamic> attributes,
  }) => {
    'deal': deal,
    'title': title.trim(),
    'description': description?.trim() ?? '',
    'price': ?price,
    if (deal == 'rent' && priceUnit != null) 'price_unit': priceUnit,
    'governorate_id': governorateId,
    'city_id': ?cityId,
    'attributes': attributes,
  };

  Future<OwnerListing> create({
    required String category,
    required String deal,
    required String title,
    String? description,
    double? price,
    String? priceUnit,
    required int governorateId,
    int? cityId,
    required Map<String, dynamic> attributes,
  }) async {
    final data =
        await _client.post(
              '/owner-listings',
              data: {
                'category': category,
                ..._body(
                  deal: deal,
                  title: title,
                  description: description,
                  price: price,
                  priceUnit: priceUnit,
                  governorateId: governorateId,
                  cityId: cityId,
                  attributes: attributes,
                ),
              },
            )
            as Map<String, dynamic>;
    return OwnerListing.fromJson(data['listing'] as Map<String, dynamic>);
  }

  Future<OwnerListing> update(
    int id, {
    required String deal,
    required String title,
    String? description,
    double? price,
    String? priceUnit,
    required int governorateId,
    int? cityId,
    required Map<String, dynamic> attributes,
  }) async {
    final data =
        await _client.put(
              '/owner-listings/$id',
              data: _body(
                deal: deal,
                title: title,
                description: description,
                price: price,
                priceUnit: priceUnit,
                governorateId: governorateId,
                cityId: cityId,
                attributes: attributes,
              ),
            )
            as Map<String, dynamic>;
    return OwnerListing.fromJson(data['listing'] as Map<String, dynamic>);
  }

  Future<void> uploadImages(int id, List<PickedMedia> photos) async {
    if (photos.isEmpty) return;
    final form = FormData();
    for (var i = 0; i < photos.length; i++) {
      final bytes =
          photos[i].processedBytes ?? await photos[i].file.readAsBytes();
      form.files.add(
        MapEntry(
          'images[$i]',
          MultipartFile.fromBytes(bytes, filename: photos[i].file.name),
        ),
      );
    }
    await _client.post('/owner-listings/$id/images', data: form);
  }

  Future<void> deleteImage(int id, int imageId) =>
      _client.delete('/owner-listings/$id/images/$imageId');

  Future<OwnerListing> finish(int id, String reason) async {
    final data =
        await _client.post(
              '/owner-listings/$id/finish',
              data: {'reason': reason},
            )
            as Map<String, dynamic>;
    return OwnerListing.fromJson(data['listing'] as Map<String, dynamic>);
  }

  Future<OwnerListing> renew(int id) async {
    final data =
        await _client.post('/owner-listings/$id/renew') as Map<String, dynamic>;
    return OwnerListing.fromJson(data['listing'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/owner-listings/$id');

  Future<void> report(int id) => _client.post('/owner-listings/$id/report');

  Future<OwnerInquiry> inquire(int id) async {
    final data =
        await _client.post('/owner-listings/$id/inquiries')
            as Map<String, dynamic>;
    return OwnerInquiry.fromJson(data['inquiry'] as Map<String, dynamic>);
  }

  Future<List<OwnerInquiry>> inquiries() async {
    final data =
        await _client.get('/owner-listing-inquiries') as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? const [])
        .map((e) => OwnerInquiry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OwnerInquiry> inquiry(int id) async {
    final data =
        await _client.get('/owner-listing-inquiries/$id')
            as Map<String, dynamic>;
    return OwnerInquiry.fromJson(data['inquiry'] as Map<String, dynamic>);
  }

  Future<OwnerInquiry> _reveal(int id, String step) async {
    final data =
        await _client.post('/owner-listing-inquiries/$id/reveal/$step')
            as Map<String, dynamic>;
    return OwnerInquiry.fromJson(data['inquiry'] as Map<String, dynamic>);
  }

  Future<OwnerInquiry> revealRequest(int id) => _reveal(id, 'request');
  Future<OwnerInquiry> revealAccept(int id) => _reveal(id, 'accept');
  Future<OwnerInquiry> revealCancel(int id) => _reveal(id, 'cancel');
}
