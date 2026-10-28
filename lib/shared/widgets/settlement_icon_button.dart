import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/booking/application/stay_settlement_providers.dart';
import '../../features/booking/presentation/screens/stay_settlement_screen.dart';
import '../../l10n/app_localizations.dart';

/// «يرجى التسوية لفك العربون»: beside the notifications, only while this account has a settlement open — for the guest and the
/// hotel alike. Its count is the open settlements; it disappears once both sides confirmed or a judge took it.
class SettlementIconButton extends ConsumerWidget {
  const SettlementIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(openStaySettlementsProvider).valueOrNull?.length ?? 0;

    if (count == 0) return const SizedBox.shrink();

    return IconButton(
      tooltip: AppLocalizations.of(context)!.settlementsTitle,
      icon: Badge(
        label: Text('$count'),
        backgroundColor: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.balance_outlined),
      ),
      onPressed: () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyStaySettlementsScreen()));
        ref.invalidate(openStaySettlementsProvider);
      },
    );
  }
}
