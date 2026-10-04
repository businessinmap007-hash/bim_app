import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/business_menu/data/menu_sheet.dart';

/// «استيراد وتصدير المنيو» — an Excel file written by the app reads back as the rows the server takes.
void main() {
  test('an exported sheet reads back as rows keyed by its Arabic headers', () {
    final sheet = MenuSheetData.fromJson({
      'columns': [
        {'key': 'id', 'label': 'رقم الصنف'},
        {'key': 'line', 'label': 'النوع'},
        {'key': 'name_ar', 'label': 'الاسم عربي'},
        {'key': 'price', 'label': 'السعر'},
      ],
      'rows': [
        {'id': 7, 'line': 'غرفة نوم', 'name_ar': 'غرفة ماستر', 'price': 30000},
        {'id': '', 'line': 'ركنة', 'name_ar': 'ركنة صغيرة', 'price': 12500.5},
      ],
      'vocabulary': {
        'lines': [
          {'name': 'غرفة نوم', 'group': 'أثاث'},
        ],
        'units': ['قطعة', 'كجم'],
      },
    });

    final bytes = sheet.toXlsx(listsSheetName: 'الأنواع والوحدات', typeHeader: 'النوع', groupHeader: 'المجموعة', unitsHeader: 'الوحدات');
    final rows = readXlsxRows(bytes);

    expect(rows, hasLength(2));
    expect(rows[0]['رقم الصنف'], '7');
    expect(rows[0]['الاسم عربي'], 'غرفة ماستر');
    expect(rows[0]['السعر'], '30000', reason: 'a whole price has no «.0»');
    expect(rows[1]['السعر'], '12500.5');
    expect(rows[1]['رقم الصنف'], '', reason: 'a new item has no id');
  });

  test('an import report reads per row', () {
    final report = MenuImportReport.fromJson({
      'dry_run': true,
      'summary': {'create': 1, 'update': 0, 'error': 1},
      'rows': [
        {'row': 2, 'name': 'غرفة', 'action': 'create', 'errors': []},
        {'row': 3, 'name': 'خطأ', 'action': 'error', 'errors': ['النوع «صاروخ» ليس من أنواع نشاطك.']},
      ],
    });

    expect(report.dryRun, isTrue);
    expect(report.created, 1);
    expect(report.rows.last.errors.single, contains('صاروخ'));
  });
}
