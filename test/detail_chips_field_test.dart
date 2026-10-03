import 'package:bim_app/features/business_menu/presentation/screens/tech_pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// «طراز الأثاث» chips did not light up on the first tap while another describing
/// group already had a choice: every group shares one selected set, and the chips
/// handed the WHOLE set back, so the screen's merge kept picking another group's id.
void main() {
  testWidgets('a tap in one group lights that chip even when another group already has a choice', (tester) async {
    final chosen = <int>{10}; // wood type already picked
    const style = [(id: 1, name: 'كلاسيك'), (id: 2, name: 'مودرن')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => DetailChipsField(
              label: 'طراز الأثاث',
              options: style,
              selected: chosen,
              multi: false,
              // The screen's merge, verbatim.
              onChanged: (ids) => setState(() {
                chosen.removeAll(style.map((o) => o.id));
                chosen.addAll(ids.isEmpty ? ids : {ids.first});
              }),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('مودرن'));
    await tester.pump();

    expect(chosen, {10, 2});

    await tester.tap(find.text('كلاسيك'));
    await tester.pump();

    expect(chosen, {10, 1}, reason: 'single choice: the new one replaces the old');

    await tester.tap(find.text('كلاسيك'));
    await tester.pump();

    expect(chosen, {10}, reason: 'tapping the chosen one clears it');
  });
}
