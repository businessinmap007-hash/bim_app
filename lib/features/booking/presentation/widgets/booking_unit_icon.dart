import 'package:flutter/material.dart';

/// The glyph of what is being booked — a bed for a hotel room, but a pitch for a pitch, a table for a table, a house
/// for a chalet, a cap for a course, a calendar for an appointment. The page's shape says it best; the item type is
/// the fallback when a form is opened without a shape.
IconData bookingUnitIcon({String? shapeCode, String? itemType}) {
  switch (shapeCode) {
    case 'hourly_venue':
      return Icons.stadium_outlined;
    case 'table':
      return Icons.table_restaurant_outlined;
    case 'furnished_units':
      return Icons.cottage_outlined;
    case 'course':
      return Icons.school_outlined;
    case 'appointment':
    case 'clinic':
      return Icons.event_available_outlined;
    case 'hotel_rooms':
      return Icons.bed_outlined;
  }

  switch (itemType) {
    case 'booking_time':
      return Icons.stadium_outlined;
    case 'booking_table':
      return Icons.table_restaurant_outlined;
    case 'book_a_course':
      return Icons.school_outlined;
    case 'booking_appointment':
      return Icons.event_available_outlined;
  }

  return Icons.bed_outlined;
}
