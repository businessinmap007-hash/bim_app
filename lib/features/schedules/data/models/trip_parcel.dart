import '../../../../core/time/egypt_time.dart';

/// A parcel (شحنة) riding with the car — mirrors `TripParcelController::serialize()`.
///
/// The sender describes it, the DRIVER prices it (and says whether it takes a seat), the sender accepts, and the
/// handover needs the delivery code the sender generated: the carrier's own view never carries it.
class TripParcel {
  static const requested = 'requested';
  static const priced = 'priced';
  static const accepted = 'accepted';
  static const loaded = 'loaded';
  static const delivered = 'delivered';
  static const rejected = 'rejected';
  static const cancelled = 'cancelled';

  /// Still on the car when the run ended: not handed over.
  static const returned = 'returned';

  final int id;
  final int tripScheduleId;
  final int businessId;
  final String? businessName;
  final int senderId;
  final String? senderName;
  final int? receiverUserId;
  final String? receiverName;
  final String? receiverPhone;
  final String description;
  final double? price;
  final int seats;
  final String currency;
  final String status;

  /// `sender` pays the driver in cash at pickup, `receiver` at delivery — recorded only (the wallet is not used).
  final String payer;
  final DateTime? paidAt;

  /// The ONE code of the parcel, as the sender (or an account receiver) sees it: `pickup` while it waits for the driver
  /// to take it, then `delivery`. Never carried for the carrier.
  final String? handoverCode;
  final String? handoverKind;

  /// Approximate (the driver's word); the actual hour is [deliveredAt].
  final DateTime? expectedArrivalAt;
  final DateTime? pickedUpAt;

  final DateTime? deliveredAt;

  const TripParcel({
    required this.id,
    required this.tripScheduleId,
    required this.businessId,
    this.businessName,
    required this.senderId,
    this.senderName,
    this.receiverUserId,
    this.receiverName,
    this.receiverPhone,
    required this.description,
    this.price,
    this.seats = 0,
    this.currency = 'EGP',
    required this.status,
    this.payer = 'receiver',
    this.paidAt,
    this.handoverCode,
    this.handoverKind,
    this.expectedArrivalAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  bool get isOpenForSender => status == requested || status == priced || status == accepted;

  /// A service with a price: either side may open a dispute once it is accepted.
  bool get canDispute => status == accepted || status == loaded || status == delivered || status == returned;

  bool get isPaid => paidAt != null;

  factory TripParcel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? const {};
    final receiver = json['receiver'] as Map<String, dynamic>? ?? const {};

    return TripParcel(
      id: (json['id'] as num).toInt(),
      tripScheduleId: (json['trip_schedule_id'] as num?)?.toInt() ?? 0,
      businessId: (json['business_id'] as num?)?.toInt() ?? 0,
      businessName: json['business_name'] as String?,
      senderId: (sender['id'] as num?)?.toInt() ?? 0,
      senderName: sender['name'] as String?,
      receiverUserId: (receiver['user_id'] as num?)?.toInt(),
      receiverName: receiver['name'] as String?,
      receiverPhone: receiver['phone'] as String?,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      status: json['status'] as String? ?? requested,
      payer: json['payer'] as String? ?? 'receiver',
      paidAt: json['paid_at'] != null ? EgyptTime.tryParse(json['paid_at'] as String) : null,
      handoverCode: json['handover_code'] as String?,
      handoverKind: json['handover_kind'] as String?,
      expectedArrivalAt: json['expected_arrival_at'] != null ? EgyptTime.tryParse(json['expected_arrival_at'] as String) : null,
      pickedUpAt: json['picked_up_at'] != null ? EgyptTime.tryParse(json['picked_up_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? EgyptTime.tryParse(json['delivered_at'] as String) : null,
    );
  }
}
