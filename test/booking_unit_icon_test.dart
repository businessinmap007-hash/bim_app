import 'package:bim_app/features/booking/presentation/widgets/booking_unit_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// «غير ايقونة السرير الى ما يناسب البزنس» — المالك، 2026-10-14.
void main() {
  test('the glyph follows what is booked, not always a bed', () {
    expect(bookingUnitIcon(shapeCode: 'hourly_venue'), Icons.stadium_outlined);
    expect(bookingUnitIcon(shapeCode: 'table'), Icons.table_restaurant_outlined);
    expect(bookingUnitIcon(shapeCode: 'furnished_units'), Icons.cottage_outlined);
    expect(bookingUnitIcon(shapeCode: 'course'), Icons.school_outlined);
    expect(bookingUnitIcon(shapeCode: 'appointment'), Icons.event_available_outlined);
    expect(bookingUnitIcon(shapeCode: 'hotel_rooms'), Icons.bed_outlined);
  });

  test('without a shape the item type decides, and a hotel room is the default', () {
    expect(bookingUnitIcon(itemType: 'booking_table'), Icons.table_restaurant_outlined);
    expect(bookingUnitIcon(itemType: 'booking_time'), Icons.stadium_outlined);
    expect(bookingUnitIcon(itemType: 'book_a_course'), Icons.school_outlined);
    expect(bookingUnitIcon(itemType: 'booking_stay'), Icons.bed_outlined);
    expect(bookingUnitIcon(), Icons.bed_outlined);
  });
}
