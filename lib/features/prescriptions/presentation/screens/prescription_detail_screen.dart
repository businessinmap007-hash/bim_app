import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../addresses/presentation/widgets/address_pick_sheet.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../discovery/data/models/business_summary.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../application/pharmacy_prescriptions_providers.dart';
import '../../application/prescriptions_providers.dart';
import '../../data/models/prescription.dart';
import '../../data/pharmacy_prescriptions_api.dart';
import '../widgets/business_picker_sheet.dart';
import 'issue_prescription_screen.dart';
import 'prescriptions_screen.dart' show statusLabel;

class PrescriptionDetailScreen extends ConsumerWidget {
  final int prescriptionId;
  const PrescriptionDetailScreen({super.key, required this.prescriptionId});

  Future<void> _sendToPharmacy(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final pharmacy = await showBusinessPickerSheet(context, title: l10n.prescriptionSendPickPharmacyTitle);
    if (pharmacy == null || !context.mounted) return;

    final result = await _showFulfillmentSheet(context, pharmacy);
    if (result == null || !context.mounted) return;

    try {
      await ref.read(prescriptionsApiProvider).sendToPharmacy(
        prescriptionId,
        pharmacyId: pharmacy.id,
        fulfillmentType: result.fulfillmentType,
        addressId: result.addressId,
        deliveryAddress: result.deliveryAddress,
      );
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.prescriptionSent)));
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<_FulfillmentChoice?> _showFulfillmentSheet(BuildContext context, BusinessSummary pharmacy) {
    final l10n = AppLocalizations.of(context)!;
    final addressController = TextEditingController();
    String fulfillment = 'delivery';
    int? selectedAddressId;

    return showModalBottomSheet<_FulfillmentChoice>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pharmacy.name, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'delivery', label: Text(l10n.prescriptionFulfillmentDelivery)),
                    ButtonSegment(value: 'pickup', label: Text(l10n.prescriptionFulfillmentPickup)),
                  ],
                  selected: {fulfillment},
                  onSelectionChanged: (s) => setState(() => fulfillment = s.first),
                ),
                if (fulfillment == 'delivery') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: l10n.prescriptionDeliveryAddressHint,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.location_on_outlined),
                        onPressed: () async {
                          final picked = await showAddressPickSheet(sheetContext);
                          if (picked == null) return;
                          setState(() {
                            selectedAddressId = picked.addressId;
                            addressController.text = picked.label;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) => setState(() => selectedAddressId = null),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(
                    _FulfillmentChoice(
                      fulfillment,
                      selectedAddressId,
                      selectedAddressId == null ? addressController.text.trim() : null,
                    ),
                  ),
                  child: Text(l10n.prescriptionSendToPharmacy),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.prescriptionCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.prescriptionCancel)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(prescriptionsApiProvider).cancel(prescriptionId);
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.prescriptionCancelled)));
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _scheduleReminders(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final count = await ref.read(prescriptionsApiProvider).scheduleReminders(prescriptionId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$count ${l10n.prescriptionRemindersLabel}')));
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final doctor = await showBusinessPickerSheet(context, title: l10n.prescriptionSharePickDoctorTitle);
    if (doctor == null || !context.mounted) return;

    try {
      await ref.read(prescriptionsApiProvider).share(prescriptionId, doctorId: doctor.id);
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.prescriptionShared)));
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _addImage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.profilePhotoCamera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profilePhotoGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null || !context.mounted) return;

    try {
      await ref.read(prescriptionsApiProvider).addImage(prescriptionId, picked.path);
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _removeImage(BuildContext context, WidgetRef ref, PrescriptionImage image) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.prescriptionRemovePhotoConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(prescriptionsApiProvider).removeImage(prescriptionId, image.id);
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _revise(BuildContext context, WidgetRef ref, Prescription p) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => IssuePrescriptionScreen(patientId: p.patient.id, patientName: p.patient.name, existing: p),
      ),
    );
    if (created == true && context.mounted) {
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
      ref.read(issuedPrescriptionsControllerProvider.notifier).load();
    }
  }

  Future<void> _pharmacyAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(PharmacyPrescriptionsApi) action,
    String successMessage, {
    bool popAfter = false,
  }) async {
    try {
      await action(ref.read(pharmacyPrescriptionsApiProvider));
      ref.read(pharmacyQueueControllerProvider.notifier).load();
      if (!context.mounted) return;
      if (popAfter) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
        return;
      }
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _prepare(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    await _pharmacyAction(context, ref, (api) => api.prepare(prescriptionId), l10n.pharmacyPreparingStarted);
  }

  Future<void> _markReady(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    await _pharmacyAction(context, ref, (api) => api.ready(prescriptionId), l10n.pharmacyMarkedReady);
  }

  Future<void> _dispense(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    await _pharmacyAction(context, ref, (api) => api.dispense(prescriptionId), l10n.pharmacyDispensed);
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.pharmacyRejectConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.pharmacyRejectAction)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _pharmacyAction(context, ref, (api) => api.reject(prescriptionId), l10n.pharmacyRejected, popAfter: true);
  }

  Future<void> _priceItems(BuildContext context, WidgetRef ref, Prescription p) async {
    final l10n = AppLocalizations.of(context)!;
    final priceControllers = <int, TextEditingController>{};
    final qtyControllers = <int, TextEditingController>{};
    for (final item in p.items) {
      priceControllers[item.id] = TextEditingController(
        text: item.unitPrice != null ? _trimNum(item.unitPrice!) : '',
      );
      qtyControllers[item.id] = TextEditingController(text: (item.billedQuantity ?? 1).toString());
    }
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
                  Text(l10n.pharmacyPriceTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  for (final item in p.items) ...[
                    Text(item.name ?? '', style: Theme.of(sheetContext).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: priceControllers[item.id],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.pharmacyUnitPriceLabel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: qtyControllers[item.id],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: l10n.pharmacyBilledQuantityLabel),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (error != null) ...[
                    Text(error!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(
                    onPressed: () {
                      final items = <PricedItemInput>[];
                      for (final item in p.items) {
                        final price = double.tryParse(priceControllers[item.id]!.text.trim());
                        final qty = int.tryParse(qtyControllers[item.id]!.text.trim());
                        if (price == null || price < 0 || qty == null || qty < 1) {
                          setSheetState(() => error = l10n.validationRequired);
                          return;
                        }
                        items.add(PricedItemInput(prescriptionItemId: item.id, unitPrice: price, billedQuantity: qty));
                      }
                      Navigator.of(sheetContext).pop(true);
                      _submitPricing(context, ref, items);
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
    if (saved != true) return;
  }

  Future<void> _submitPricing(BuildContext context, WidgetRef ref, List<PricedItemInput> items) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(pharmacyPrescriptionsApiProvider).price(prescriptionId, items);
      ref.invalidate(prescriptionDetailProvider(prescriptionId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pharmacyPriced)));
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  String _trimNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void _showError(BuildContext context, Object e) {
    final l10n = AppLocalizations.of(context)!;
    final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(prescriptionDetailProvider(prescriptionId));
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState is AuthSignedIn ? authState.user.id : null;

    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(prescriptionDetailProvider(prescriptionId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (p) {
        // Send-to-pharmacy and dose reminders are patient-only server-side
        // (both 404 for anyone else) — this screen used to show them
        // unconditionally, which only ever worked because only the patient
        // ever opened it before a doctor could too (see IssuePrescriptionScreen).
        final isPatientViewer = currentUserId != null && currentUserId == p.patient.id;
        final canRevise = currentUserId != null && currentUserId == p.doctor.id && p.canCancel;
        final isPharmacyViewer = currentUserId != null && p.pharmacy != null && currentUserId == p.pharmacy!.id;
        const openStatuses = ['sent_to_pharmacy', 'preparing', 'ready'];
        final canPrice = isPharmacyViewer && openStatuses.contains(p.status);
        final canPrepare = isPharmacyViewer && p.status == 'sent_to_pharmacy';
        final canMarkReady = isPharmacyViewer && (p.status == 'sent_to_pharmacy' || p.status == 'preparing');
        final canDispense = isPharmacyViewer && (p.status == 'ready' || p.status == 'preparing');
        final canReject = isPharmacyViewer && (p.status == 'sent_to_pharmacy' || p.status == 'preparing');
        return Scaffold(
        appBar: AppBar(title: Text(p.doctor.name ?? l10n.prescriptionsTitle)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusLabel(p.status, l10n), style: Theme.of(context).textTheme.titleSmall),
                    if (p.superseded) Text(l10n.prescriptionSupersededLabel),
                    if (p.diagnosis != null && p.diagnosis!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(l10n.prescriptionDiagnosisLabel, style: Theme.of(context).textTheme.labelMedium),
                      Text(p.diagnosis!),
                    ],
                    if (p.patientCondition != null && p.patientCondition!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(l10n.prescriptionConditionLabel, style: Theme.of(context).textTheme.labelMedium),
                      Text(p.patientCondition!),
                    ],
                    if (p.notes != null && p.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(l10n.prescriptionNotesLabel, style: Theme.of(context).textTheme.labelMedium),
                      Text(p.notes!),
                    ],
                    if (p.pharmacy != null) ...[
                      const SizedBox(height: 6),
                      Text(l10n.prescriptionPharmacyLabel, style: Theme.of(context).textTheme.labelMedium),
                      Text(p.pharmacy!.name ?? ''),
                    ],
                    if (p.medicineTotal != null) ...[
                      const SizedBox(height: 6),
                      Text(l10n.prescriptionMedicineTotalLabel, style: Theme.of(context).textTheme.labelMedium),
                      Text('${p.medicineTotal}'),
                    ],
                    if (p.sharedWith.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(l10n.prescriptionSharedWithTitle, style: Theme.of(context).textTheme.labelMedium),
                      Text(p.sharedWith.map((d) => d.name ?? '').join(', ')),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.prescriptionItemsTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final item in p.items) ...[
              _ItemCard(item: item),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            Text(l10n.prescriptionImagesTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 84,
              child: MouseWheelHorizontalScroll(
                builder: (context, controller) => ListView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final img in p.images) ...[
                      _ImageThumb(image: img, onRemove: () => _removeImage(context, ref, img)),
                      const SizedBox(width: 8),
                    ],
                    InkWell(
                      onTap: () => _addImage(context, ref),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (p.canSend && isPatientViewer)
                  FilledButton(
                    onPressed: () => _sendToPharmacy(context, ref),
                    child: Text(l10n.prescriptionSendToPharmacy),
                  ),
                if (isPatientViewer)
                  OutlinedButton(
                    onPressed: () => _scheduleReminders(context, ref),
                    child: Text(l10n.prescriptionScheduleReminders),
                  ),
                OutlinedButton(
                  onPressed: () => _share(context, ref),
                  child: Text(l10n.prescriptionShareWithDoctor),
                ),
                if (canRevise)
                  OutlinedButton(
                    onPressed: () => _revise(context, ref, p),
                    child: Text(l10n.prescriptionReviseAction),
                  ),
                if (canPrice)
                  OutlinedButton(
                    onPressed: () => _priceItems(context, ref, p),
                    child: Text(l10n.pharmacyPriceAction),
                  ),
                if (canPrepare)
                  OutlinedButton(
                    onPressed: () => _prepare(context, ref),
                    child: Text(l10n.pharmacyPrepareAction),
                  ),
                if (canMarkReady)
                  OutlinedButton(
                    onPressed: () => _markReady(context, ref),
                    child: Text(l10n.pharmacyMarkReadyAction),
                  ),
                if (canDispense)
                  FilledButton(
                    onPressed: () => _dispense(context, ref),
                    child: Text(l10n.pharmacyDispenseAction),
                  ),
                if (canReject)
                  OutlinedButton(
                    onPressed: () => _reject(context, ref),
                    child: Text(l10n.pharmacyRejectAction),
                  ),
                if (p.canCancel)
                  OutlinedButton(
                    onPressed: () => _cancel(context, ref),
                    child: Text(l10n.prescriptionCancel),
                  ),
              ],
            ),
          ],
        ),
        );
      },
    );
  }
}

class _FulfillmentChoice {
  final String fulfillmentType;
  final int? addressId;
  final String? deliveryAddress;
  const _FulfillmentChoice(this.fulfillmentType, this.addressId, this.deliveryAddress);
}

class _ItemCard extends StatelessWidget {
  final PrescriptionItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name ?? '', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (item.dosage != null) Text('${l10n.prescriptionDosageLabel}: ${item.dosage}'),
                if (item.quantity != null) Text('${l10n.prescriptionQuantityLabel}: ${item.quantity}'),
                if (item.frequencyPerDay != null) Text('${item.frequencyPerDay}x/day'),
                if (item.foodTiming != null) Text(_foodTimingLabel(item.foodTiming!, l10n)),
                if (item.durationValue != null && item.durationUnit != null)
                  Text('${item.durationValue} ${_durationUnitLabel(item.durationUnit!, l10n)}'),
              ],
            ),
            if (item.timeSlots.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: item.timeSlots
                    .map((s) => Chip(label: Text(_slotLabel(s, l10n)), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
            ],
            if (item.instructions != null && item.instructions!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.instructions!, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (item.lineTotal != null) ...[
              const SizedBox(height: 4),
              Text(
                '${item.unitPrice} × ${item.billedQuantity} = ${item.lineTotal} ${l10n.pharmacyCurrencyLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _foodTimingLabel(String v, AppLocalizations l10n) => switch (v) {
  'before' => l10n.prescriptionFoodBefore,
  'with' => l10n.prescriptionFoodWith,
  'after' => l10n.prescriptionFoodAfter,
  _ => v,
};

String _slotLabel(String v, AppLocalizations l10n) => switch (v) {
  'breakfast' => l10n.mealBreakfast,
  'lunch' => l10n.mealLunch,
  'dinner' => l10n.mealDinner,
  'morning' => l10n.prescriptionSlotMorning,
  'evening' => l10n.prescriptionSlotEvening,
  _ => v,
};

String _durationUnitLabel(String v, AppLocalizations l10n) => switch (v) {
  'days' => l10n.prescriptionDurationDays,
  'weeks' => l10n.prescriptionDurationWeeks,
  'months' => l10n.prescriptionDurationMonths,
  _ => v,
};

class _ImageThumb extends StatelessWidget {
  final PrescriptionImage image;
  final VoidCallback onRemove;
  const _ImageThumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(image.url, width: 64, height: 64, fit: BoxFit.cover),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: IconButton(
            icon: const Icon(Icons.cancel, size: 18),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
