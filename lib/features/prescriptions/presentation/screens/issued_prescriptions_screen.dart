import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/prescriptions_providers.dart';
import '../../data/models/prescription.dart';
import 'prescription_detail_screen.dart';
import 'prescriptions_screen.dart' show statusLabel;

/// Api\V2\PrescriptionController::issued — a doctor's own prescription
/// history. Writing a NEW one always starts from a specific patient's
/// appointment on "My Clinic" (see clinic_management_screen.dart), never
/// from this screen — there is no patient picker here on purpose.
class IssuedPrescriptionsScreen extends ConsumerStatefulWidget {
  const IssuedPrescriptionsScreen({super.key});

  @override
  ConsumerState<IssuedPrescriptionsScreen> createState() => _IssuedPrescriptionsScreenState();
}

class _IssuedPrescriptionsScreenState extends ConsumerState<IssuedPrescriptionsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(issuedPrescriptionsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(issuedPrescriptionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.prescriptionsIssuedTitle)),
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
                    onPressed: () => ref.read(issuedPrescriptionsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.prescriptionsIssuedEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(issuedPrescriptionsControllerProvider.notifier).load(),
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
                  final p = state.items[index];
                  return _PrescriptionTile(prescription: p);
                },
              ),
            ),
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  final Prescription prescription;
  const _PrescriptionTile({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PrescriptionDetailScreen(prescriptionId: prescription.id)),
          );
        },
        title: Text(prescription.patient.name ?? '#${prescription.patient.id}'),
        subtitle: Text(
          [
            statusLabel(prescription.status, l10n),
            if (prescription.diagnosis != null && prescription.diagnosis!.isNotEmpty) prescription.diagnosis,
          ].whereType<String>().join(' · '),
        ),
        trailing: Text('${prescription.items.length}'),
      ),
    );
  }
}
