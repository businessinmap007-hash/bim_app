import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/location/data/models/location_models.dart';

LocationGovernorate _g(int id, String ar, String en) => LocationGovernorate(id: id, countryId: 1, nameAr: ar, nameEn: en);

void main() {
  final items = [
    _g(1, 'القاهرة', 'Cairo'),
    _g(2, 'الإسكندرية', 'Alexandria'),
    _g(3, 'أسوان', 'Aswan'),
    _g(4, 'الجيزة', 'Giza'),
    _g(5, 'البحيرة', 'Beheira'),
    _g(6, 'أسيوط', 'Assiut'),
  ];

  test('governorates are alphabetical by the name the person reads', () {
    expect(sortedGovernorates(items, 'en').map((g) => g.nameEn), ['Alexandria', 'Assiut', 'Aswan', 'Beheira', 'Cairo', 'Giza']);
    // «ال» and the hamza forms of alef are ignored, so الإسكندرية sits with the alefs
    expect(sortedGovernorates(items, 'ar').map((g) => g.nameAr), ['الإسكندرية', 'أسوان', 'أسيوط', 'البحيرة', 'الجيزة', 'القاهرة']);
  });
}
