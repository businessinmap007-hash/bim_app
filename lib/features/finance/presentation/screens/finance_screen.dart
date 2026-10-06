import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../deposits/presentation/screens/deposits_screen.dart';
import '../../../disputes/presentation/screens/disputes_screen.dart';
import '../../../fines/presentation/screens/fines_screen.dart';
import '../../../guarantee/presentation/screens/guarantee_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

/// «الأمور المالية» — المالك، 2026-10-06: the wallet, the guarantee, the frozen guarantees, the disputes and the
/// fines were five separate entries; they are ONE page now, a tab each, in that order. Each tab is the screen it
/// always was (embedded), so nothing about them changed but where they live.
class FinanceScreen extends StatelessWidget {
  /// The tab to open on (0 wallet … 4 fines).
  final int initialTab;
  const FinanceScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 5,
      initialIndex: initialTab.clamp(0, 4),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.financeTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.walletTitle),
              Tab(text: l10n.guaranteeTitle),
              Tab(text: l10n.depositsTitle),
              Tab(text: l10n.disputesTitle),
              Tab(text: l10n.finesTitle),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WalletScreen(embedded: true),
            GuaranteeScreen(embedded: true),
            DepositsScreen(embedded: true),
            DisputesScreen(embedded: true),
            FinesScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}
