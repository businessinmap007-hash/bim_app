import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_menu_providers.dart';
import '../../data/menu_sheet.dart';

/// «استيراد وتصدير المنيو» — المالك، 2026-10-05: «المنيو يحفظ فى ملف csv او اكسل ويضاف عليه ثم يتم
/// استيرادها للحساب». Export the items (or an empty template in the merchant's own vocabulary) as an Excel
/// file and share it; pick an Excel/CSV file, see what it would do, then confirm.
class MenuImportScreen extends ConsumerStatefulWidget {
  const MenuImportScreen({super.key});

  @override
  ConsumerState<MenuImportScreen> createState() => _MenuImportScreenState();
}

class _MenuImportScreenState extends ConsumerState<MenuImportScreen> {
  bool _busy = false;
  String? _error;

  /// What the picked file holds, kept for «تأكيد» after the preview.
  List<List<String>>? _grid;
  ({List<int> bytes, String name})? _csv;
  MenuFileInspect? _inspect;

  /// Our column key → the number of the column of the merchant's file it reads (null: not read).
  Map<String, int?> _mapping = {};
  MenuImportReport? _report;

  // The same file shape comes back to the same matching: remembered on this phone.
  String _memoryKey(List<String> headers) =>
      'bim_menu_import_map_${headers.join('|')}';

  Future<Map<String, int?>?> _remembered(List<String> headers) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(
        _memoryKey(headers),
      );
      if (raw == null) return null;
      return {
        for (final e in (jsonDecode(raw) as Map<String, dynamic>).entries)
          e.key: (e.value as num?)?.toInt(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _remember() async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        _memoryKey(_inspect!.headers),
        jsonEncode(_mapping),
      );
    } catch (_) {
      // a convenience only
    }
  }

  Future<void> _export({required bool template}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final sheet = await ref
          .read(businessMenuApiProvider)
          .menuSheet(template: template);
      final bytes = sheet.toXlsx(
        listsSheetName: l10n.menuSheetListsSheet,
        typeHeader: l10n.menuSheetTypes,
        groupHeader: l10n.menuSheetGroup,
        unitsHeader: l10n.menuSheetUnits,
        howToHeader: l10n.menuSheetHowTo,
      );
      final name = template ? 'menu-template.xlsx' : 'menu.xlsx';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(bytes),
              name: name,
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          ],
          fileNameOverrides: [name],
        ),
      );
    } catch (e) {
      setState(
        () => _error = e is ApiException
            ? e.message
            : l10n.commonSomethingWentWrong,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
      withData: true,
    );
    final file = picked?.files.single;
    if (file == null || file.bytes == null) return;

    setState(() {
      _error = null;
      _report = null;
      _grid = null;
      _csv = null;
      _inspect = null;
      _busy = true;
    });
    try {
      final api = ref.read(businessMenuApiProvider);
      final MenuFileInspect inspect;
      if (file.name.toLowerCase().endsWith('.csv')) {
        _csv = (bytes: file.bytes!, name: file.name);
        inspect = await api.inspectMenuFile(csv: _csv);
      } else {
        final grid = readXlsxGrid(file.bytes!);
        if (grid.length < 2) {
          setState(() => _error = l10n.menuSheetEmpty);
          return;
        }
        _grid = grid;
        inspect = await api.inspectMenuFile(grid: grid);
      }
      final remembered = await _remembered(inspect.headers);
      setState(() {
        _inspect = inspect;
        _mapping = remembered ?? Map<String, int?>.from(inspect.mapping);
      });
    } catch (e) {
      setState(
        () => _error = e is ApiException
            ? e.message
            : l10n.commonSomethingWentWrong,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run({required bool dryRun}) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(businessMenuApiProvider);
    setState(() => _busy = true);
    try {
      if (dryRun) await _remember();
      final report = await api.importMenuMapped(
        grid: _grid,
        csv: _csv,
        mapping: _mapping,
        dryRun: dryRun,
      );
      setState(() => _report = report);
      if (!dryRun) {
        // The lists that show the items read them again.
        ref.read(menuItemsControllerProvider.notifier).load();
        ref.invalidate(menuVocabularyProvider);
      }
    } catch (e) {
      setState(
        () => _error = e is ApiException
            ? e.message
            : l10n.commonSomethingWentWrong,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// «ربط الأعمدة بالترقيم»: the file's columns numbered, and one picker per column of ours.
  Widget _buildMapping(BuildContext context, MenuFileInspect inspect) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String header(int i) =>
        '${i + 1} - ${inspect.headers[i].isEmpty ? l10n.menuSheetMapColumn(i + 1) : inspect.headers[i]}';

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.menuSheetMapTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.menuSheetMapHint, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                l10n.menuSheetMapRows(inspect.totalRows),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.menuSheetMapFileColumns,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < inspect.headers.length; i++)
                Text(header(i), style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              Text(
                l10n.menuSheetMapOurColumns,
                style: theme.textTheme.labelLarge,
              ),
              for (var n = 0; n < inspect.columns.length; n++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text('${n + 1} - ${inspect.columns[n].label}'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField<int?>(
                          key: ValueKey(
                            '${inspect.columns[n].key}-${_mapping[inspect.columns[n].key]}',
                          ),
                          isExpanded: true,
                          initialValue: _mapping[inspect.columns[n].key],
                          decoration: const InputDecoration(isDense: true),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(l10n.menuSheetMapNone),
                            ),
                            for (var i = 0; i < inspect.headers.length; i++)
                              DropdownMenuItem<int?>(
                                value: i + 1,
                                child: Text(
                                  header(i),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(
                            () => _mapping[inspect.columns[n].key] = v,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: _busy ? null : () => _run(dryRun: true),
                    child: Text(l10n.menuSheetMapPreview),
                  ),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => setState(
                            () => _mapping = Map<String, int?>.from(
                              inspect.mapping,
                            ),
                          ),
                    child: Text(l10n.menuSheetMapReset),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final report = _report;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuSheetTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.menuSheetExportHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : () => _export(template: false),
                icon: const Icon(Icons.file_download_outlined),
                label: Text(l10n.menuSheetExportItems),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _export(template: true),
                icon: const Icon(Icons.description_outlined),
                label: Text(l10n.menuSheetExportTemplate),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(l10n.menuSheetImportHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(l10n.menuSheetImport),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          if (_inspect != null) _buildMapping(context, _inspect!),
          if (report != null) ...[
            const SizedBox(height: 16),
            Text(
              report.dryRun
                  ? l10n.menuSheetPreviewTitle
                  : l10n.menuSheetDoneTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.menuSheetSummary(
                report.created,
                report.updated,
                report.errors,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            for (final row in report.rows)
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(
                    row.name.isEmpty ? l10n.menuSheetRow(row.row) : row.name,
                  ),
                  subtitle: Text(
                    [
                      l10n.menuSheetRow(row.row),
                      ...row.errors,
                      ...row.warnings,
                    ].join(' — '),
                  ),
                  trailing: Text(
                    switch (row.action) {
                      'create' => l10n.menuSheetActionCreate,
                      'update' => l10n.menuSheetActionUpdate,
                      'section' => l10n.menuSheetActionSection,
                      _ => l10n.menuSheetActionError,
                    },
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: row.action == 'error'
                          ? theme.colorScheme.error
                          : (row.action == 'create'
                                ? AppColors.success
                                : theme.colorScheme.primary),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar:
          report != null &&
              report.dryRun &&
              (report.created + report.updated) > 0
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: FilledButton(
                onPressed: _busy ? null : () => _run(dryRun: false),
                child: Text(l10n.menuSheetConfirm),
              ),
            )
          : null,
    );
  }
}
