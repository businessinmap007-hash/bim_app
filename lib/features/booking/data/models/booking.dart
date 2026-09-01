/// Mirrors the `bookings` table as returned by `Api\V2\BookingController`
/// (a plain Eloquent model, not a Resource — every fillable column comes
/// through as-is, `price` as a decimal-cast string).
class Booking {
  final int id;
  final String status;
  final double price;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool allDay;
  final String? notes;
  final String? businessName;

  const Booking({
    required this.id,
    required this.status,
    required this.price,
    this.startsAt,
    this.endsAt,
    required this.allDay,
    this.notes,
    this.businessName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    return Booking(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      price: double.tryParse('${json['price']}') ?? 0,
      startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
      allDay: json['all_day'] as bool? ?? false,
      notes: json['notes'] as String?,
      businessName: business?['name'] as String?,
    );
  }
}
