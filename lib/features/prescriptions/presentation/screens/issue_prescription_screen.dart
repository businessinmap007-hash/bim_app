import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/prescriptions_providers.dart';
import '../../data/models/medicine.dart';
import '../../data/models/prescription.dart';
import '../../data/prescriptions_api.dart';

/// One line being built in the form — pairs the picked [Medicine] (for
/// display) with the [PrescriptionItemInput] actually submitted.
class _DraftItem {
  final Medicine medicine;
  final PrescriptionItemInput input;
  const _DraftItem({required this.medicine, required this.input});
}

/// Api\V2\PrescriptionController::store/revise — a doctor (clinic/hospital/
/// medical-center business) issues a new prescription, or amends an
/// existing one. [patientId] always comes from an already-known context (an
/// appointment on the clinic's own "My Clinic" list) — never a bare
/// name/phone search. When [existing] is set this is a revise: the server
/// creates a new version and cancels the old one, never edits in place.
class IssuePrescriptionScreen extends ConsumerStatefulWidget {
  final int patientId;
  final String? patientName;
  final int? appointmentId;
  final Prescription? existing;

  const IssuePrescriptionScreen({
    super.key,
    required this.patientId,
    this.patientName,
    this.appointmentId,
    this.existing,
  });

  @override
  ConsumerState<IssuePrescriptionScreen> createState() => _IssuePrescriptionScreenState();
}

class _IssuePrescriptionScreenState extends ConsumerState<IssuePrescriptionScreen> {
  final _diagnosisController = TextEditingController();
  final _conditionController = TextEditingController();
  final _notesController = TextEditingController();
  final List<_DraftItem> _items = [];
  bool _saving = false;
  String? _error;

  bool get _isRevise => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _diagnosisController.text = existing.diagnosis ?? '';
      _conditionController.text = existing.patientCondition ?? '';
      _notesController.text = existing.notes ?? '';
      for (final item in existing.items) {
        final medicineId = item.medicineId;
        // A line written before medicine_id existed can't be resubmitted as
        // one — the doctor re-adds it from the dictionary if still needed.
        if (medicineId == null) continue;
        _items.add(
          _DraftItem(
            medicine: Medicine(id: medicineId, name: item.name ?? ''),
            input: PrescriptionItemInput(
              medicineId: medicineId,
              dosage: item.dosage,
              quantity: item.quantity,
              instructions: item.instructions,
              frequencyPerDay: item.frequencyPerDay,
              foodTiming: item.foodTiming,
              timeSlots: item.timeSlots,
              durationValue: item.durationValue,
              durationUnit: item.durationUnit,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _conditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<Medicine?> _pickMedicine() async {
    final l10n = AppLocalizations.of(context)!;
    final searchController = TextEditingController();
    List<Medicine> results = [];
    bool loading = false;
    bool searched = false;

    return showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> runSearch(String q) async {
            if (q.trim().isEmpty) {
              setSheetState(() {
                results = [];
                searched = false;
              });
              return;
            }
            setSheetState(() => loading = true);
            try {
              final found = await ref.read(medicinesApiProvider).search(q.trim());
              setSheetState(() {
                results = found;
                loading = false;
                searched = true;
              });
            } catch (_) {
              setSheetState(() => loading = false);
            }
          }

          Future<void> addNew() async {
            final nameController = TextEditingController(text: searchController.text.trim());
            final strengthController = TextEditingController();
            final added = await showModalBottomSheet<bool>(
              context: sheetContext,
              isScrollControlled: true,
              builder: (addContext) => Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(addContext).viewInsets.bottom),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.medicineAddTitle, style: Theme.of(addContext).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: l10n.medicineNameHint),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: strengthController,
                        decoration: InputDecoration(labelText: l10n.medicineStrengthHint),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(addContext).pop(true),
                        child: Text(l10n.commonSave),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (added != true || nameController.text.trim().isEmpty) return;
            try {
              final medicine = await ref
                  .read(medicinesApiProvider)
                  .add(name: nameController.text.trim(), strength: strengthController.text.trim());
              if (sheetContext.mounted) Navigator.of(sheetContext).pop(medicine);
            } catch (e) {
              if (sheetContext.mounted) {
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)),
                );
              }
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
            child: SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.75),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.medicineSearchTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(hintText: l10n.medicineSearchHint, prefixIcon: const Icon(Icons.search)),
                      onChanged: runSearch,
                    ),
                    const SizedBox(height: 8),
                    if (loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                    if (!loading)
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final m in results)
                              ListTile(
                                title: Text(m.displayName),
                                subtitle: m.manufacturer != null ? Text(m.manufacturer!) : null,
                                onTap: () => Navigator.of(sheetContext).pop(m),
                              ),
                            if (searched && results.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(l10n.medicineNoResults),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: addNew,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.medicineAddNew),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addOrEditItem({Medicine? medicine, _DraftItem? existingDraft, int? editIndex}) async {
    final l10n = AppLocalizations.of(context)!;
    final chosenMedicine = medicine ?? existingDraft?.medicine;
    if (chosenMedicine == null) return;

    final dosageController = TextEditingController(text: existingDraft?.input.dosage ?? '');
    final quantityController = TextEditingController(text: existingDraft?.input.quantity ?? '');
    final instructionsController = TextEditingController(text: existingDraft?.input.instructions ?? '');
    final durationController = TextEditingController(
      text: existingDraft?.input.durationValue?.toString() ?? '',
    );
    int? frequency = existingDraft?.input.frequencyPerDay;
    String? foodTiming = existingDraft?.input.foodTiming;
    final timeSlots = <String>{...(existingDraft?.input.timeSlots ?? const [])};
    String durationUnit = existingDraft?.input.durationUnit ?? 'days';

    final result = await showModalBottomSheet<PrescriptionItemInput>(
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
                  Text(chosenMedicine.displayName, style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(controller: dosageController, decoration: InputDecoration(labelText: l10n.prescriptionDosageLabel)),
                  const SizedBox(height: 12),
                  TextField(controller: quantityController, decoration: InputDecoration(labelText: l10n.prescriptionQuantityLabel)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instructionsController,
                    decoration: InputDecoration(labelText: l10n.medicineInstructionsHint),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.medicineFrequencyLabel)),
                      IconButton(
                        onPressed: (frequency ?? 0) > 0
                            ? () => setSheetState(() => frequency = (frequency! - 1))
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(width: 24, child: Text('${frequency ?? 0}', textAlign: TextAlign.center)),
                      IconButton(
                        onPressed: () => setSheetState(() => frequency = (frequency ?? 0) + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.medicineFoodTimingLabel, style: Theme.of(sheetContext).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final v in const ['before', 'with', 'after'])
                        ChoiceChip(
                          label: Text(_foodTimingLabel(v, l10n)),
                          selected: foodTiming == v,
                          onSelected: (_) => setSheetState(() => foodTiming = foodTiming == v ? null : v),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.medicineTimeSlotsLabel, style: Theme.of(sheetContext).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final v in const ['breakfast', 'lunch', 'dinner', 'morning', 'evening'])
                        FilterChip(
                          label: Text(_slotLabel(v, l10n)),
                          selected: timeSlots.contains(v),
                          onSelected: (checked) => setSheetState(() {
                            if (checked) {
                              timeSlots.add(v);
                            } else {
                              timeSlots.remove(v);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.medicineDurationLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: durationUnit,
                        items: [
                          DropdownMenuItem(value: 'days', child: Text(l10n.prescriptionDurationDays)),
                          DropdownMenuItem(value: 'weeks', child: Text(l10n.prescriptionDurationWeeks)),
                          DropdownMenuItem(value: 'months', child: Text(l10n.prescriptionDurationMonths)),
                        ],
                        onChanged: (v) => setSheetState(() => durationUnit = v ?? 'days'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      final durationValue = int.tryParse(durationController.text.trim());
                      Navigator.of(sheetContext).pop(
                        PrescriptionItemInput(
                          medicineId: chosenMedicine.id,
                          dosage: dosageController.text.trim(),
                          quantity: quantityController.text.trim(),
                          instructions: instructionsController.text.trim(),
                          frequencyPerDay: (frequency ?? 0) > 0 ? frequency : null,
                          foodTiming: foodTiming,
                          timeSlots: timeSlots.toList(),
                          durationValue: durationValue,
                          durationUnit: durationValue != null ? durationUnit : null,
                        ),
                      );
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

    if (result == null) return;
    setState(() {
      final draft = _DraftItem(medicine: chosenMedicine, input: result);
      if (editIndex != null) {
        _items[editIndex] = draft;
      } else {
        _items.add(draft);
      }
    });
  }

  Future<void> _addMedicine() async {
    final medicine = await _pickMedicine();
    if (medicine == null || !mounted) return;
    await _addOrEditItem(medicine: medicine);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_items.isEmpty) {
      setState(() => _error = l10n.medicineAtLeastOneItem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final api = ref.read(prescriptionsApiProvider);
      if (_isRevise) {
        await api.revise(
          widget.existing!.id,
          diagnosis: _diagnosisController.text.trim(),
          patientCondition: _conditionController.text.trim(),
          notes: _notesController.text.trim(),
          items: _items.map((d) => d.input).toList(),
        );
      } else {
        await api.issue(
          patientId: widget.patientId,
          appointmentId: widget.appointmentId,
          diagnosis: _diagnosisController.text.trim(),
          patientCondition: _conditionController.text.trim(),
          notes: _notesController.text.trim(),
          items: _items.map((d) => d.input).toList(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(_isRevise ? l10n.prescriptionReviseTitle : l10n.prescriptionIssueTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.patientName != null) ...[
            Text(widget.patientName!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _diagnosisController,
            decoration: InputDecoration(labelText: l10n.prescriptionDiagnosisLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _conditionController,
            decoration: InputDecoration(labelText: l10n.prescriptionConditionLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: l10n.prescriptionNotesLabel),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.prescriptionItemsTitle, style: Theme.of(context).textTheme.titleSmall),
              TextButton.icon(onPressed: _addMedicine, icon: const Icon(Icons.add), label: Text(l10n.medicineAddItem)),
            ],
          ),
          for (var i = 0; i < _items.length; i++) _DraftItemCard(
            draft: _items[i],
            onTap: () => _addOrEditItem(existingDraft: _items[i], editIndex: i),
            onRemove: () => setState(() => _items.removeAt(i)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_isRevise ? l10n.prescriptionReviseSubmit : l10n.prescriptionIssueSubmit),
          ),
        ],
      ),
    );
  }
}

class _DraftItemCard extends StatelessWidget {
  final _DraftItem draft;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _DraftItemCard({required this.draft, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(draft.medicine.displayName),
        subtitle: Text(
          [
            if (draft.input.dosage != null && draft.input.dosage!.isNotEmpty) draft.input.dosage,
            if (draft.input.quantity != null && draft.input.quantity!.isNotEmpty) draft.input.quantity,
          ].whereType<String>().join(' · '),
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onRemove),
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
