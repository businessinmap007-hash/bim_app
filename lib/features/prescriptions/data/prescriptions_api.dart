import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/prescription.dart';

/// /prescriptions — the patient's side only (see PrescriptionController).
/// Issuing (store) and revising a prescription are a doctor/clinic action —
/// out of scope for this customer app. Pharmacy-side dispensing actions live
/// on PharmacyPrescriptionController, also out of scope.
class PrescriptionsApi {
  final ApiClient _client;
  const PrescriptionsApi(this._client);

  Future<Paginated<Prescription>> myPrescriptions({int page = 1}) async {
    final data = await _client.get('/prescriptions', query: {'page': page}) as Map<String, dynamic>;
    return Paginated.fromJson(data, Prescription.fromJson);
  }

  Future<Prescription> prescription(int id) async {
    final data = await _client.get('/prescriptions/$id') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> sendToPharmacy(
    int id, {
    required int pharmacyId,
    required String fulfillmentType,
    String? deliveryAddress,
  }) async {
    final data = await _client.post(
      '/prescriptions/$id/send',
      data: {
        'pharmacy_id': pharmacyId,
        'fulfillment_type': fulfillmentType,
        if (deliveryAddress != null && deliveryAddress.isNotEmpty) 'delivery_address': deliveryAddress,
      },
    ) as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> cancel(int id) async {
    final data = await _client.post('/prescriptions/$id/cancel') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> share(int id, {required int doctorId}) async {
    final data = await _client.post(
      '/prescriptions/$id/share',
      data: {'doctor_id': doctorId},
    ) as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  /// Returns how many dose reminders were placed on the patient's agenda.
  Future<int> scheduleReminders(int id) async {
    final data = await _client.post('/prescriptions/$id/schedule-reminders') as Map<String, dynamic>;
    return (data['reminders'] as num?)?.toInt() ?? 0;
  }

  Future<PrescriptionImage> addImage(int id, String filePath) async {
    final data = await _client.post(
      '/prescriptions/$id/images',
      data: FormData.fromMap({'image': await MultipartFile.fromFile(filePath)}),
    ) as Map<String, dynamic>;
    return PrescriptionImage.fromJson(data['image'] as Map<String, dynamic>);
  }

  Future<void> removeImage(int id, int imageId) async {
    await _client.delete('/prescriptions/$id/images/$imageId');
  }
}
