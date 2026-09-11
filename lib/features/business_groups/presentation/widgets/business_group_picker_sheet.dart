import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_groups_providers.dart';
import '../../data/models/business_group.dart';

/// Picks one of the viewer's own saved business groups, or creates a new
/// one on the spot — pops the picked/created [BusinessGroup]. Shared
/// between a restricted retail listing's "add a group" action (which then
/// bulk-adds every member as audience) and a business profile page's "add
/// to offers group" icon (which then adds just that one business to the
/// picked group).
class BusinessGroupPickerSheet extends ConsumerWidget {
  const BusinessGroupPickerSheet({super.key});

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.businessGroupsCreate),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.businessGroupNameHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.commonCreate),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;

    try {
      await ref.read(businessGroupsControllerProvider.notifier).create(name);
      final created = ref.read(businessGroupsControllerProvider).groups.firstWhere((g) => g.name == name);
      if (context.mounted) Navigator.of(context).pop(created);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessGroupsControllerProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.retailListingBusinessGroupPickerTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.businessGroupsCreate),
                onTap: () => _createGroup(context, ref),
              ),
              const Divider(height: 1),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.groups.isEmpty
                    ? Center(child: Text(l10n.retailListingBusinessGroupPickerEmpty))
                    : ListView.separated(
                        itemCount: state.groups.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final group = state.groups[index];
                          return ListTile(
                            leading: const Icon(Icons.groups_outlined),
                            title: Text(group.name),
                            subtitle: Text(l10n.contactGroupMembersCount(group.membersCount)),
                            onTap: () => Navigator.of(context).pop(group),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
