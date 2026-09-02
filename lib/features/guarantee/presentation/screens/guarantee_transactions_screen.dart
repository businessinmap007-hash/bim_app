import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/guarantee_providers.dart';
import '../../data/models/guarantee_level.dart';

class GuaranteeTransactionsScreen extends ConsumerStatefulWidget {
  const GuaranteeTransactionsScreen({super.key});

  @override
  ConsumerState<GuaranteeTransactionsScreen> createState() => _GuaranteeTransactionsScreenState();
}

class _GuaranteeTransactionsScreenState extends ConsumerState<GuaranteeTransactionsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(guaranteeTransactionsControllerProvider.notifier).loadMore();
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
    final state = ref.watch(guaranteeTransactionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guaranteeTransactionsTitle)),
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
                    onPressed: () => ref.read(guaranteeTransactionsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(child: Text(l10n.guaranteeTransactionsEmpty))
          : ListView.separated(
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
                final tx = state.items[index];
                return _TransactionTile(tx: tx);
              },
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final GuaranteeTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(tx.type),
        subtitle: Text(
          [
            '${tx.amount}',
            if (tx.reason != null && tx.reason!.isNotEmpty) tx.reason!,
            if (tx.createdAt != null) _formatDate(tx.createdAt!),
          ].join(' · '),
        ),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
