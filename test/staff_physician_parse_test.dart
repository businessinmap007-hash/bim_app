import 'package:bim_app/features/clinic/data/models/clinic_appointment.dart';
import 'package:bim_app/features/prescriptions/data/models/prescription.dart';
import 'package:bim_app/features/staff/data/models/staff_member.dart';
import 'package:bim_app/features/staff/data/models/staff_membership.dart';
import 'package:flutter_test/flutter_test.dart';

/// «الطبيب فى المستشفى موظف» — المالك، 2026-10-14: the physician rides on every model the server names him in.
void main() {
  test('a staff member and a membership know they are a physician', () {
    final member = StaffMember.fromJson({
      'user': {'id': 9, 'name': 'د. كمال'},
      'title': 'استشاري باطنة',
      'capabilities': ['clinic', 'prescriptions'],
      'is_physician': true,
    });
    expect(member.isPhysician, isTrue);
    expect(StaffMember.fromJson({'user': {'id': 1, 'name': 'سكرتيرة'}, 'capabilities': <String>[]}).isPhysician, isFalse);

    final membership = StaffMembership.fromJson({
      'business': {'id': 5, 'name': 'مستشفى الشفاء'},
      'capabilities': ['clinic'],
      'is_physician': true,
    });
    expect(membership.isPhysician, isTrue);
  });

  test('the patient reads «مع د. فلان — لقبه» on his appointment', () {
    final a = ClinicAppointment.fromJson({
      'id': 1,
      'status': 'confirmed',
      'clinic': {'id': 5, 'name': 'مستشفى الشفاء'},
      'physician': {'id': 9, 'name': 'د. كمال', 'title': 'استشاري باطنة'},
    });
    expect(a.physicianLine, 'د. كمال — استشاري باطنة');
    expect(ClinicAppointment.fromJson({'id': 2, 'status': 'confirmed'}).physicianLine, isNull);
  });

  test('a prescription names the physician beside the hospital that is its doctor of record', () {
    final p = Prescription.fromJson({
      'id': 3,
      'status': 'issued',
      'doctor': {'id': 5, 'name': 'مستشفى الشفاء'},
      'physician': {'id': 9, 'name': 'د. كمال', 'title': 'استشاري باطنة'},
      'patient': {'id': 77, 'name': 'مريض'},
    });
    expect(p.doctor?.name, 'مستشفى الشفاء');
    expect(p.physician?.line, 'د. كمال — استشاري باطنة');
  });
}
