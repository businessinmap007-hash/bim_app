import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/addresses_providers.dart';
import '../../data/models/address.dart';
import '../widgets/address_form_sheet.dart';

/// The saved-address book — reused wherever a delivery flow already accepts
/// a saved `address_id` alongside its free-text fallback (checkout,
/// prescription delivery). See Api\V2\AddressController.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Address address) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.addressDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(addressesControllerProvider.notifier).delete(address.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final state = ref.watch(addressesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addressesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddressFormSheet(context),
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
                    onPressed: () => ref.read(addressesControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.addressesEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(addressesControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final address = state.items[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      onTap: () => showAddressFormSheet(context, existing: address),
                      leading: Icon(
                        address.isPrimary ? Icons.star : Icons.location_on_outlined,
                        color: address.isPrimary ? Theme.of(context).colorScheme.primary : null,
                      ),
                      title: Text(address.addressLine, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        [
                          address.governorate?.localizedName(languageCode),
                          address.city?.localizedName(languageCode),
                        ].whereType<String>().where((s) => s.isNotEmpty).join(' — '),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'primary') {
                            ref.read(addressesControllerProvider.notifier).setPrimary(address.id);
                          } else if (action == 'delete') {
                            _delete(context, ref, address);
                          }
                        },
                        itemBuilder: (context) => [
                          if (!address.isPrimary)
                            PopupMenuItem(value: 'primary', child: Text(l10n.addressMakePrimary)),
                          PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
