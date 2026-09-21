import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/table_providers.dart';
import '../../data/table_api.dart';

/// The business's standing queue of dine-in calls («waiter», «the bill»,
/// «assistance»). Push is the primary alert; this is the board to work through.
/// Api\V2\TableServiceCallController. Re-reads itself every 20 seconds, like the
/// web panel's board.
class TableCallsScreen extends ConsumerStatefulWidget {
  const TableCallsScreen({super.key});

  @override
  ConsumerState<TableCallsScreen> createState() => _TableCallsScreenState();
}

class _TableCallsScreenState extends ConsumerState<TableCallsScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => ref.invalidate(tableCallsProvider));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
    'waiter' => l10n.tableCallWaiter,
    'bill' => l10n.tableCallBill,
    'assistance' => l10n.tableCallAssistance,
    _ => type,
  };

  IconData _typeIcon(String type) => switch (type) {
    'waiter' => Icons.room_service_outlined,
    'bill' => Icons.receipt_long_outlined,
    _ => Icons.support_agent_outlined,
  };

  Future<void> _resolve(TableCall call) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(tableApiProvider).resolveCall(call.id);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)));
    }
    ref.invalidate(tableCallsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calls = ref.watch(tableCallsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tableCallsTitle)),
      body: calls.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => ref.invalidate(tableCallsProvider), child: Text(l10n.commonRetry)),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.tableCallsEmpty))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(tableCallsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final call = items[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: Icon(_typeIcon(call.type)),
                        title: Text(l10n.tableCallTable(call.tableLabel)),
                        subtitle: Text(
                          [
                            _typeLabel(l10n, call.type),
                            if (call.note != null && call.note!.isNotEmpty) call.note!,
                          ].join(' · '),
                        ),
                        trailing: FilledButton.tonal(onPressed: () => _resolve(call), child: Text(l10n.tableCallResolve)),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
