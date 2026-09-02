import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/merchant_account_providers.dart';
import '../../data/models/merchant_account_status.dart';

/// GET/POST /merchant-account — a business's own Fawry sub-account status,
/// and applying for one. Provisioning is admin-only (AdminV2); this is
/// visibility + the application itself, never the money routing.
class MerchantAccountScreen extends ConsumerWidget {
  const MerchantAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(merchantAccountControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.merchantAccountTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.read(merchantAccountControllerProvider.notifier).load(),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (status) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.merchantAccountHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            _StatusCard(status: status),
            if (!status.routingEnabled) ...[
              const SizedBox(height: 12),
              Text(
                l10n.merchantAccountRoutingDisabledNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
              ),
            ],
            if (!status.hasAccount && !status.pendingRequest) ...[
              const SizedBox(height: 24),
              const _ApplyForm(),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final MerchantAccountStatus status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, color, label) = switch (status) {
      MerchantAccountStatus(hasAccount: true) => (
        Icons.check_circle_outline,
        AppColors.success,
        l10n.merchantAccountStatusActive,
      ),
      MerchantAccountStatus(pendingRequest: true) => (
        Icons.hourglass_empty,
        AppColors.warning,
        l10n.merchantAccountStatusPending,
      ),
      MerchantAccountStatus(requestStatus: 'rejected') => (
        Icons.cancel_outlined,
        AppColors.error,
        l10n.merchantAccountStatusRejected,
      ),
      _ => (Icons.account_balance_outlined, Theme.of(context).hintColor, l10n.merchantAccountStatusNone),
    };

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ApplyForm extends ConsumerStatefulWidget {
  const _ApplyForm();

  @override
  ConsumerState<_ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends ConsumerState<_ApplyForm> {
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ref
          .read(merchantAccountControllerProvider.notifier)
          .apply(note: _noteController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.merchantAccountApplied)));
      }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.merchantAccountNoteHint),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.merchantAccountApplyButton),
        ),
      ],
    );
  }
}
