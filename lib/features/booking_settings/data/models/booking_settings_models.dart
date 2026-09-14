import '../../../../core/env/env.dart';

/// A small id+name pair — a service, a line option, a modifier option.
class NamedOption {
  final int id;
  final String name;
  const NamedOption({required this.id, required this.name});

  factory NamedOption.fromJson(Map<String, dynamic> json) =>
      NamedOption(id: json['id'] as int, name: json['name'] as String? ?? '');
}

/// One vocabulary group as the merchant picks from it — «الغرف»، «إطلالة
/// الوحدة» — grouped for display, same grouping the backend computed.
class VocabularyGroup {
  final String group;
  final List<NamedOption> options;
  const VocabularyGroup({required this.group, required this.options});

  factory VocabularyGroup.fromJson(Map<String, dynamic> json) => VocabularyGroup(
    group: json['group'] as String? ?? '',
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => NamedOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ServiceItemType {
  final String key;
  final String label;
  const ServiceItemType({required this.key, required this.label});

  factory ServiceItemType.fromJson(Map<String, dynamic> json) =>
      ServiceItemType(key: json['key'] as String? ?? '', label: json['label'] as String? ?? '');
}

class BusinessServiceOption {
  final int id;
  final String key;
  final String name;
  final List<ServiceItemType> itemTypes;

  const BusinessServiceOption({required this.id, required this.key, required this.name, required this.itemTypes});

  factory BusinessServiceOption.fromJson(Map<String, dynamic> json) => BusinessServiceOption(
    id: json['id'] as int,
    key: json['key'] as String? ?? '',
    name: json['name'] as String? ?? '',
    itemTypes: (json['item_types'] as List<dynamic>? ?? [])
        .map((e) => ServiceItemType.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// GET /business/prices/options
class PricesOptionsPayload {
  final List<String> chargeModes;
  final List<BusinessServiceOption> services;
  final List<VocabularyGroup> lines;
  final List<VocabularyGroup> modifiers;

  const PricesOptionsPayload({
    required this.chargeModes,
    required this.services,
    required this.lines,
    required this.modifiers,
  });

  factory PricesOptionsPayload.fromJson(Map<String, dynamic> json) => PricesOptionsPayload(
    chargeModes: (json['charge_modes'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    services: (json['services'] as List<dynamic>? ?? [])
        .map((e) => BusinessServiceOption.fromJson(e as Map<String, dynamic>))
        .toList(),
    lines: (json['lines'] as List<dynamic>? ?? []).map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>)).toList(),
    modifiers: (json['modifiers'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// GET /business/bookable-items/options
class BookableItemsOptionsPayload {
  final List<BusinessServiceOption> services;
  final List<VocabularyGroup> lineOptions;

  const BookableItemsOptionsPayload({required this.services, required this.lineOptions});

  factory BookableItemsOptionsPayload.fromJson(Map<String, dynamic> json) => BookableItemsOptionsPayload(
    services: (json['services'] as List<dynamic>? ?? [])
        .map((e) => BusinessServiceOption.fromJson(e as Map<String, dynamic>))
        .toList(),
    lineOptions: (json['line_options'] as List<dynamic>? ?? [])
        .map((e) => VocabularyGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// One of the business's own priced rows — mirrors BusinessServicePriceResource.
class PriceRow {
  final int id;
  final int serviceId;
  final String serviceName;
  final String bookableItemType;
  final NamedOption? lineOption;
  final String label;
  final double price;
  final String chargeMode;
  final double chargeAmount;
  final String currency;
  final bool isActive;

  const PriceRow({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.bookableItemType,
    this.lineOption,
    required this.label,
    required this.price,
    required this.chargeMode,
    required this.chargeAmount,
    required this.currency,
    required this.isActive,
  });

  factory PriceRow.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>? ?? const {};
    final lineOptionJson = json['line_option'] as Map<String, dynamic>?;
    return PriceRow(
      id: json['id'] as int,
      serviceId: (service['id'] as num?)?.toInt() ?? 0,
      serviceName: service['name'] as String? ?? '',
      bookableItemType: json['bookable_item_type'] as String? ?? '',
      lineOption: lineOptionJson != null && lineOptionJson['name'] != null
          ? NamedOption.fromJson(lineOptionJson)
          : null,
      label: json['label'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      chargeMode: json['charge_mode'] as String? ?? 'standard',
      chargeAmount: (json['charge_amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// One photo in a bookable unit's gallery — mirrors HasOwnedImages'
/// imagePayload() shape ({id, image}), `image` a relative path.
class BookableItemImage {
  final int id;
  final String url;
  const BookableItemImage({required this.id, required this.url});

  factory BookableItemImage.fromJson(Map<String, dynamic> json) =>
      BookableItemImage(id: json['id'] as int, url: Env.assetUrl(json['image'] as String?) ?? '');
}

/// One of the business's own bookable units — mirrors BookableItemResource.
class BookableItemRow {
  final int id;
  final int serviceId;
  final String itemType;
  final NamedOption? lineOption;
  final String code;
  final String? title;
  final String? description;
  final String label;
  final List<BookableItemImage> images;
  final int? capacity;
  final int quantity;
  final bool isActive;
  final String status;
  final bool isCurrentlyBooked;

  const BookableItemRow({
    required this.id,
    required this.serviceId,
    required this.itemType,
    this.lineOption,
    required this.code,
    this.title,
    this.description,
    required this.label,
    this.images = const [],
    this.capacity,
    required this.quantity,
    required this.isActive,
    this.status = 'available',
    this.isCurrentlyBooked = false,
  });

  bool get isUnderMaintenance => status == 'maintenance';

  factory BookableItemRow.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>? ?? const {};
    final lineOptionJson = json['line_option'] as Map<String, dynamic>?;
    return BookableItemRow(
      id: json['id'] as int,
      serviceId: (service['id'] as num?)?.toInt() ?? 0,
      itemType: json['item_type'] as String? ?? '',
      lineOption: lineOptionJson != null && lineOptionJson['name'] != null
          ? NamedOption.fromJson(lineOptionJson)
          : null,
      code: json['code'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      label: json['label'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => BookableItemImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      capacity: (json['capacity'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String? ?? 'available',
      isCurrentlyBooked: json['is_currently_booked'] as bool? ?? false,
    );
  }
}

class WorkingDay {
  final int day;
  final bool? isClosed;
  final String? open;
  final String? close;

  const WorkingDay({required this.day, this.isClosed, this.open, this.close});

  WorkingDay copyWith({bool? isClosed, String? open, String? close, bool clearTimes = false}) {
    return WorkingDay(
      day: day,
      isClosed: isClosed ?? this.isClosed,
      open: clearTimes ? null : (open ?? this.open),
      close: clearTimes ? null : (close ?? this.close),
    );
  }

  factory WorkingDay.fromJson(Map<String, dynamic> json) => WorkingDay(
    day: json['day'] as int,
    isClosed: json['is_closed'] as bool?,
    open: json['open'] as String?,
    close: json['close'] as String?,
  );
}

class WorkingHours {
  final bool isOpenNow;
  final List<WorkingDay> days;
  const WorkingHours({required this.isOpenNow, required this.days});

  factory WorkingHours.fromJson(Map<String, dynamic> json) => WorkingHours(
    isOpenNow: json['is_open_now'] as bool? ?? false,
    days: (json['days'] as List<dynamic>? ?? []).map((e) => WorkingDay.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

/// A stay's own check-in/check-out clock — "HH:mm" (or null, unset).
class CheckTimes {
  final String? checkInTime;
  final String? checkOutTime;
  const CheckTimes({this.checkInTime, this.checkOutTime});

  /// The API returns "HH:mm:ss"; the picker only wants "HH:mm".
  static String? _trimSeconds(String? value) => value?.substring(0, 5);

  factory CheckTimes.fromJson(Map<String, dynamic> json) => CheckTimes(
    checkInTime: _trimSeconds(json['check_in_time'] as String?),
    checkOutTime: _trimSeconds(json['check_out_time'] as String?),
  );
}
