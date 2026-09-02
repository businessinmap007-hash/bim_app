import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_section.dart';

class MenuSectionsScreen extends ConsumerWidget {
  const MenuSectionsScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {BusinessMenuSection? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final nameArController = TextEditingController(text: existing?.nameAr ?? '');
    final nameEnController = TextEditingController(text: existing?.nameEn ?? '');
    final sortController = TextEditingController(text: '${existing?.sortOrder ?? 0}');
    bool isActive = existing?.isActive ?? true;
    String? error;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? l10n.menuSectionAddTitle : l10n.menuSectionEditTitle,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameArController,
                    decoration: InputDecoration(labelText: l10n.menuItemNameArHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameEnController,
                    decoration: InputDecoration(labelText: l10n.menuItemNameEnHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sortController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.menuItemSortOrderHint),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.menuItemActiveLabel),
                    value: isActive,
                    onChanged: (v) => setSheetState(() => isActive = v),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (nameArController.text.trim().isEmpty) {
                        setSheetState(() => error = l10n.menuNameRequired);
                        return;
                      }
                      try {
                        if (existing == null) {
                          await ref.read(menuSectionsControllerProvider.notifier).create(
                                nameAr: nameArController.text.trim(),
                                nameEn: nameEnController.text.trim(),
                                sortOrder: int.tryParse(sortController.text.trim()) ?? 0,
                                isActive: isActive,
                              );
                        } else {
                          await ref.read(menuSectionsControllerProvider.notifier).update(
                                existing.id,
                                nameAr: nameArController.text.trim(),
                                nameEn: nameEnController.text.trim(),
                                sortOrder: int.tryParse(sortController.text.trim()) ?? 0,
                                isActive: isActive,
                              );
                        }
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop(true);
                      } catch (_) {
                        setSheetState(() => error = l10n.commonSomethingWentWrong);
                      }
                    },
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      // MenuSectionsController already reloads itself after create/update.
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, BusinessMenuSection section) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuSectionDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuSectionsControllerProvider.notifier).delete(section.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(menuSectionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuSectionsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.menuSectionAdd),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(menuSectionsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.menuSectionsEmpty))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final section = state.items[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(section.nameAr, style: TextStyle(color: section.isActive ? null : Theme.of(context).hintColor)),
                    subtitle: section.nameEn != null ? Text(section.nameEn!) : null,
                    onTap: () => _openForm(context, ref, existing: section),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, ref, section),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
