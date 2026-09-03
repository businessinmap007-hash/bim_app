import '../../../core/network/api_client.dart';
import '../../../core/network/paginated.dart';
import 'models/prescription.dart';

/// One line's price, submitted together with every other line on the same
/// prescription (all-or-nothing) — see PrescriptionService::price().
class PricedItemInput {
  final int prescriptionItemId;
  final double unitPrice;
  final int billedQuantity;

  const PricedItemInput({
    required this.prescriptionItemId,
    required this.unitPrice,
    required this.billedQuantity,
  });

  Map<String, dynamic> toJson() => {
    'prescription_item_id': prescriptionItemId,
    'unit_price': unitPrice,
    'billed_quantity': billedQuantity,
  };
}

/// /pharmacy/prescriptions — the pharmacy's own queue of prescriptions sent
/// to it: price, prepare, mark ready, dispense, or reject back to the
/// patient. See Api\V2\PharmacyPrescriptionController. Detail/single-fetch
/// reuses PrescriptionsApi.prescription() — the pharmacy is a valid party
/// on the general show() endpoint too.
class PharmacyPrescriptionsApi {
  final ApiClient _client;
  const PharmacyPrescriptionsApi(this._client);

  Future<Paginated<Prescription>> incoming({String? status, int page = 1}) async {
    final data = await _client.get(
      '/pharmacy/prescriptions',
      query: {if (status != null && status.isNotEmpty) 'status': status, 'page': page},
    ) as Map<String, dynamic>;
    return Paginated.fromJson(data, Prescription.fromJson);
  }

  Future<Prescription> price(int id, List<PricedItemInput> items) async {
    final data = await _client.post(
      '/pharmacy/prescriptions/$id/price',
      data: {'items': items.map((i) => i.toJson()).toList()},
    ) as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> prepare(int id) async {
    final data = await _client.post('/pharmacy/prescriptions/$id/prepare') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> ready(int id) async {
    final data = await _client.post('/pharmacy/prescriptions/$id/ready') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> dispense(int id) async {
    final data = await _client.post('/pharmacy/prescriptions/$id/dispense') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }

  Future<Prescription> reject(int id) async {
    final data = await _client.post('/pharmacy/prescriptions/$id/reject') as Map<String, dynamic>;
    return Prescription.fromJson(data['prescription'] as Map<String, dynamic>);
  }
}
