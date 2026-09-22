import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../discovery/data/models/business_summary.dart';
import '../../application/prescriptions_providers.dart';
import 'prescription_detail_screen.dart';
import '../widgets/business_picker_sheet.dart' show showBusinessPickerSheet;

/// Ask a pharmacy for medicine directly — no doctor, no dictionary-bound drug
/// on the customer's side. Chefaa-style: a photo of a paper prescription
/// and/or a free-text note; the pharmacy reads it and replies with real,
/// priced items (PrescriptionDetailScreen), which the customer then confirms.
class RequestMedicineScreen extends ConsumerStatefulWidget {
  const RequestMedicineScreen({super.key});

  @override
  ConsumerState<RequestMedicineScreen> createState() => _RequestMedicineScreenState();
}

class _RequestMedicineScreenState extends ConsumerState<RequestMedicineScreen> {
  final _noteController = TextEditingController();
  BusinessSummary? _pharmacy;
  File? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPharmacy() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showBusinessPickerSheet(context, title: l10n.medicineRequestPickPharmacyTitle);
    if (picked != null && mounted) setState(() => _pharmacy = picked);
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.medicineRequestTakePhoto),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.medicineRequestChooseFromGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final pharmacy = _pharmacy;
    if (pharmacy == null) return;
    if (_noteController.text.trim().isEmpty && _photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicineRequestNeedsNoteOrPhoto)));
      return;
    }

    setState(() => _submitting = true);
    try {
      final prescription = await ref
          .read(prescriptionsApiProvider)
          .requestFromPharmacy(
            pharmacyId: pharmacy.id,
            note: _noteController.text,
            hasPhoto: _photo != null,
          );
      if (_photo != null) {
        // Best-effort — the request itself already succeeded either way.
        try {
          await ref.read(prescriptionsApiProvider).addImage(prescription.id, _photo!.path);
        } catch (_) {}
      }
      // The list this screen was opened from won't otherwise learn about the
      // new row until the whole navigation stack (including the detail
      // screen we're about to push) eventually pops back to it.
      ref.invalidate(myPrescriptionsControllerProvider);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PrescriptionDetailScreen(prescriptionId: prescription.id)),
      );
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicineRequestTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.medicineRequestExplainer, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          InkWell(
            onTap: _pickPharmacy,
            child: InputDecorator(
              decoration: InputDecoration(labelText: l10n.medicineRequestPharmacyLabel, suffixIcon: const Icon(Icons.search)),
              child: Text(
                _pharmacy?.name ?? l10n.medicineRequestPickPharmacyTitle,
                style: _pharmacy == null ? TextStyle(color: Theme.of(context).hintColor) : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: l10n.medicineRequestNoteLabel,
              hintText: l10n.medicineRequestNoteHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          if (_photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_photo!, height: 160, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(_photo == null ? l10n.medicineRequestAttachPhoto : l10n.medicineRequestChangePhoto),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _pharmacy == null || _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.medicineRequestSubmit),
          ),
        ],
      ),
    );
  }
}
