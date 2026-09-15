import '../../../../core/env/env.dart';

/// A business this account works for as a delegated staff member — mirrors
/// Api\V2\BusinessStaffController::memberships().
class StaffMembership {
  final int businessId;
  final String businessName;
  final String? businessLogoUrl;
  final String? title;
  final List<String> capabilities;

  const StaffMembership({
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
    this.title,
    required this.capabilities,
  });

  factory StaffMembership.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>? ?? const {};
    return StaffMembership(
      businessId: business['id'] as int? ?? 0,
      businessName: business['name'] as String? ?? '',
      businessLogoUrl: Env.assetUrl(business['logo'] as String?),
      title: json['title'] as String?,
      capabilities: (json['capabilities'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    );
  }
}

/// Today's attendance for one membership — mirrors StaffAttendanceController.
class AttendanceStatus {
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final bool isPresent;

  const AttendanceStatus({this.checkedInAt, this.checkedOutAt, required this.isPresent});

  static const empty = AttendanceStatus(isPresent: false);

  factory AttendanceStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return AttendanceStatus(
      checkedInAt: json['checked_in_at'] != null ? DateTime.tryParse(json['checked_in_at'] as String) : null,
      checkedOutAt: json['checked_out_at'] != null ? DateTime.tryParse(json['checked_out_at'] as String) : null,
      isPresent: json['is_present'] as bool? ?? false,
    );
  }
}
