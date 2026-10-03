import 'package:bim_app/features/cart/presentation/screens/tech_product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// «حدد أقصى ارتفاع للصورة على الشاشات الكبيرة» — 16 : 10 of the width, capped at 360.
void main() {
  Future<double> heightAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ListView(children: const [HeroImageBox(child: ColoredBox(color: Colors.blue))]))),
    );

    return tester.getSize(find.byType(HeroImageBox)).height;
  }

  testWidgets('a phone keeps 16:10 of its width', (tester) async {
    expect(await heightAt(tester, 400), 250);
    expect(await heightAt(tester, 360), 225);
  });

  testWidgets('a tablet / desktop is capped at 360', (tester) async {
    expect(await heightAt(tester, 1000), HeroImageBox.maxHeight);
    expect(await heightAt(tester, 1280), HeroImageBox.maxHeight);
  });

  testWidgets('the width where 16:10 meets the cap is exactly 576', (tester) async {
    expect(await heightAt(tester, 576), 360);
    expect(await heightAt(tester, 577), 360);
  });
}
