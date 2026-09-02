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

  const StaffMember({
    required this.userId,
    required this.name,
    this.phone,
    this.logoUrl,
    this.title,
    required this.capabilities,
    required this.isActive,
  });

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
    );
  }
}
