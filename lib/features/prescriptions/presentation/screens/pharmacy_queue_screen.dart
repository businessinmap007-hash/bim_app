import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/pharmacy_prescriptions_providers.dart';
import '../../data/models/prescription.dart';
import 'prescription_detail_screen.dart';
import 'prescriptions_screen.dart' show statusLabel;

/// Api\V2\PharmacyPrescriptionController::incoming — every prescription sent
/// to this pharmacy. Tapping one opens the same PrescriptionDetailScreen
/// used by the doctor/patient sides; the pharmacy's own actions (price,
/// prepare, ready, dispense, reject) are gated there by viewer role.
class PharmacyQueueScreen extends ConsumerStatefulWidget {
  const PharmacyQueueScreen({super.key});

  @override
  ConsumerState<PharmacyQueueScreen> createState() => _PharmacyQueueScreenState();
}

class _PharmacyQueueScreenState extends ConsumerState<PharmacyQueueScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(pharmacyQueueControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const _statuses = [null, 'sent_to_pharmacy', 'preparing', 'ready', 'dispensed'];

  String _filterLabel(AppLocalizations l10n, String? status) =>
      status == null ? l10n.pharmacyQueueFilterAll : statusLabel(status, l10n);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(pharmacyQueueControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pharmacyQueueTitle)),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final status in _statuses)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(l10n, status)),
                      selected: state.status == status,
                      onSelected: (_) => ref.read(pharmacyQueueControllerProvider.notifier).setStatus(status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(pharmacyQueueControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
                ? Center(child: Text(l10n.pharmacyQueueEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(pharmacyQueueControllerProvider.notifier).load(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _QueueTile(prescription: state.items[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends ConsumerWidget {
  final Prescription prescription;
  const _QueueTile({required this.prescription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PrescriptionDetailScreen(prescriptionId: prescription.id)),
          );
          ref.read(pharmacyQueueControllerProvider.notifier).load();
        },
        title: Text(prescription.patient.name ?? '#${prescription.patient.id}'),
        subtitle: Text(
          [
            statusLabel(prescription.status, l10n),
            prescription.doctor.name,
            if (prescription.medicineTotal != null) '${prescription.medicineTotal} EGP',
          ].whereType<String>().join(' · '),
        ),
        trailing: Text('${prescription.items.length}'),
      ),
    );
  }
}
