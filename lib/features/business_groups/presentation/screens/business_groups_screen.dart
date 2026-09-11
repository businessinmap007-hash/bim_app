import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_groups_providers.dart';
import 'business_group_detail_screen.dart';

/// A business's own named groups of OTHER businesses ("محلات الخضار",
/// "مصانع الأثاث") — created once, then used to name a whole circle of
/// wholesale buyers on a restricted retail listing in one tap (see
/// BusinessGroupDetailScreen and the retail listing form's "add a group"
/// action) instead of searching for each business every time.
class BusinessGroupsScreen extends ConsumerWidget {
  const BusinessGroupsScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessGroupsTitle)),
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
                    onPressed: () => ref.read(businessGroupsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.groups.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(l10n.businessGroupsEmpty, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(businessGroupsControllerProvider.notifier).load(),
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
                        MaterialPageRoute(builder: (_) => BusinessGroupDetailScreen(groupId: group.id)),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
