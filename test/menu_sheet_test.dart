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

    final bytes = sheet.toXlsx(
      listsSheetName: 'الأنواع والوحدات',
      typeHeader: 'النوع',
      groupHeader: 'المجموعة',
      unitsHeader: 'الوحدات',
    );
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
        {
          'row': 3,
          'name': 'خطأ',
          'action': 'error',
          'errors': ['النوع «صاروخ» ليس من أنواع نشاطك.'],
        },
      ],
    });

    expect(report.dryRun, isTrue);
    expect(report.created, 1);
    expect(report.rows.last.errors.single, contains('صاروخ'));
  });

  test(
    'a row that went in with a note keeps its warnings, and the template carries the how-to lines',
    () {
      final row = MenuImportRow.fromJson({
        'row': 2,
        'name': 'برجر',
        'action': 'create',
        'errors': [],
        'warnings': ['تعذّر تحميل الصورة: https://x'],
      });
      expect(row.warnings.single, contains('تعذّر'));

      final sheet = MenuSheetData.fromJson({
        'columns': [
          {'key': 'name_ar', 'label': 'الاسم عربي'},
        ],
        'rows': [],
        'vocabulary': {
          'lines': [],
          'units': [],
          'help': ['المقاسات: صغير=50'],
        },
      });
      expect(sheet.help.single, startsWith('المقاسات'));
      expect(
        sheet.toXlsx(
          listsSheetName: 'L',
          typeHeader: 't',
          groupHeader: 'g',
          unitsHeader: 'u',
          howToHeader: 'h',
        ),
        isNotEmpty,
      );
    },
  );

  test(
    'an Excel file reads as a grid, header row first, empty rows dropped',
    () {
      final sheet = MenuSheetData.fromJson({
        'columns': [
          {'key': 'name_ar', 'label': 'الاسم عربي'},
          {'key': 'price', 'label': 'السعر'},
        ],
        'rows': [
          {'name_ar': 'برجر', 'price': 55},
          {'name_ar': '', 'price': ''},
          {'name_ar': 'بيتزا', 'price': 80.5},
        ],
      });

      final grid = readXlsxGrid(
        sheet.toXlsx(
          listsSheetName: 'lists',
          typeHeader: 'a',
          groupHeader: 'b',
          unitsHeader: 'c',
        ),
      );

      expect(grid.first, ['الاسم عربي', 'السعر']);
      expect(grid, hasLength(3), reason: 'the empty row is dropped');
      expect(grid[1], ['برجر', '55']);
      expect(grid[2], ['بيتزا', '80.5']);
    },
  );

  test(
    'an inspected file reads its numbered headers and the suggested mapping',
    () {
      final inspect = MenuFileInspect.fromJson({
        'headers': ['كود', 'المنتج', 'بيع'],
        'sample': [
          ['', 'غرفة', '30000'],
        ],
        'total_rows': 4,
        'mapping': {'name_ar': null, 'price': 3, 'line': null},
        'columns': [
          {'key': 'name_ar', 'label': 'الاسم عربي'},
          {'key': 'price', 'label': 'السعر'},
        ],
      });

      expect(inspect.headers[1], 'المنتج');
      expect(inspect.totalRows, 4);
      expect(inspect.mapping['price'], 3);
      expect(inspect.mapping['name_ar'], isNull);
      expect(inspect.columns.last.label, 'السعر');
    },
  );
}
