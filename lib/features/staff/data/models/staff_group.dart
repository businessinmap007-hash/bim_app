import '../../../../core/env/env.dart';

/// One staff member's card inside a group — mirrors
/// Api\V2\BusinessStaffController::groups()'s per-member payload.
class StaffGroupMember {
  final int userId;
  final String name;
  final String? phone;
  final String? logoUrl;
  final String? title;
  final bool isActive;
  final int operationsToday;
  final bool isPresent;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final bool isDriver;
  final bool driverBusy;
  final int activeOrderCount;

  const StaffGroupMember({
    required this.userId,
    required this.name,
    this.phone,
    this.logoUrl,
    this.title,
    required this.isActive,
    required this.operationsToday,
    required this.isPresent,
    this.checkedInAt,
    this.checkedOutAt,
    required this.isDriver,
    required this.driverBusy,
    required this.activeOrderCount,
  });

  factory StaffGroupMember.fromJson(Map<String, dynamic> json) {
    final attendance = json['attendance'] as Map<String, dynamic>? ?? const {};
    final deliveryStatus = json['delivery_status'] as Map<String, dynamic>?;

    return StaffGroupMember(
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      logoUrl: Env.assetUrl(json['logo'] as String?),
      title: json['title'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      operationsToday: json['operations_today'] as int? ?? 0,
      isPresent: attendance['is_present'] as bool? ?? false,
      checkedInAt: attendance['checked_in_at'] != null
          ? DateTime.tryParse(attendance['checked_in_at'] as String)
          : null,
      checkedOutAt: attendance['checked_out_at'] != null
          ? DateTime.tryParse(attendance['checked_out_at'] as String)
          : null,
      isDriver: deliveryStatus != null,
      driverBusy: deliveryStatus?['busy'] as bool? ?? false,
      activeOrderCount: deliveryStatus?['active_order_count'] as int? ?? 0,
    );
  }
}

/// One capability group ("المنيو", "مناديب التوصيل", ...) and who is in it —
/// a staff member with several capabilities appears once per group.
class StaffGroup {
  final String capability;
  final String nameAr;
  final String nameEn;
  final List<StaffGroupMember> members;

  const StaffGroup({
    required this.capability,
    required this.nameAr,
    required this.nameEn,
    required this.members,
  });

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  factory StaffGroup.fromJson(Map<String, dynamic> json) => StaffGroup(
    capability: json['capability'] as String? ?? '',
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
    members: (json['staff'] as List<dynamic>? ?? [])
        .map((e) => StaffGroupMember.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
