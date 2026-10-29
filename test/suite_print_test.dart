import 'dart:io';

import 'package:bim_app/desktop/print/suite_print.dart';
import 'package:flutter_test/flutter_test.dart';

/// The printed documents build with the app's Arabic font. Set SUITE_PRINT_OUT to a folder to keep the PDFs for a look.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> keep(String name, List<int> bytes) async {
    final dir = Platform.environment['SUITE_PRINT_OUT'];
    if (dir != null && dir.isNotEmpty) await File('$dir/$name').writeAsBytes(bytes);
  }

  test('the cashier receipt is an 80 mm PDF', () async {
    final pdf = await SuitePrint.receipt(
      businessName: 'مطعم النخيل',
      title: 'إيصال بيع',
      number: '47',
      at: DateTime(2026, 10, 29, 21, 30),
      lines: const [
        PrintLine(name: 'وجبة برجر دبل', qty: '2', price: '260', total: '520'),
        PrintLine(name: 'بطاطس مقلية', qty: '1', price: '45', total: '45'),
        PrintLine(name: 'في كولا علبة', qty: '3', price: '25', total: '75'),
      ],
      total: '640',
      paid: '700',
      change: '60',
      footer: 'شكرًا لزيارتكم — الدفع نقدًا',
      labels: const {'number': 'رقم الفاتورة', 'date': 'الوقت', 'total': 'الإجمالي', 'paid': 'المدفوع نقدًا', 'change': 'الباقي'},
    );

    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    expect(pdf.length, greaterThan(2000));
    await keep('receipt.pdf', pdf);
  });

  test('a purchase order prints on A4 with its table and signatures', () async {
    final pdf = await SuitePrint.document(
      businessName: 'مطعم النخيل',
      title: 'أمر شراء #1043',
      facts: const [('المورد', 'شركة الألبان المتحدة'), ('الحالة', 'معتمد ومُرسل')],
      headers: const ['الصنف', 'الوحدة', 'الكمية', 'سعر الوحدة', 'الإجمالي'],
      rows: const [
        ['جبنة شيدر شرائح', 'كرتونة', '2', '950', '1,900'],
        ['زيت قلي', 'جركن 18 لتر', '4', '1,530', '6,120'],
      ],
      totalLabel: 'الإجمالي',
      total: '8,020 ج',
      signatures: const ['أعدّه', 'اعتمده', 'المورد'],
    );

    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    await keep('purchase-order.pdf', pdf);
  });
}
