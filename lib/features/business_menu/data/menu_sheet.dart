import 'package:excel/excel.dart';

/// «استيراد وتصدير المنيو» — the menu as a sheet (`GET /business/menu/sheet`): the columns in the app's
/// language, the merchant's items as rows (or two example rows for a template), and what «النوع» and
/// «الوحدة» may say. See Api\V2\BusinessMenuSheetController.
class MenuSheetData {
  final List<({String key, String label})> columns;
  final List<Map<String, dynamic>> rows;
  final List<({String name, String group})> lines;
  final List<String> units;

  /// How the cells that hold more than one thing are written (sizes, extras, photos, barcode).
  final List<String> help;

  const MenuSheetData({
    required this.columns,
    required this.rows,
    required this.lines,
    required this.units,
    this.help = const [],
  });

  factory MenuSheetData.fromJson(Map<String, dynamic> json) {
    final vocabulary = json['vocabulary'] as Map<String, dynamic>? ?? const {};
    return MenuSheetData(
      columns: [
        for (final c in json['columns'] as List<dynamic>? ?? const [])
          (
            key: '${(c as Map<String, dynamic>)['key']}',
            label: '${c['label']}',
          ),
      ],
      rows: [
        for (final r in json['rows'] as List<dynamic>? ?? const [])
          Map<String, dynamic>.from(r as Map),
      ],
      lines: [
        for (final l in vocabulary['lines'] as List<dynamic>? ?? const [])
          (
            name: '${(l as Map<String, dynamic>)['name']}',
            group: '${l['group']}',
          ),
      ],
      units: [
        for (final u in vocabulary['units'] as List<dynamic>? ?? const []) '$u',
      ],
      help: [
        for (final h in vocabulary['help'] as List<dynamic>? ?? const []) '$h',
      ],
    );
  }

  /// An .xlsx: the items on the first sheet, and a second sheet listing the types and units the merchant may
  /// write — so a sheet filled on a computer speaks the merchant's own vocabulary.
  List<int> toXlsx({
    required String listsSheetName,
    required String typeHeader,
    required String groupHeader,
    required String unitsHeader,
    String howToHeader = '',
  }) {
    final excel = Excel.createExcel();
    final first = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(first, 'menu');
    final sheet = excel['menu'];
    sheet.appendRow([for (final c in columns) TextCellValue(c.label)]);
    for (final row in rows) {
      sheet.appendRow([
        for (final c in columns)
          switch (row[c.key]) {
            final num n =>
              n == n.roundToDouble()
                  ? IntCellValue(n.toInt())
                  : DoubleCellValue(n.toDouble()),
            null => TextCellValue(''),
            final v => TextCellValue('$v'),
          },
      ]);
    }

    final lists = excel[listsSheetName];
    lists.appendRow([
      TextCellValue(typeHeader),
      TextCellValue(groupHeader),
      TextCellValue(unitsHeader),
      TextCellValue(howToHeader),
    ]);
    final n = [
      lines.length,
      units.length,
      help.length,
    ].reduce((a, b) => a > b ? a : b);
    for (var i = 0; i < n; i++) {
      lists.appendRow([
        TextCellValue(i < lines.length ? lines[i].name : ''),
        TextCellValue(i < lines.length ? lines[i].group : ''),
        TextCellValue(i < units.length ? units[i] : ''),
        TextCellValue(i < help.length ? help[i] : ''),
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
      final DoubleCellValue d =>
        d.value == d.value.roundToDouble()
            ? d.value.toInt().toString()
            : d.value.toString(),
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

/// The FIRST sheet of an .xlsx as a grid of cells, header row first — what `POST /business/menu/inspect` and
/// `import` take as `grid`, so the merchant can point each of our columns at a column NUMBER of his own file.
List<List<String>> readXlsxGrid(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) return const [];

  String text(Data? cell) {
    final v = cell?.value;
    if (v == null) return '';
    final s = switch (v) {
      final DoubleCellValue d =>
        d.value == d.value.roundToDouble()
            ? d.value.toInt().toString()
            : d.value.toString(),
      _ => v.toString(),
    };
    return s.trim();
  }

  final grid = [
    for (final cells in excel.tables.values.first.rows)
      [for (final c in cells) text(c)],
  ];
  return grid.where((r) => r.any((v) => v.isNotEmpty)).toList();
}

/// What a picked file looks like before importing (`POST /business/menu/inspect`): its numbered headers, a few
/// rows, and the server's guess at which of its columns is which of ours.
class MenuFileInspect {
  final List<String> headers;
  final List<List<String>> sample;
  final int totalRows;

  /// Our column key → the file's column NUMBER (1-based), null when the file has no column we recognise for it.
  final Map<String, int?> mapping;
  final List<({String key, String label})> columns;

  const MenuFileInspect({
    required this.headers,
    required this.sample,
    required this.totalRows,
    required this.mapping,
    required this.columns,
  });

  factory MenuFileInspect.fromJson(Map<String, dynamic> json) =>
      MenuFileInspect(
        headers: [
          for (final h in json['headers'] as List<dynamic>? ?? const []) '$h',
        ],
        sample: [
          for (final r in json['sample'] as List<dynamic>? ?? const [])
            [for (final c in r as List<dynamic>) '$c'],
        ],
        totalRows: (json['total_rows'] as num?)?.toInt() ?? 0,
        mapping: {
          for (final e
              in (json['mapping'] as Map<String, dynamic>? ?? const {}).entries)
            e.key: (e.value as num?)?.toInt(),
        },
        columns: [
          for (final c in json['columns'] as List<dynamic>? ?? const [])
            (
              key: '${(c as Map<String, dynamic>)['key']}',
              label: '${c['label']}',
            ),
        ],
      );
}

/// What an import did (or, on a preview, would do) — per row of the sheet.
class MenuImportReport {
  final int created;
  final int updated;
  final int errors;
  final bool dryRun;
  final List<MenuImportRow> rows;

  const MenuImportReport({
    required this.created,
    required this.updated,
    required this.errors,
    required this.dryRun,
    required this.rows,
  });

  factory MenuImportReport.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    return MenuImportReport(
      created: (summary['create'] as num?)?.toInt() ?? 0,
      updated: (summary['update'] as num?)?.toInt() ?? 0,
      errors: (summary['error'] as num?)?.toInt() ?? 0,
      dryRun: json['dry_run'] as bool? ?? true,
      rows: [
        for (final r in json['rows'] as List<dynamic>? ?? const [])
          MenuImportRow.fromJson(r as Map<String, dynamic>),
      ],
    );
  }
}

class MenuImportRow {
  final int row;
  final String name;
  final String action;
  final List<String> errors;

  /// The row went in, with a note: a photo that could not be fetched, a barcode not in the catalog…
  final List<String> warnings;

  const MenuImportRow({
    required this.row,
    required this.name,
    required this.action,
    required this.errors,
    this.warnings = const [],
  });

  factory MenuImportRow.fromJson(Map<String, dynamic> json) => MenuImportRow(
    row: (json['row'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    action: json['action'] as String? ?? '',
    errors: [
      for (final e in json['errors'] as List<dynamic>? ?? const []) '$e',
    ],
    warnings: [
      for (final w in json['warnings'] as List<dynamic>? ?? const []) '$w',
    ],
  );
}
