import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business_menu/data/menu_sheet.dart' show readXlsxGrid;
import '../../data/import_core.dart';

/// What an import did, in words the owner reads.
class ImportSummary {
  final int created;
  final int merged;
  final List<({int row, String reason})> skipped;

  const ImportSummary({this.created = 0, this.merged = 0, this.skipped = const []});
}

/// The one import screen every target uses: pick an Excel or CSV file, see its columns next to ours, link them, and
/// bring the rows in. The file is read on THIS device; what [apply] does with the rows decides where they go.
class ImportWizardScreen extends StatefulWidget {
  final String title;
  final String intro;

  /// Remembered column links are kept per target and per file shape (the same sheet comes back to the same links).
  final String memoryKey;
  final List<ImportField> fields;
  final String templateName;

  /// Receives the whole grid (header row first) and the links: our field key → file column (0-based).
  final Future<ImportSummary> Function(List<List<String>> grid, Map<String, int?> mapping) apply;

  const ImportWizardScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.memoryKey,
    required this.fields,
    required this.apply,
    this.templateName = 'template.xlsx',
  });

  @override
  State<ImportWizardScreen> createState() => _ImportWizardScreenState();
}

class _ImportWizardScreenState extends State<ImportWizardScreen> {
  List<List<String>>? _grid;
  String _fileName = '';
  Map<String, int?> _mapping = {};
  bool _busy = false;
  String? _error;
  ImportSummary? _summary;

  List<String> get _headers => _grid == null ? const [] : _grid!.first;

  String _memory(List<String> headers) => 'bim_import_map_${widget.memoryKey}_${headers.join('|')}';

  Future<Map<String, int?>?> _remembered(List<String> headers) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_memory(headers));
      if (raw == null) return null;
      return {for (final e in (jsonDecode(raw) as Map<String, dynamic>).entries) e.key: (e.value as num?)?.toInt()};
    } catch (_) {
      return null;
    }
  }

  Future<void> _remember() async {
    try {
      await (await SharedPreferences.getInstance()).setString(_memory(_headers), jsonEncode(_mapping));
    } catch (_) {
      // a convenience only
    }
  }

  Future<void> _template() async {
    final excel = Excel.createExcel();
    final first = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(first, 'data');
    excel['data'].appendRow([for (final f in widget.fields) TextCellValue(f.label)]);
    final bytes = excel.encode();
    if (bytes == null) return;

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(bytes),
            name: widget.templateName,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        fileNameOverrides: [widget.templateName],
      ),
    );
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'csv'], withData: true);
    final file = picked?.files.single;
    if (file == null || file.bytes == null) return;

    setState(() {
      _error = null;
      _summary = null;
      _grid = null;
      _busy = true;
    });

    try {
      final lower = file.name.toLowerCase();
      final grid = lower.endsWith('.csv') ? parseCsv(utf8.decode(file.bytes!, allowMalformed: true)) : readXlsxGrid(file.bytes!);
      if (grid.length < 2) {
        setState(() => _error = l10n.importFileEmpty);
        return;
      }

      final headers = grid.first;
      final remembered = await _remembered(headers);
      setState(() {
        _grid = grid;
        _fileName = file.name;
        _mapping = remembered ?? suggestMapping(headers, widget.fields);
      });
    } catch (_) {
      setState(() => _error = l10n.importFileUnreadable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool get _ready => _grid != null && widget.fields.where((f) => f.required).every((f) => _mapping[f.key] != null);

  Future<void> _run() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _remember();
      final summary = await widget.apply(_grid!, _mapping);
      if (mounted) setState(() => _summary = summary);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _sample(int column) {
    for (var r = 1; r < _grid!.length && r <= 6; r++) {
      final row = _grid![r];
      if (column < row.length && row[column].isNotEmpty) return row[column];
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.intro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(onPressed: _busy ? null : _pick, icon: const Icon(Icons.upload_file_outlined), label: Text(l10n.importPickFile)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(onPressed: _busy ? null : _template, icon: const Icon(Icons.download_outlined), label: Text(l10n.importTemplate)),
            ],
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
          if (_grid != null) ...[
            const SizedBox(height: 16),
            Text(l10n.importFileInfo(_fileName, _grid!.length - 1), style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l10n.importMapHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 10),
            for (final f in widget.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(f.required ? '${f.label} *' : f.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: f.required ? FontWeight.w700 : null)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _mapping[f.key],
                        isExpanded: true,
                        decoration: const InputDecoration(isDense: true),
                        items: [
                          DropdownMenuItem<int?>(value: null, child: Text(l10n.importNotUsed)),
                          for (var i = 0; i < _headers.length; i++)
                            DropdownMenuItem<int?>(
                              value: i,
                              child: Text(
                                '${i + 1}. ${_headers[i].isEmpty ? l10n.importUnnamedColumn : _headers[i]}${_sample(i).isEmpty ? '' : '  —  ${_sample(i)}'}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _mapping = {..._mapping, f.key: v}),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            FilledButton(onPressed: _ready && !_busy ? _run : null, child: Text(l10n.importRun(_grid!.length - 1))),
            if (!_ready) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l10n.importRequiredMissing, style: theme.textTheme.bodySmall)),
          ],
          if (_summary != null) ...[
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.importDone, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(l10n.importCreated(_summary!.created)),
                    if (_summary!.merged > 0) Text(l10n.importMerged(_summary!.merged)),
                    if (_summary!.skipped.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(l10n.importSkipped(_summary!.skipped.length), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                      for (final s in _summary!.skipped.take(8)) Text(l10n.importSkippedRow(s.row, s.reason), style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
