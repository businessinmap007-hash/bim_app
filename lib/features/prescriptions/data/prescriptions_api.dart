import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/prescription.dart';

/// One drug line as the doctor writes it. Write-only shape — the server
/// echoes back the full read [PrescriptionItem] shape after issue/revise.
class PrescriptionItemInput {
  final int medicineId;
  final String? dosage;
  final String? quantity;
  final String? instructions;
  final int? frequencyPerDay;
  final String? foodTiming;
  final List<String> timeSlots;
  final int? durationValue;
  final String? durationUnit;

  const PrescriptionItemInput({
    required this.medicineId,
    this.dosage,
    this.quantity,
    this.instructions,
    this.frequencyPerDay,
    this.foodTiming,
    this.timeSlots = const [],
    this.durationValue,
    this.durationUnit,
  });

  Map<String, dynamic> toJson() => {
    'medicine_id': medicineId,
    if (dosage != null && dosage!.isNotEmpty) 'dosage': dosage,
    if (quantity != null && quantity!.isNotEmpty) 'quantity': quantity,
    if (instructions != null && instructions!.isNotEmpty)
      'instructions': instructions,
    if (frequencyPerDay != null) 'frequency_per_day': frequencyPerDay,
    if (foodTiming != null) 'food_timing': foodTiming,
    if (timeSlots.isNotEmpty) 'time_slots': timeSlots,
    if (durationValue != null) 'duration_value': durationValue,
    if (durationUnit != null) 'duration_unit': durationUnit,
  };
}

/// /prescriptions — both the patient's side and, since this app's doctor
/// accounts (clinic/hospital/medical-center businesses) can issue and revise
/// too, the doctor's side. Pharmacy-side dispensing actions live on
/// PharmacyPrescriptionController, still out of scope.
class PrescriptionsApi {
  final ApiClient _client;
  const PrescriptionsApi(this._client);

  Future<Paginated<Prescription>> myPrescriptions({int page = 1}) async {
    final data =
        await _client.get('/prescriptions', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, Prescription.fromJson);
  }

  /// A doctor's own issued prescriptions.
  Future<Paginated<Prescription>> issuedPrescriptions({int page = 1}) async {
    final data =
        await _client.get('/prescriptions/issued', query: {'page': page})
            as Map<String, dynamic>;
    return Paginated.fromJson(data, Prescription.fromJson);
  }

  /// A doctor issues a new prescription for a patient — [patientId] and, when
  /// tied to a visit, [appointmentId] come from an already-known context (an
  /// appointment on the clinic's own list), never a bare name/phone search.
  Future<Prescription> issue({
    required int patientId,
    int? appointmentId,
    String? diagnosis,
    String? patientCondition,
    String? notes,
    required List<PrescriptionItemInput> items,
  }) async {
    final data =
        await _client.post(
              '/prescriptions',
              data: {
                'patient_id': patientId,
                'appointment_id': ?appointmentId,
                if (diagnosis != null && diagnosis.isNotEmpty)
                  'diagnosis': diagnosis,
                if (patientCondition != null && patientCondition.isNotEmpty)
                  'patient_condition': patientCondition,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                'items': items.map((i) => i.toJson()).toList(),
              },
            )
            as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  /// The original doctor amends a prescription. Never in place — the server
  /// creates a new prescription and cancels this one.
  Future<Prescription> revise(
    int id, {
    String? diagnosis,
    String? patientCondition,
    String? notes,
    required List<PrescriptionItemInput> items,
  }) async {
    final data =
        await _client.post(
              '/prescriptions/$id/revise',
              data: {
                if (diagnosis != null && diagnosis.isNotEmpty)
                  'diagnosis': diagnosis,
                if (patientCondition != null && patientCondition.isNotEmpty)
                  'patient_condition': patientCondition,
                if (notes != null && notes.isNotEmpty) 'notes': notes,
                'items': items.map((i) => i.toJson()).toList(),
              },
            )
            as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> prescription(int id) async {
    final data =
        await _client.get('/prescriptions/$id') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> sendToPharmacy(
    int id, {
    required int pharmacyId,
    required String fulfillmentType,
    int? addressId,
    String? deliveryAddress,
  }) async {
    final data =
        await _client.post(
              '/prescriptions/$id/send',
              data: {
                'pharmacy_id': pharmacyId,
                'fulfillment_type': fulfillmentType,
                'address_id': ?addressId,
                if (addressId == null &&
                    deliveryAddress != null &&
                    deliveryAddress.isNotEmpty)
                  'delivery_address': deliveryAddress,
              },
            )
            as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> cancel(int id) async {
    final data =
        await _client.post('/prescriptions/$id/cancel') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> share(int id, {required int doctorId}) async {
    final data =
        await _client.post(
              '/prescriptions/$id/share',
              data: {'doctor_id': doctorId},
            )
            as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  /// Returns how many dose reminders were placed on the patient's agenda.
  Future<int> scheduleReminders(int id) async {
    final data =
        await _client.post('/prescriptions/$id/schedule-reminders')
            as Map<String, dynamic>;
    return (data['reminders'] as num?)?.toInt() ?? 0;
  }

  Future<PrescriptionImage> addImage(int id, String filePath) async {
    final data =
        await _client.post(
              '/prescriptions/$id/images',
              data: FormData.fromMap({
                'image': await MultipartFile.fromFile(filePath),
              }),
            )
            as Map<String, dynamic>;
    return PrescriptionImage.fromJson(data['image'] as Map<String, dynamic>);
  }

  Future<void> removeImage(int id, int imageId) async {
    await _client.delete('/prescriptions/$id/images/$imageId');
  }
}
