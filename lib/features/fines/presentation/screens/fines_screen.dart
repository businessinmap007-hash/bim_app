import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/fines_providers.dart';
import '../../data/models/fine.dart';

/// The signed-in account's own platform fines — see them and contest one
/// while its window is open. Read-only otherwise: levying/deciding a fine
/// is admin-only.
class FinesScreen extends ConsumerStatefulWidget {
  const FinesScreen({super.key});

  @override
  ConsumerState<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends ConsumerState<FinesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(finesControllerProvider.notifier).loadMore();
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
    final state = ref.watch(finesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.finesTitle)),
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
                    onPressed: () => ref.read(finesControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.finesEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(finesControllerProvider.notifier).load(),
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
                  final fine = state.items[index];
                  return _FineTile(
                    fine: fine,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => _FineDetailSheet(fine: fine),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _FineTile extends StatelessWidget {
  final Fine fine;
  final VoidCallback onTap;
  const _FineTile({required this.fine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.gavel_outlined),
        title: Text(fine.reason?.isNotEmpty == true ? fine.reason! : l10n.finesTitle),
        subtitle: Text(_statusLabel(fine.status, l10n)),
        trailing: Text(
          fine.amount.toStringAsFixed(2),
          style: TextStyle(color: _statusColor(fine.status), fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FineDetailSheet extends ConsumerStatefulWidget {
  final Fine fine;
  const _FineDetailSheet({required this.fine});

  @override
  ConsumerState<_FineDetailSheet> createState() => _FineDetailSheetState();
}

class _FineDetailSheetState extends ConsumerState<_FineDetailSheet> {
  final _statementController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _statementController.dispose();
    super.dispose();
  }

  Future<void> _submitAppeal() async {
    final l10n = AppLocalizations.of(context)!;
    if (_statementController.text.trim().isEmpty) {
      setState(() => _error = l10n.finesAppealStatementRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(finesControllerProvider.notifier).appeal(widget.fine.id, _statementController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.finesAppealSubmitted)));
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fine = widget.fine;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fine.reason?.isNotEmpty == true ? fine.reason! : l10n.finesTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    fine.amount.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _statusColor(fine.status)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(_statusLabel(fine.status, l10n), style: TextStyle(color: _statusColor(fine.status))),
              const SizedBox(height: 12),
              if (fine.frozenAmount > 0)
                _AmountRow(label: l10n.finesFrozenAmount, value: fine.frozenAmount),
              if (fine.collectedAmount > 0)
                _AmountRow(label: l10n.finesCollectedAmount, value: fine.collectedAmount),
              const SizedBox(height: 16),
              if (fine.hasPendingAppeal)
                Text(l10n.finesAppealPending, style: TextStyle(color: Theme.of(context).hintColor))
              else if (fine.canAppeal) ...[
                TextField(
                  controller: _statementController,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: l10n.finesAppealStatementHint),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _submitting ? null : _submitAppeal,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.finesSubmitAppeal),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  const _AmountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
          Text(value.toStringAsFixed(2), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
  'frozen' => l10n.finesStatusFrozen,
  'appealed' => l10n.finesStatusAppealed,
  'upheld' => l10n.finesStatusUpheld,
  'overturned' => l10n.finesStatusOverturned,
  'collected' => l10n.finesStatusCollected,
  'cancelled' => l10n.finesStatusCancelled,
  _ => status,
};

Color _statusColor(String status) => switch (status) {
  'overturned' || 'cancelled' => AppColors.success,
  'upheld' || 'collected' => AppColors.error,
  _ => AppColors.warning,
};
