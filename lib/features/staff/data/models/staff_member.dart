import '../../../../core/env/env.dart';

/// One capability a business can delegate — mirrors BusinessCapability's
/// catalog entries.
class CapabilityOption {
  final String key;
  final String nameAr;
  final String nameEn;

  const CapabilityOption({required this.key, required this.nameAr, required this.nameEn});

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  factory CapabilityOption.fromJson(Map<String, dynamic> json) => CapabilityOption(
    key: json['key'] as String? ?? '',
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
  );
}

/// Mirrors BusinessStaff's status column — a fresh or re-sent grant is
/// `pending` until the invited person accepts it themselves; declining
/// leaves it on record but permanently inactive.
class StaffStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const declined = 'declined';
}

/// Mirrors `BusinessStaffController::serialize()` — one delegated staff
/// member and what they're allowed to do on the business's behalf.
class StaffMember {
  final int userId;
  final String name;
  final String? phone;
  final String? logoUrl;
  final String? title;
  final List<String> capabilities;
  final bool isActive;
  final String status;

  const StaffMember({
    required this.userId,
    required this.name,
    this.phone,
    this.logoUrl,
    this.title,
    required this.capabilities,
    required this.isActive,
    this.status = StaffStatus.accepted,
  });

  bool get isPending => status == StaffStatus.pending;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return StaffMember(
      userId: user['id'] as int? ?? 0,
      name: user['name'] as String? ?? '',
      phone: user['phone'] as String?,
      logoUrl: Env.assetUrl(user['logo'] as String?),
      title: json['title'] as String?,
      capabilities: (json['capabilities'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String? ?? StaffStatus.accepted,
    );
  }
}

/// GET /staff/invitations — a grant I (the invited person) haven't answered
/// yet. Carries the INVITING BUSINESS's own info (not mine — I already know
/// my own details), for the "who's inviting me" card.
class StaffInvitation {
  final int businessId;
  final String businessName;
  final String? businessPhone;
  final String? businessLogoUrl;
  final String? title;
  final List<String> capabilities;

  const StaffInvitation({
    required this.businessId,
    required this.businessName,
    this.businessPhone,
    this.businessLogoUrl,
    this.title,
    required this.capabilities,
  });

  factory StaffInvitation.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>? ?? const {};
    return StaffInvitation(
      businessId: (json['business_id'] as num?)?.toInt() ?? (business['id'] as num?)?.toInt() ?? 0,
      businessName: business['name'] as String? ?? '',
      businessPhone: business['phone'] as String?,
      businessLogoUrl: Env.assetUrl(business['logo'] as String?),
      title: json['title'] as String?,
      capabilities: (json['capabilities'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    );
  }
}
