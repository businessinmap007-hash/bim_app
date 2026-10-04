import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  List<Map<String, String>>? _rows;
  ({List<int> bytes, String name})? _csv;
  MenuImportReport? _report;

  Future<void> _export({required bool template}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final sheet = await ref.read(businessMenuApiProvider).menuSheet(template: template);
      final bytes = sheet.toXlsx(
        listsSheetName: l10n.menuSheetListsSheet,
        typeHeader: l10n.menuSheetTypes,
        groupHeader: l10n.menuSheetGroup,
        unitsHeader: l10n.menuSheetUnits,
        howToHeader: l10n.menuSheetHowTo,
      );
      final name = template ? 'menu-template.xlsx' : 'menu.xlsx';
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(bytes),
            name: name,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        fileNameOverrides: [name],
      ));
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'csv'], withData: true);
    final file = picked?.files.single;
    if (file == null || file.bytes == null) return;

    setState(() {
      _error = null;
      _report = null;
      _rows = null;
      _csv = null;
    });
    try {
      if (file.name.toLowerCase().endsWith('.csv')) {
        _csv = (bytes: file.bytes!, name: file.name);
      } else {
        final rows = readXlsxRows(file.bytes!);
        if (rows.isEmpty) {
          setState(() => _error = l10n.menuSheetEmpty);
          return;
        }
        _rows = rows;
      }
      await _run(dryRun: true);
    } catch (_) {
      setState(() => _error = l10n.commonSomethingWentWrong);
    }
  }

  Future<void> _run({required bool dryRun}) async {
    final l10n = AppLocalizations.of(context)!;
    final api = ref.read(businessMenuApiProvider);
    setState(() => _busy = true);
    try {
      final report = _rows != null
          ? await api.importMenuRows(_rows!, dryRun: dryRun)
          : await api.importMenuCsv(_csv!.bytes, _csv!.name, dryRun: dryRun);
      setState(() => _report = report);
      if (!dryRun) {
        // The lists that show the items read them again.
        ref.read(menuItemsControllerProvider.notifier).load();
        ref.invalidate(menuVocabularyProvider);
      }
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
          if (_busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          if (report != null) ...[
            const SizedBox(height: 16),
            Text(report.dryRun ? l10n.menuSheetPreviewTitle : l10n.menuSheetDoneTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.menuSheetSummary(report.created, report.updated, report.errors), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            for (final row in report.rows)
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(row.name.isEmpty ? l10n.menuSheetRow(row.row) : row.name),
                  subtitle: Text([l10n.menuSheetRow(row.row), ...row.errors, ...row.warnings].join(' — ')),
                  trailing: Text(
                    switch (row.action) {
                      'create' => l10n.menuSheetActionCreate,
                      'update' => l10n.menuSheetActionUpdate,
                      _ => l10n.menuSheetActionError,
                    },
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: row.action == 'error' ? theme.colorScheme.error : (row.action == 'create' ? AppColors.success : theme.colorScheme.primary),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: report != null && report.dryRun && (report.created + report.updated) > 0
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
