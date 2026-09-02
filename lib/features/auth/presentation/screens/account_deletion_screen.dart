import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_controller.dart';
import '../../data/models/account_deletion_status.dart';

/// GET/POST /account/deletion — see Api\V2\AccountDeletionController. Shows
/// why deletion is blocked (if it is) before the user ever taps it, then
/// requires a password confirmation and a plain-language warning before
/// acting — this signs the account out everywhere immediately.
class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  ConsumerState<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
  late Future<AccountDeletionStatus> _future = _load();

  Future<AccountDeletionStatus> _load() => ref.read(authApiProvider).deletionEligibility();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountDeletionTitle)),
      body: FutureBuilder<AccountDeletionStatus>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            );
          }
          final status = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!status.canDelete) ...[
                Text(l10n.accountDeletionBlockersTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final b in status.blockers)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.block, color: Theme.of(context).colorScheme.error),
                      title: Text(b.message),
                    ),
                  ),
              ] else ...[
                Text(
                  l10n.accountDeletionHint(status.graceDays),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _RequestDeletionForm(graceDays: status.graceDays),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RequestDeletionForm extends ConsumerStatefulWidget {
  final int graceDays;
  const _RequestDeletionForm({required this.graceDays});

  @override
  ConsumerState<_RequestDeletionForm> createState() => _RequestDeletionFormState();
}

class _RequestDeletionFormState extends ConsumerState<_RequestDeletionForm> {
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_passwordController.text.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountDeletionConfirmTitle),
        content: Text(l10n.accountDeletionConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.accountDeletionConfirmButton, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authApiProvider)
          .requestDeletion(password: _passwordController.text, reason: _reasonController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.accountDeletionRequested)));
        await ref.read(authControllerProvider.notifier).logout();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
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
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.accountDeletionPasswordHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reasonController,
          maxLines: 2,
          decoration: InputDecoration(labelText: l10n.accountDeletionReasonHint),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.accountDeletionRequestButton),
        ),
      ],
    );
  }
}
