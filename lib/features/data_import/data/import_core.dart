/// «أداة استيراد شاملة» — المالك، 2026-10-10: any business opens its own tables, sees our column names against the
/// names in its Excel/CSV file, links them, and brings its old data in instead of building from zero.
///
/// This file is the shared core: reading a CSV, guessing which file column is which of ours, and reading a date.
library;

/// One column the target understands: [key] is what [ImportTarget] reads, [label] is what the owner sees, and
/// [aliases] are the other names such a column commonly has in a sheet (Arabic and English).
class ImportField {
  final String key;
  final String label;
  final bool required;
  final List<String> aliases;

  const ImportField({required this.key, required this.label, this.required = false, this.aliases = const []});
}

/// A file's header row compared without case, diacritics, hamza forms, spaces or punctuation.
String normalizeHeader(String raw) => raw
    .replaceAll(RegExp(r'[ً-ْـ]'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ة', 'ه')
    .toLowerCase()
    .replaceAll(RegExp(r'[\s_\-/.:()]+'), '');

/// Our field key → the file column's index (0-based), guessed from the headers: an exact match on the label or an
/// alias wins; a header that merely contains one is the fallback. A file column is used for ONE field only.
Map<String, int?> suggestMapping(List<String> headers, List<ImportField> fields) {
  final heads = [for (final h in headers) normalizeHeader(h)];
  final used = <int>{};
  final out = <String, int?>{for (final f in fields) f.key: null};

  int? find(ImportField f, {required bool exact}) {
    final names = [normalizeHeader(f.label), for (final a in f.aliases) normalizeHeader(a)].where((n) => n.isNotEmpty);
    for (var i = 0; i < heads.length; i++) {
      if (used.contains(i) || heads[i].isEmpty) continue;
      for (final n in names) {
        if (exact ? heads[i] == n : (heads[i].contains(n) || n.contains(heads[i]))) return i;
      }
    }

    return null;
  }

  for (final f in fields) {
    final i = find(f, exact: true);
    if (i != null) {
      out[f.key] = i;
      used.add(i);
    }
  }
  for (final f in fields) {
    if (out[f.key] != null) continue;
    final i = find(f, exact: false);
    if (i != null) {
      out[f.key] = i;
      used.add(i);
    }
  }

  return out;
}

/// CSV text → rows of cells. Handles quotes, doubled quotes, line breaks inside quotes, a BOM, and the delimiter
/// (comma, semicolon or tab — whichever the first line uses most).
List<List<String>> parseCsv(String input) {
  var text = input.startsWith('﻿') ? input.substring(1) : input;
  if (text.isEmpty) return const [];

  final firstLine = text.split(RegExp(r'\r?\n')).first;
  var delimiter = ',';
  var best = -1;
  for (final d in [',', ';', '\t']) {
    final n = d.allMatches(firstLine).length;
    if (n > best) {
      best = n;
      delimiter = d;
    }
  }

  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;

  void endCell() {
    row.add(cell.toString().trim());
    cell.clear();
  }

  void endRow() {
    endCell();
    if (row.any((c) => c.isNotEmpty)) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (quoted) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      quoted = true;
    } else if (ch == delimiter) {
      endCell();
    } else if (ch == '\n') {
      endRow();
    } else if (ch != '\r') {
      cell.write(ch);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) endRow();

  return rows;
}

/// A date as a sheet writes it: ISO, `d/m/y` (Egypt writes the day first), `d-m-y`, `d.m.y`, an Excel serial number,
/// or the stringified date an Excel cell gives. Null when it is not a date.
DateTime? parseSheetDate(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;

  final iso = DateTime.tryParse(s.length >= 10 ? s.substring(0, 10) : s);
  if (iso != null && RegExp(r'^\d{4}-\d{1,2}-\d{1,2}').hasMatch(s)) return DateTime(iso.year, iso.month, iso.day);

  final dmy = RegExp(r'^(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})').firstMatch(s);
  if (dmy != null) {
    final d = int.parse(dmy.group(1)!);
    final m = int.parse(dmy.group(2)!);
    var y = int.parse(dmy.group(3)!);
    if (y < 100) y += y > 50 ? 1900 : 2000;
    if (m >= 1 && m <= 12 && d >= 1 && d <= 31) return DateTime(y, m, d);
  }

  final serial = double.tryParse(s);
  if (serial != null && serial > 20000 && serial < 80000) {
    return DateTime(1899, 12, 30).add(Duration(days: serial.floor()));
  }

  return null;
}
