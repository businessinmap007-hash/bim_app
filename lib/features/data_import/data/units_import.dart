import '../../booking_settings/data/models/booking_settings_models.dart' show NamedOption;
import 'import_core.dart';

/// The columns a hotel's (or a court's, a hall's) old sheet of units may have. One row is one unit — a room, a
/// court, a hall. The service and the unit type are chosen once for the whole file, not per row.
const unitImportFields = <ImportField>[
  ImportField(
    key: 'code',
    label: 'رقم الوحدة',
    required: true,
    aliases: ['رقم الغرفة', 'الغرفة', 'الوحدة', 'الكود', 'كود', 'رقم', 'room', 'room no', 'room number', 'code', 'number', 'unit', 'no'],
  ),
  ImportField(key: 'title', label: 'الاسم', aliases: ['اسم الوحدة', 'اسم الغرفة', 'العنوان', 'title', 'name']),
  ImportField(key: 'kind', label: 'النوع', aliases: ['نوع الغرفة', 'نوع الوحدة', 'الفئة', 'التصنيف', 'type', 'room type', 'kind', 'category']),
  ImportField(key: 'capacity', label: 'السعة', aliases: ['عدد الاشخاص', 'عدد الأفراد', 'الافراد', 'سعة', 'capacity', 'guests', 'persons', 'pax']),
  ImportField(key: 'quantity', label: 'العدد', aliases: ['الكمية', 'عدد الغرف', 'عدد', 'quantity', 'qty', 'count']),
  ImportField(key: 'description', label: 'الوصف', aliases: ['وصف', 'تفاصيل', 'ملاحظات', 'description', 'details', 'notes']),
];

/// One row of the sheet, read.
class UnitDraft {
  final int row;
  final String code;
  final String? title;
  final String kindText;
  final int? capacity;
  final int quantity;
  final String? description;

  const UnitDraft({
    required this.row,
    required this.code,
    this.title,
    this.kindText = '',
    this.capacity,
    this.quantity = 1,
    this.description,
  });
}

class UnitsImportResult {
  final List<UnitDraft> units;

  /// 1-based sheet row numbers (header = 1) with the reason a row was left out.
  final List<({int row, String reason})> skipped;

  const UnitsImportResult({required this.units, required this.skipped});
}

/// A whole number as a sheet writes it: Western or Arabic-Indic digits, a trailing `.0` from Excel. Null if none.
int? parseWholeNumber(String raw) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  final buffer = StringBuffer();
  for (final ch in raw.trim().split('')) {
    final i = arabic.indexOf(ch);
    buffer.write(i >= 0 ? '$i' : ch);
  }
  final match = RegExp(r'^(\d+)(?:[.,]0+)?$').firstMatch(buffer.toString());

  return match == null ? null : int.tryParse(match.group(1)!);
}

/// The unit kind a cell names: the merchant's own option whose name equals it (ignoring hamza, diacritics and case),
/// else the one that contains it or is contained in it. Null when nothing matches.
NamedOption? matchKind(String text, List<NamedOption> options) {
  final wanted = normalizeHeader(text);
  if (wanted.isEmpty) return null;

  for (final o in options) {
    if (normalizeHeader(o.name) == wanted) return o;
  }
  for (final o in options) {
    final n = normalizeHeader(o.name);
    if (n.isNotEmpty && (n.contains(wanted) || wanted.contains(n))) return o;
  }

  return null;
}

/// Turn a sheet (header row first) into unit drafts, reading the columns [mapping] points at. A repeated code in the
/// file is left out after its first appearance.
UnitsImportResult unitsFromGrid(List<List<String>> grid, Map<String, int?> mapping) {
  if (grid.length < 2) return const UnitsImportResult(units: [], skipped: []);

  String cell(List<String> row, String key) {
    final i = mapping[key];
    if (i == null || i < 0 || i >= row.length) return '';

    return row[i].trim();
  }

  final seen = <String>{};
  final units = <UnitDraft>[];
  final skipped = <({int row, String reason})>[];

  for (var r = 1; r < grid.length; r++) {
    final row = grid[r];
    final code = cell(row, 'code');
    if (code.isEmpty) {
      if (row.any((c) => c.trim().isNotEmpty)) skipped.add((row: r + 1, reason: 'بلا رقم'));
      continue;
    }
    if (!seen.add(normalizeHeader(code))) {
      skipped.add((row: r + 1, reason: 'رقم مكرر في الملف'));
      continue;
    }

    final capacity = parseWholeNumber(cell(row, 'capacity'));
    final quantity = parseWholeNumber(cell(row, 'quantity'));
    final title = cell(row, 'title');
    final description = cell(row, 'description');

    units.add(
      UnitDraft(
        row: r + 1,
        code: code,
        title: title.isEmpty ? null : title,
        kindText: cell(row, 'kind'),
        capacity: capacity != null && capacity > 0 ? capacity : null,
        quantity: quantity != null && quantity > 0 ? quantity : 1,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  return UnitsImportResult(units: units, skipped: skipped);
}
