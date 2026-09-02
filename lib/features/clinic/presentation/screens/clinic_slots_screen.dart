import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/clinic_providers.dart';
import '../../data/models/clinic_slot.dart';

/// A clinic's open appointment slots — booking one confirms it at once (no
/// back-and-forth with the clinic). See Api\V2\ClinicAppointmentController.
class ClinicSlotsScreen extends ConsumerWidget {
  final int clinicId;
  final String clinicName;

  const ClinicSlotsScreen({super.key, required this.clinicId, required this.clinicName});

  Future<void> _book(BuildContext context, WidgetRef ref, ClinicSlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.clinicBookSlot, style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (slot.startsAt != null) Text(_formatDateTime(slot.startsAt!)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(hintText: l10n.clinicReasonHint),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.clinicBookSlot),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(clinicApiProvider).bookSlot(slot.id, reason: reasonController.text.trim());
      ref.invalidate(clinicSlotsProvider(clinicId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.clinicAppointmentBooked)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clinicSlotsProvider(clinicId));

    return Scaffold(
      appBar: AppBar(title: Text(clinicName)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(clinicSlotsProvider(clinicId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (slots) {
          if (slots.isEmpty) {
            return Center(child: Text(l10n.clinicNoOpenSlots));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: slots.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => _book(context, ref, slot),
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(slot.startsAt != null ? _formatDateTime(slot.startsAt!) : ''),
                  subtitle: slot.visitKind != null ? Text(slot.visitKind!) : null,
                  trailing: slot.price != null ? Text(slot.price!.toStringAsFixed(0)) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
