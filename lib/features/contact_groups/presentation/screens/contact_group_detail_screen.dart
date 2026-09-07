import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/contact_groups_providers.dart';
import '../../data/models/contact_group.dart';

/// One group's members — add by phone/email (an already-registered account
/// only, same rule as a direct shared-cart invite), remove, rename, delete
/// the whole group. Reads the group back out of the shared
/// [contactGroupsControllerProvider] list rather than holding its own copy,
/// so a rename/add/remove here is instantly visible on the list screen too.
class ContactGroupDetailScreen extends ConsumerWidget {
  final int groupId;
  const ContactGroupDetailScreen({super.key, required this.groupId});

  ContactGroup? _group(ContactGroupsState state) {
    for (final g in state.groups) {
      if (g.id == groupId) return g;
    }
    return null;
  }

  Future<void> _addMember(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final identifier = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactGroupAddMember),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.sharedCartInviteHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.contactGroupAddAction),
          ),
        ],
      ),
    );
    if (identifier == null || identifier.isEmpty || !context.mounted) return;

    try {
      await ref.read(contactGroupsControllerProvider.notifier).addMember(groupId, identifier);
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiException ? (e.firstErrorFor('identifier') ?? e.message) : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _removeMember(BuildContext context, WidgetRef ref, int memberId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(contactGroupsControllerProvider.notifier).removeMember(groupId, memberId);
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
        title: Text(l10n.contactGroupRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.contactGroupNameHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == currentName || !context.mounted) return;

    try {
      await ref.read(contactGroupsControllerProvider.notifier).rename(groupId, name);
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
        content: Text(l10n.contactGroupDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(contactGroupsControllerProvider.notifier).delete(groupId);
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
    final state = ref.watch(contactGroupsControllerProvider);
    final group = _group(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? l10n.contactGroupsTitle),
        actions: [
          if (group != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') _rename(context, ref, group.name);
                if (value == 'delete') _deleteGroup(context, ref);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'rename', child: Text(l10n.contactGroupRename)),
                PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMember(context, ref),
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: group == null
          ? const SizedBox.shrink()
          : group.members.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(l10n.contactGroupNoMembers, textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: group.members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = group.members[index];
                return ListTile(
                  leading: const Icon(Icons.person_outline),
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
