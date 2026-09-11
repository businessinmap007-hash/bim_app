import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/business_picker_sheet.dart';
import '../../../discovery/data/models/business_summary.dart';
import '../../application/business_groups_providers.dart';
import '../../data/models/business_group.dart';

/// One group's members — add by search (any business on the platform),
/// remove, rename, delete the whole group. Reads the group back out of the
/// shared [businessGroupsControllerProvider] list rather than holding its
/// own copy, so a rename/add/remove here is instantly visible on the list
/// screen too.
class BusinessGroupDetailScreen extends ConsumerWidget {
  final int groupId;
  const BusinessGroupDetailScreen({super.key, required this.groupId});

  BusinessGroup? _group(BusinessGroupsState state) {
    for (final g in state.groups) {
      if (g.id == groupId) return g;
    }
    return null;
  }

  Future<void> _addMember(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showModalBottomSheet<BusinessSummary>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const BusinessPickerSheet(),
    );
    if (picked == null || !context.mounted) return;

    try {
      await ref.read(businessGroupsControllerProvider.notifier).addMember(groupId, picked.id);
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiException ? (e.firstErrorFor('business_id') ?? e.message) : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _removeMember(BuildContext context, WidgetRef ref, int memberId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(businessGroupsControllerProvider.notifier).removeMember(groupId, memberId);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, String currentName) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.businessGroupRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.businessGroupNameHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == currentName || !context.mounted) return;

    try {
      await ref.read(businessGroupsControllerProvider.notifier).rename(groupId, name);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  Future<void> _deleteGroup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.businessGroupDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(businessGroupsControllerProvider.notifier).delete(groupId);
      if (context.mounted) Navigator.of(context).pop();
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
    final group = _group(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? l10n.businessGroupsTitle),
        actions: [
          if (group != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') _rename(context, ref, group.name);
                if (value == 'delete') _deleteGroup(context, ref);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'rename', child: Text(l10n.businessGroupRename)),
                PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMember(context, ref),
        child: const Icon(Icons.add_business_outlined),
      ),
      body: group == null
          ? const SizedBox.shrink()
          : group.members.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(l10n.businessGroupNoMembers, textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: group.members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = group.members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: member.logoUrl != null ? NetworkImage(member.logoUrl!) : null,
                    child: member.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                  ),
                  title: Text(member.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeMember(context, ref, member.id),
                  ),
                );
              },
            ),
    );
  }
}
