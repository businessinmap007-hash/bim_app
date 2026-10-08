/// A doctor listed under a department. [businessId] is the doctor's own account — the page a patient can visit — and is
/// null for a doctor the hospital listed as text. [isPending]: the doctor has not accepted yet (only the hospital sees it).
class HospitalDoctorEntry {
  final int id;
  final String name;
  final int? businessId;
  final String status;

  const HospitalDoctorEntry({required this.id, required this.name, this.businessId, this.status = 'active'});

  bool get isPending => status == 'pending';

  factory HospitalDoctorEntry.fromJson(Map<String, dynamic> json) => HospitalDoctorEntry(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    businessId: (json['business_id'] as num?)?.toInt(),
    status: json['status'] as String? ?? 'active',
  );
}

/// A department of a hospital: one of the medical specialties it ticked, with the doctors under it.
class HospitalDepartment {
  final int optionId;
  final String name;
  final List<HospitalDoctorEntry> doctors;

  const HospitalDepartment({required this.optionId, required this.name, this.doctors = const []});

  factory HospitalDepartment.fromJson(Map<String, dynamic> json) => HospitalDepartment(
    optionId: (json['option_id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    doctors: (json['doctors'] as List<dynamic>? ?? [])
        .map((e) => HospitalDoctorEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// A doctor account a hospital may invite, found by name.
class DoctorCandidate {
  final int id;
  final String name;

  const DoctorCandidate({required this.id, required this.name});

  factory DoctorCandidate.fromJson(Map<String, dynamic> json) =>
      DoctorCandidate(id: (json['id'] as num?)?.toInt() ?? 0, name: json['name'] as String? ?? '');
}

/// One hospital department a doctor was invited to (pending) or is listed under (active).
class HospitalInvitation {
  final int id;
  final int hospitalId;
  final String hospitalName;
  final String department;
  final String status;

  const HospitalInvitation({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.department,
    required this.status,
  });

  factory HospitalInvitation.fromJson(Map<String, dynamic> json) {
    final hospital = json['hospital'] as Map<String, dynamic>? ?? const {};

    return HospitalInvitation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      hospitalId: (hospital['id'] as num?)?.toInt() ?? 0,
      hospitalName: hospital['name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class HospitalInvitations {
  final List<HospitalInvitation> pending;
  final List<HospitalInvitation> active;

  const HospitalInvitations({this.pending = const [], this.active = const []});

  factory HospitalInvitations.fromJson(Map<String, dynamic> json) {
    List<HospitalInvitation> list(String key) =>
        (json[key] as List<dynamic>? ?? []).map((e) => HospitalInvitation.fromJson(e as Map<String, dynamic>)).toList();

    return HospitalInvitations(pending: list('pending'), active: list('active'));
  }
}
