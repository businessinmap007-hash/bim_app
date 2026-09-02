import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/prescriptions_providers.dart';
import '../../data/models/prescription.dart';
import 'prescription_detail_screen.dart';

class PrescriptionsScreen extends ConsumerStatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  ConsumerState<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends ConsumerState<PrescriptionsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(myPrescriptionsControllerProvider.notifier).loadMore();
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
    final state = ref.watch(myPrescriptionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.prescriptionsTitle)),
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
                    onPressed: () => ref.read(myPrescriptionsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.prescriptionsEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(myPrescriptionsControllerProvider.notifier).load(),
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
                  return _PrescriptionTile(
                    prescription: p,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PrescriptionDetailScreen(prescriptionId: p.id)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  final Prescription prescription;
  final VoidCallback onTap;
  const _PrescriptionTile({required this.prescription, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
        title: Text(prescription.doctor.name ?? ''),
        subtitle: Text(
          '${prescription.diagnosis ?? ''}\n'
          '${statusLabel(prescription.status, l10n)}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'issued' => l10n.prescriptionStatusIssued,
  'sent_to_pharmacy' => l10n.prescriptionStatusSent,
  'preparing' => l10n.prescriptionStatusPreparing,
  'ready' => l10n.prescriptionStatusReady,
  'dispensed' => l10n.prescriptionStatusDispensed,
  'cancelled' => l10n.prescriptionStatusCancelled,
  _ => status,
};
