import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../application/addresses_providers.dart';
import '../../data/models/address.dart';

/// Add/edit sheet for one saved address. Returns nothing — callers just
/// await it and let the list provider's reload pick up the change.
Future<void> showAddressFormSheet(BuildContext context, {Address? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddressFormSheet(existing: existing),
  );
}

class _AddressFormSheet extends ConsumerStatefulWidget {
  final Address? existing;
  const _AddressFormSheet({this.existing});

  @override
  ConsumerState<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<_AddressFormSheet> {
  final _addressLineController = TextEditingController();
  final _zipController = TextEditingController();
  LocationSelection? _location;
  bool _makePrimary = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _addressLineController.text = existing.addressLine;
      _zipController.text = existing.zipCode ?? '';
      _makePrimary = existing.isPrimary;
      if (existing.governorateId != null && existing.cityId != null) {
        _location = LocationSelection(
          countryId: existing.countryId ?? 0,
          governorateId: existing.governorateId!,
          cityId: existing.cityId!,
          label: [existing.governorate?.nameAr, existing.city?.nameAr]
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .join(' — '),
        );
      }
    }
  }

  @override
  void dispose() {
    _addressLineController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final location = _location;
    if (location == null || _addressLineController.text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      final controller = ref.read(addressesControllerProvider.notifier);
      final existing = widget.existing;
      if (existing == null) {
        await controller.create(
          governorateId: location.governorateId,
          cityId: location.cityId,
          addressLine: _addressLineController.text.trim(),
          zipCode: _zipController.text.trim(),
          isPrimary: _makePrimary,
        );
      } else {
        await controller.update(
          existing.id,
          governorateId: location.governorateId,
          cityId: location.cityId,
          addressLine: _addressLineController.text.trim(),
          zipCode: _zipController.text.trim(),
        );
        if (_makePrimary && !existing.isPrimary) {
          await controller.setPrimary(existing.id);
        }
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? l10n.addressAddTitle : l10n.addressEditTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              LocationPickerField(
                value: _location,
                onChanged: (v) => setState(() => _location = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressLineController,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(hintText: l10n.addressLineHint),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _zipController,
                decoration: InputDecoration(hintText: l10n.addressZipHint),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _makePrimary,
                onChanged: (v) => setState(() => _makePrimary = v ?? false),
                title: Text(l10n.addressMakePrimary),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
