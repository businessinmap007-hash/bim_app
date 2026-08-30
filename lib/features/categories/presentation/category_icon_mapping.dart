import 'package:flutter/material.dart';

/// Maps a root category's Arabic name to a Material icon for [PinBadgeIcon].
/// Matched by keyword (not exact string) so small backend wording changes
/// don't silently fall back to the generic icon. Order matters — first
/// match wins, so put more specific keywords before broader ones.
IconData iconForCategory(String nameAr) {
  for (final entry in _keywordIcons) {
    if (nameAr.contains(entry.$1)) return entry.$2;
  }
  return Icons.storefront_rounded;
}

const _keywordIcons = <(String, IconData)>[
  ('مطاعم', Icons.restaurant_rounded),
  ('كافيه', Icons.local_cafe_rounded),
  ('فندق', Icons.hotel_rounded),
  ('سياح', Icons.hotel_rounded),
  ('مصنع', Icons.factory_rounded),
  ('مصانع', Icons.factory_rounded),
  ('شرك', Icons.apartment_rounded),
  ('مكاتب', Icons.business_rounded),
  ('صحة', Icons.local_hospital_rounded),
  ('طبي', Icons.local_hospital_rounded),
  ('معارض', Icons.event_rounded),
  ('محلات', Icons.shopping_bag_rounded),
  ('اونلاين', Icons.shopping_cart_rounded),
  ('أونلاين', Icons.shopping_cart_rounded),
  ('عقارات', Icons.home_work_rounded),
  ('أراضي', Icons.home_work_rounded),
  ('سيارات', Icons.directions_car_rounded),
  ('فنون', Icons.palette_rounded),
  ('ترفي', Icons.palette_rounded),
  ('تكنولوجيا', Icons.memory_rounded),
  ('رياض', Icons.fitness_center_rounded),
  ('قاعات', Icons.celebration_rounded),
  ('دورات', Icons.school_rounded),
  ('تدريب', Icons.school_rounded),
  ('ورش', Icons.construction_rounded),
  ('صيانة', Icons.construction_rounded),
  ('زراع', Icons.agriculture_rounded),
  ('حيوان', Icons.pets_rounded),
  ('ملابس', Icons.checkroom_rounded),
  ('اكسسوارات', Icons.checkroom_rounded),
  ('كوافير', Icons.content_cut_rounded),
  ('شحن', Icons.local_shipping_rounded),
  ('توصيل', Icons.local_shipping_rounded),
  ('مهن', Icons.engineering_rounded),
  ('حرفي', Icons.engineering_rounded),
];
