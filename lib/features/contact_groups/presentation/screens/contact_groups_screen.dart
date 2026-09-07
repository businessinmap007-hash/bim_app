import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/contact_groups_providers.dart';
import 'contact_group_detail_screen.dart';

/// A user's own named contact groups ("العائلة", "أصدقاء دمياط") — created
/// once, then used to invite everyone in the group to a shared cart at
/// once (see ContactGroupDetailScreen and SharedCartScreen's group-invite
/// action) instead of typing a phone/email each time.
class ContactGroupsScreen extends ConsumerWidget {
  const ContactGroupsScreen({super.key});

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactGroupsCreate),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.contactGroupNameHint),
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
      await ref.read(contactGroupsControllerProvider.notifier).create(name);
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactGroupsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createGroup(context, ref),
        child: const Icon(Icons.add),
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
                    onPressed: () => ref.read(contactGroupsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.groups.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(l10n.contactGroupsEmpty, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(contactGroupsControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.groups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.groups_outlined),
                      title: Text(group.name),
                      subtitle: Text(l10n.contactGroupMembersCount(group.membersCount)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ContactGroupDetailScreen(groupId: group.id)),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
