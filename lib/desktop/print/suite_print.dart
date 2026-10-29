import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../sync/desktop_sync.dart';
import '../sync/suite_store.dart';

/// One line of a printed document (already in the words the paper shows).
class PrintLine {
  final String name;
  final String qty;
  final String price;
  final String total;

  const PrintLine({required this.name, required this.qty, this.price = '', this.total = ''});
}

/// What the printers print (owner, 2026-10-29: «اضف الطباعة»): the cashier's receipt on an 80 mm roll, and the purchase
/// order and the receiving note on A4. Arabic, right to left, in the app's own Cairo font. Each computer picks its own
/// receipt printer and documents printer (any printer Windows / macOS knows — a thermal roll printer, an office printer,
/// or «Microsoft Print to PDF»); with none picked, the system's print dialog opens.
class SuitePrint {
  final SuiteStore store;

  SuitePrint(this.store);

  static const receiptPrinterKey = 'print_receipt_printer';
  static const documentPrinterKey = 'print_document_printer';
  static const autoReceiptKey = 'print_receipt_auto';

  static pw.Font? _font;

  static Future<pw.ThemeData> _theme() async {
    _font ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Variable.ttf'));
    return pw.ThemeData.withFont(base: _font, bold: _font);
  }

  bool get autoReceipt => store.meta.get(autoReceiptKey) == '1';

  // ── documents ──

  /// The cashier's receipt, 80 mm roll.
  static Future<Uint8List> receipt({
    required String businessName,
    required String title,
    required String number,
    required DateTime at,
    required List<PrintLine> lines,
    required String total,
    required String paid,
    required String change,
    required String footer,
    required Map<String, String> labels,
  }) async {
    final doc = pw.Document(theme: await _theme());
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.roll80.copyWith(marginLeft: 4 * PdfPageFormat.mm, marginRight: 4 * PdfPageFormat.mm),
      textDirection: pw.TextDirection.rtl,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _t(businessName, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          _t(title, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          _t('${labels['number']}: $number', style: const pw.TextStyle(fontSize: 9)),
          _t('${labels['date']}: ${_stamp(at)}', style: const pw.TextStyle(fontSize: 9)),
          pw.Divider(thickness: 0.5),
          for (final l in lines)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
              child: pw.Row(children: [
                pw.Expanded(child: _t('${l.name}\n${l.qty} × ${l.price}', style: const pw.TextStyle(fontSize: 9))),
                _t(l.total, style: const pw.TextStyle(fontSize: 9)),
              ]),
            ),
          pw.Divider(thickness: 0.5),
          _pair(labels['total']!, total, bold: true, size: 12),
          _pair(labels['paid']!, paid),
          _pair(labels['change']!, change),
          pw.SizedBox(height: 6),
          _t(footer, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    ));
    return doc.save();
  }

  /// A4 document: a purchase order or a receiving note.
  static Future<Uint8List> document({
    required String businessName,
    required String title,
    required List<(String, String)> facts,
    required List<String> headers,
    required List<List<String>> rows,
    String? totalLabel,
    String? total,
    String? notes,
    required List<String> signatures,
  }) async {
    final doc = pw.Document(theme: await _theme());
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => [
        pw.Row(children: [
          pw.Expanded(child: _t(businessName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
          _t(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.SizedBox(height: 12),
        pw.Wrap(spacing: 24, runSpacing: 4, children: [for (final f in facts) _t('${f.$1}: ${f.$2}', style: const pw.TextStyle(fontSize: 11))]),
        pw.SizedBox(height: 14),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0B1F3A)),
              // the PDF table lays its columns out left to right: reversed, the first column reads on the right
              children: [for (final h in headers.reversed) _cell(h, header: true)],
            ),
            for (var i = 0; i < rows.length; i++)
              pw.TableRow(
                decoration: i.isOdd ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF4F2EC)) : null,
                children: [for (final c in rows[i].reversed) _cell(c)],
              ),
          ],
        ),
        if (total != null) ...[
          pw.SizedBox(height: 10),
          pw.Align(alignment: pw.Alignment.centerLeft, child: _t('${totalLabel ?? ''}: $total', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
        ],
        if (notes != null && notes.isNotEmpty) ...[pw.SizedBox(height: 10), _t(notes, style: const pw.TextStyle(fontSize: 10))],
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            for (final s in signatures)
              pw.SizedBox(
                width: 150,
                child: pw.Column(children: [
                  _t(s, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 24),
                  pw.Container(height: 0.6, color: PdfColors.grey700),
                ]),
              ),
          ],
        ),
      ],
    ));
    return doc.save();
  }

  // ── sending to a printer ──

  /// Prints to this computer's chosen printer, or opens the print dialog when none is chosen.
  Future<bool> print(Uint8List pdf, {required bool receipt, required String name}) async {
    final url = store.meta.get(receipt ? receiptPrinterKey : documentPrinterKey);

    if (url != null && url.isNotEmpty) {
      final printers = await Printing.listPrinters();
      final printer = printers.where((p) => p.url == url).firstOrNull;
      if (printer != null) {
        return Printing.directPrintPdf(printer: printer, name: name, format: receipt ? PdfPageFormat.roll80 : PdfPageFormat.a4, onLayout: (_) async => pdf);
      }
    }

    return Printing.layoutPdf(name: name, format: receipt ? PdfPageFormat.roll80 : PdfPageFormat.a4, onLayout: (_) async => pdf);
  }

  static pw.Widget _pair(String label, String value, {bool bold = false, double size = 10}) {
    final style = pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Row(children: [pw.Expanded(child: _t(label, style: style)), _t(value, style: style)]);
  }

  static String _stamp(DateTime at) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${at.year}-${two(at.month)}-${two(at.day)} ${two(at.hour)}:${two(at.minute)}';
  }

  /// A purchase order's lines as the paper shows them.
  static List<List<String>> orderRows(InvPurchaseOrder po) => [
        for (final l in po.lines) [l.itemName ?? '', l.unitName, invNum(l.qty), InvLabels.money(l.unitPrice), InvLabels.money(l.total)],
      ];
}

/// Cairo's «ر»-shaped endings (ر ز د ذ) swallow the following space in the PDF engine — «أمر شراء» printed «أمرشراء».
/// An extra space after them restores the gap; nothing else about the text changes.
String _fix(String text) => text.replaceAllMapped(RegExp('([رزژدذ]) '), (m) => '${m[1]}  ');

pw.Widget _cell(String text, {bool header = false}) => pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: _t(
        text,
        textAlign: pw.TextAlign.right,
        style: header ? pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10) : const pw.TextStyle(fontSize: 10),
      ),
    );

pw.Text _t(String text, {pw.TextStyle? style, pw.TextAlign? textAlign}) => pw.Text(_fix(text), style: style, textAlign: textAlign);

final suitePrintProvider = Provider<SuitePrint>((ref) => SuitePrint(ref.watch(suiteStoreProvider)));
