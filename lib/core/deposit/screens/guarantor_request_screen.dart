import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../network/api_exception.dart';
import '../guarantor.dart';
import '../visit_deposit_providers.dart';

/// The friend's side: someone asked him to stand for an operation's deposit. He sees who, how much of his guarantee is
/// free, and chooses the amount to freeze — it is frozen until the operation ends, then returned, never charged.
class GuarantorRequestScreen extends ConsumerStatefulWidget {
  final int guarantorId;
  const GuarantorRequestScreen({super.key, required this.guarantorId});

  @override
  ConsumerState<GuarantorRequestScreen> createState() => _GuarantorRequestScreenState();
}

class _GuarantorRequestScreenState extends ConsumerState<GuarantorRequestScreen> {
  final _amount = TextEditingController();
  Guarantor? _request;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final g = await ref.read(visitDepositApiProvider).guarantor(widget.guarantorId);
      if (!mounted) return;
      setState(() {
        _request = g;
        if (_amount.text.isEmpty && g.availableCoverage > 0) _amount.text = g.availableCoverage.toStringAsFixed(0);
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _answer({required bool accept}) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final api = ref.read(visitDepositApiProvider);

    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;
    if (accept && amount <= 0) return;

    setState(() => _busy = true);

    try {
      if (accept) {
        await api.acceptGuarantor(widget.guarantorId, amount);
        messenger.showSnackBar(SnackBar(content: Text(l10n.guarantorAccepted)));
      } else {
        await api.declineGuarantor(widget.guarantorId);
      }
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
      );
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final g = _request;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guarantorRequestTitle)),
      body: _failed
          ? Center(child: Text(l10n.commonSomethingWentWrong))
          : g == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(l10n.guarantorRequestBody(g.requesterName ?? ''), style: theme.textTheme.bodyLarge),
                const SizedBox(height: 14),
                Text(l10n.guarantorAvailable(g.availableCoverage.toStringAsFixed(0)), style: theme.textTheme.titleSmall),
                const SizedBox(height: 14),
                if (g.isInvited) ...[
                  TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.guarantorAmountLabel, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy || g.availableCoverage <= 0 ? null : () => _answer(accept: true),
                          child: Text(l10n.guarantorAccept),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(onPressed: _busy ? null : () => _answer(accept: false), child: Text(l10n.guarantorDecline)),
                      ),
                    ],
                  ),
                ] else
                  Text(g.status == Guarantor.accepted ? l10n.guarantorAccepted : l10n.guarantorStatusDeclined),
              ],
            ),
    );
  }
}
