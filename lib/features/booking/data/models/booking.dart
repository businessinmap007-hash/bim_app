import '../../../../core/env/env.dart';

/// Mirrors the `bookings` table as returned by `Api\V2\BookingController`
/// (a plain Eloquent model, not a Resource — every fillable column comes
/// through as-is, `price` as a decimal-cast string). `service` is loaded on
/// every response (see `relations()` on the backend), so `serviceNameAr`/`En`
/// are always available as the display fallback when there's no `offering`
/// to name the booking more specifically (Booking::title()'s full fallback
/// chain isn't replicated client-side — a service name is enough for a list).
class Booking {
  final int id;
  final String status;
  final double price;
  final DateTime? date;
  final String? time;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool allDay;
  final String? notes;
  final int? businessId;
  final String? businessName;
  final String? businessLogoUrl;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.status,
    required this.price,
    this.date,
    this.time,
    this.startsAt,
    this.endsAt,
    required this.allDay,
    this.notes,
    this.businessId,
    this.businessName,
    this.businessLogoUrl,
    this.serviceNameAr,
    this.serviceNameEn,
    this.createdAt,
  });

  bool get isCancellable => status == 'pending' || status == 'accepted';

  String serviceName(String languageCode) {
    final primary = languageCode == 'ar' ? serviceNameAr : serviceNameEn;
    if (primary != null && primary.isNotEmpty) return primary;
    return serviceNameAr ?? serviceNameEn ?? '';
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;
    return Booking(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      price: double.tryParse('${json['price']}') ?? 0,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
      time: json['time'] as String?,
      startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
      allDay: json['all_day'] as bool? ?? false,
      notes: json['notes'] as String?,
      businessId: business?['id'] as int?,
      businessName: business?['name'] as String?,
      businessLogoUrl: Env.assetUrl(business?['logo'] as String?),
      serviceNameAr: service?['name_ar'] as String?,
      serviceNameEn: service?['name_en'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}
