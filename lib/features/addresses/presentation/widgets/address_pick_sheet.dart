import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../application/addresses_providers.dart';

typedef AddressPickResult = ({int? addressId, String? freeText, String label});

/// A saved address, or fall back to free text — the same two-source pattern
/// checkout and prescription delivery already accept on the backend
/// (`address_id` wins over `delivery_address` when both are sent).
Future<AddressPickResult?> showAddressPickSheet(BuildContext context) {
  return showModalBottomSheet<AddressPickResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddressPickSheet(),
  );
}

class _AddressPickSheet extends ConsumerStatefulWidget {
  const _AddressPickSheet();

  @override
  ConsumerState<_AddressPickSheet> createState() => _AddressPickSheetState();
}

class _AddressPickSheetState extends ConsumerState<_AddressPickSheet> {
  final _freeTextController = TextEditingController();
  bool _typingNew = false;
  bool _saving = false;
  LocationSelection? _location;

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final state = ref.watch(addressesControllerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.addressPickTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (state.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final address in state.items)
                        ListTile(
                          leading: Icon(address.isPrimary ? Icons.star : Icons.location_on_outlined),
                          title: Text(address.addressLine, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            [
                              address.governorate?.localizedName(languageCode),
                              address.city?.localizedName(languageCode),
                            ].whereType<String>().where((s) => s.isNotEmpty).join(' — '),
                          ),
                          onTap: () => Navigator.of(context).pop((
                            addressId: address.id,
                            freeText: null,
                            label: address.summary(languageCode),
                          )),
                        ),
                    ],
                  ),
                ),
              const Divider(),
              if (!_typingNew)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.addressUseNewLabel),
                  onTap: () => setState(() => _typingNew = true),
                )
              else ...[
                LocationPickerField(value: _location, onChanged: (v) => setState(() => _location = v)),
                const SizedBox(height: 12),
                TextField(
                  controller: _freeTextController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: l10n.addressLineHint),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          final text = _freeTextController.text.trim();
                          final location = _location;
                          if (text.length < 5 || location == null) return;
                          setState(() => _saving = true);
                          try {
                            final saved = await ref.read(addressesApiProvider).create(
                              governorateId: location.governorateId,
                              cityId: location.cityId,
                              addressLine: text,
                            );
                            await ref.read(addressesControllerProvider.notifier).load();
                            if (context.mounted) {
                              Navigator.of(context).pop((
                                addressId: saved.id,
                                freeText: null,
                                label: '$text (${location.label})',
                              ));
                            }
                          } catch (_) {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                  child: Text(l10n.addressSaveAndUse),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
