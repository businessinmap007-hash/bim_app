import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/menu_bundle_providers.dart';
import '../../data/models/menu_bundle.dart';
import 'menu_bundle_edit_screen.dart';

class MenuBundlesScreen extends ConsumerWidget {
  const MenuBundlesScreen({super.key});

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const MenuBundleEditScreen()),
    );
    if (created == true) {
      ref.read(menuBundlesControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(menuBundlesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuBundlesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.menuBundleAdd),
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
                    onPressed: () => ref.read(menuBundlesControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.menuBundlesEmpty, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(menuBundlesControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final bundle = state.items[index];
                  return _BundleTile(
                    bundle: bundle,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MenuBundleEditScreen(bundleId: bundle.id)),
                      );
                      ref.read(menuBundlesControllerProvider.notifier).load();
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _BundleTile extends ConsumerWidget {
  final MenuBundle bundle;
  final VoidCallback onTap;
  const _BundleTile({required this.bundle, required this.onTap});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuBundleDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuBundlesControllerProvider.notifier).delete(bundle.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contents = bundle.items.map((i) => i.qty > 1 ? '${i.name} × ${i.qty}' : i.name).join('، ');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.fastfood_outlined)),
        title: Text(bundle.nameAr, style: TextStyle(color: bundle.isActive ? null : Theme.of(context).hintColor)),
        subtitle: Text(contents, maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: contents.isNotEmpty,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(bundle.price.toStringAsFixed(2)),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.commonDelete,
              onPressed: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
