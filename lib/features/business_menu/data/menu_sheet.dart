import 'package:excel/excel.dart';

/// «استيراد وتصدير المنيو» — the menu as a sheet (`GET /business/menu/sheet`): the columns in the app's
/// language, the merchant's items as rows (or two example rows for a template), and what «النوع» and
/// «الوحدة» may say. See Api\V2\BusinessMenuSheetController.
class MenuSheetData {
  final List<({String key, String label})> columns;
  final List<Map<String, dynamic>> rows;
  final List<({String name, String group})> lines;
  final List<String> units;

  const MenuSheetData({required this.columns, required this.rows, required this.lines, required this.units});

  factory MenuSheetData.fromJson(Map<String, dynamic> json) {
    final vocabulary = json['vocabulary'] as Map<String, dynamic>? ?? const {};
    return MenuSheetData(
      columns: [
        for (final c in json['columns'] as List<dynamic>? ?? const [])
          (key: '${(c as Map<String, dynamic>)['key']}', label: '${c['label']}'),
      ],
      rows: [for (final r in json['rows'] as List<dynamic>? ?? const []) Map<String, dynamic>.from(r as Map)],
      lines: [
        for (final l in vocabulary['lines'] as List<dynamic>? ?? const [])
          (name: '${(l as Map<String, dynamic>)['name']}', group: '${l['group']}'),
      ],
      units: [for (final u in vocabulary['units'] as List<dynamic>? ?? const []) '$u'],
    );
  }

  /// An .xlsx: the items on the first sheet, and a second sheet listing the types and units the merchant may
  /// write — so a sheet filled on a computer speaks the merchant's own vocabulary.
  List<int> toXlsx({required String listsSheetName, required String typeHeader, required String groupHeader, required String unitsHeader}) {
    final excel = Excel.createExcel();
    final first = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(first, 'menu');
    final sheet = excel['menu'];
    sheet.appendRow([for (final c in columns) TextCellValue(c.label)]);
    for (final row in rows) {
      sheet.appendRow([
        for (final c in columns)
          switch (row[c.key]) {
            final num n => n == n.roundToDouble() ? IntCellValue(n.toInt()) : DoubleCellValue(n.toDouble()),
            null => TextCellValue(''),
            final v => TextCellValue('$v'),
          },
      ]);
    }

    final lists = excel[listsSheetName];
    lists.appendRow([TextCellValue(typeHeader), TextCellValue(groupHeader), TextCellValue(unitsHeader)]);
    final n = lines.length > units.length ? lines.length : units.length;
    for (var i = 0; i < n; i++) {
      lists.appendRow([
        TextCellValue(i < lines.length ? lines[i].name : ''),
        TextCellValue(i < lines.length ? lines[i].group : ''),
        TextCellValue(i < units.length ? units[i] : ''),
      ]);
    }

    return excel.encode() ?? const [];
  }
}

/// The FIRST sheet of an .xlsx as rows keyed by its header row — what `POST /business/menu/import` takes as
/// `rows` (the server knows the Arabic and English headers). Empty rows are dropped.
List<Map<String, String>> readXlsxRows(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) return const [];
  final table = excel.tables.values.first;
  if (table.rows.isEmpty) return const [];

  String text(Data? cell) {
    final v = cell?.value;
    if (v == null) return '';
    final s = switch (v) {
      final DoubleCellValue d => d.value == d.value.roundToDouble() ? d.value.toInt().toString() : d.value.toString(),
      _ => v.toString(),
    };
    return s.trim();
  }

  final header = [for (final c in table.rows.first) text(c)];
  final out = <Map<String, String>>[];
  for (final cells in table.rows.skip(1)) {
    final row = <String, String>{};
    for (var i = 0; i < header.length; i++) {
      if (header[i].isEmpty) continue;
      row[header[i]] = i < cells.length ? text(cells[i]) : '';
    }
    if (row.values.any((v) => v.isNotEmpty)) out.add(row);
  }
  return out;
}

/// What an import did (or, on a preview, would do) — per row of the sheet.
class MenuImportReport {
  final int created;
  final int updated;
  final int errors;
  final bool dryRun;
  final List<MenuImportRow> rows;

  const MenuImportReport({required this.created, required this.updated, required this.errors, required this.dryRun, required this.rows});

  factory MenuImportReport.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    return MenuImportReport(
      created: (summary['create'] as num?)?.toInt() ?? 0,
      updated: (summary['update'] as num?)?.toInt() ?? 0,
      errors: (summary['error'] as num?)?.toInt() ?? 0,
      dryRun: json['dry_run'] as bool? ?? true,
      rows: [for (final r in json['rows'] as List<dynamic>? ?? const []) MenuImportRow.fromJson(r as Map<String, dynamic>)],
    );
  }
}

class MenuImportRow {
  final int row;
  final String name;
  final String action;
  final List<String> errors;

  const MenuImportRow({required this.row, required this.name, required this.action, required this.errors});

  factory MenuImportRow.fromJson(Map<String, dynamic> json) => MenuImportRow(
    row: (json['row'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    action: json['action'] as String? ?? '',
    errors: [for (final e in json['errors'] as List<dynamic>? ?? const []) '$e'],
  );
}
