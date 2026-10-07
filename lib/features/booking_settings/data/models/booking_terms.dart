/// How a business secures its bookings — Api\V2\BusinessBookingTermsController, in plain terms.
enum BookingSecurityMode {
  /// A deposit frozen in the wallet of BOTH parties — the preferred way.
  depositFreeze('deposit_freeze'),

  /// The customer's guarantee coverage stands for it.
  guaranteeFreeze('guarantee_freeze'),

  /// Paid by direct transfer outside the app; the business confirms it arrived. The platform carries no responsibility.
  externalTransfer('external_transfer');

  final String wire;
  const BookingSecurityMode(this.wire);

  static BookingSecurityMode fromWire(String? value) =>
      BookingSecurityMode.values.firstWhere((m) => m.wire == value, orElse: () => BookingSecurityMode.depositFreeze);
}

/// What the terms mean for a booking of one day at [bookingValue] — the preview the server computes.
class BookingTermsExample {
  final double bookingValue;
  final double deposit;
  final double customerHold;
  final double businessHold;
  final double externalAmount;
  final double guaranteeRequired;

  const BookingTermsExample({
    required this.bookingValue,
    required this.deposit,
    required this.customerHold,
    required this.businessHold,
    required this.externalAmount,
    required this.guaranteeRequired,
  });

  factory BookingTermsExample.fromJson(Map<String, dynamic> json) => BookingTermsExample(
    bookingValue: (json['booking_value'] as num?)?.toDouble() ?? 0,
    deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
    customerHold: (json['customer_hold'] as num?)?.toDouble() ?? 0,
    businessHold: (json['business_hold'] as num?)?.toDouble() ?? 0,
    externalAmount: (json['external_amount'] as num?)?.toDouble() ?? 0,
    guaranteeRequired: (json['guarantee_required'] as num?)?.toDouble() ?? 0,
  );
}

class BookingTerms {
  final bool enabled;
  final BookingSecurityMode mode;
  final double depositPercent;

  /// `first_day` or `total`.
  final String depositBase;
  final double businessCounterPercent;

  /// 0 = just the deposit; otherwise N times the day's value.
  final double guaranteeMultiple;
  final bool forfeitToBusiness;
  final bool acceptDepositAsPayment;
  final double maxPercent;
  final bool hasSpecificPolicies;
  final BookingTermsExample? example;

  const BookingTerms({
    this.enabled = false,
    this.mode = BookingSecurityMode.depositFreeze,
    this.depositPercent = 20,
    this.depositBase = 'first_day',
    this.businessCounterPercent = 50,
    this.guaranteeMultiple = 0,
    this.forfeitToBusiness = false,
    this.acceptDepositAsPayment = false,
    this.maxPercent = 50,
    this.hasSpecificPolicies = false,
    this.example,
  });

  BookingTerms copyWith({
    bool? enabled,
    BookingSecurityMode? mode,
    double? depositPercent,
    String? depositBase,
    double? businessCounterPercent,
    double? guaranteeMultiple,
    bool? forfeitToBusiness,
    bool? acceptDepositAsPayment,
  }) => BookingTerms(
    enabled: enabled ?? this.enabled,
    mode: mode ?? this.mode,
    depositPercent: depositPercent ?? this.depositPercent,
    depositBase: depositBase ?? this.depositBase,
    businessCounterPercent: businessCounterPercent ?? this.businessCounterPercent,
    guaranteeMultiple: guaranteeMultiple ?? this.guaranteeMultiple,
    forfeitToBusiness: forfeitToBusiness ?? this.forfeitToBusiness,
    acceptDepositAsPayment: acceptDepositAsPayment ?? this.acceptDepositAsPayment,
    maxPercent: maxPercent,
    hasSpecificPolicies: hasSpecificPolicies,
    example: example,
  );

  factory BookingTerms.fromJson(Map<String, dynamic> json) => BookingTerms(
    enabled: json['enabled'] as bool? ?? false,
    mode: BookingSecurityMode.fromWire(json['security_mode'] as String?),
    depositPercent: (json['deposit_percent'] as num?)?.toDouble() ?? 20,
    depositBase: json['deposit_base'] as String? ?? 'first_day',
    businessCounterPercent: (json['business_counter_percent'] as num?)?.toDouble() ?? 50,
    guaranteeMultiple: (json['guarantee_multiple'] as num?)?.toDouble() ?? 0,
    forfeitToBusiness: json['forfeit_to_business'] as bool? ?? false,
    acceptDepositAsPayment: json['accept_deposit_as_payment'] as bool? ?? false,
    maxPercent: (json['max_percent'] as num?)?.toDouble() ?? 50,
    hasSpecificPolicies: json['has_specific_policies'] as bool? ?? false,
    example: json['example'] is Map<String, dynamic> ? BookingTermsExample.fromJson(json['example'] as Map<String, dynamic>) : null,
  );

  /// What these terms mean for a booking of one day at [value] — the same arithmetic the server does, so the screen can
  /// answer while the merchant is still choosing (the server's own answer comes back on save).
  BookingTermsExample previewFor(double value) {
    final deposit = enabled ? double.parse((value * depositPercent / 100).toStringAsFixed(2)) : 0.0;
    final external = mode == BookingSecurityMode.externalTransfer;
    final counter = external ? 0.0 : double.parse((deposit * businessCounterPercent / 100).toStringAsFixed(2));
    final multiple = mode == BookingSecurityMode.guaranteeFreeze ? guaranteeMultiple : 0.0;

    return BookingTermsExample(
      bookingValue: value,
      deposit: deposit,
      customerHold: external ? 0 : deposit,
      businessHold: counter,
      externalAmount: external ? deposit : 0,
      guaranteeRequired: enabled ? (value * multiple > deposit ? value * multiple : deposit) : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'security_mode': mode.wire,
    'deposit_percent': depositPercent,
    'deposit_base': depositBase,
    'business_counter_percent': businessCounterPercent,
    'guarantee_multiple': guaranteeMultiple,
    'forfeit_to_business': forfeitToBusiness,
    'accept_deposit_as_payment': acceptDepositAsPayment,
  };
}
