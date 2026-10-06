import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/wallet/application/wallet_providers.dart';
import 'package:bim_app/features/wallet/data/models/wallet_summary.dart';
import 'package:bim_app/features/wallet/data/models/wallet_transaction.dart';
import 'package:bim_app/features/wallet/data/wallet_api.dart';
import 'package:bim_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:bim_app/l10n/app_localizations.dart';

/// «داخل المحفظة تابات لكل نوع من الحركات، أولها الكل» — المالك، 2026-10-06.
class _FakeWalletApi implements WalletApi {
  final asked = <String?>[];

  static WalletTransaction _tx(int id, String type, String direction, double amount) => WalletTransaction(
    id: id,
    status: 'completed',
    direction: direction,
    type: type,
    amount: amount,
    balanceAfter: 0,
  );

  final _all = [_tx(1, 'deposit', 'in', 100), _tx(2, 'platform_fee', 'out', 5), _tx(3, 'refund', 'in', 20)];

  @override
  Future<WalletSummary> show() async => const WalletSummary(balance: 115, lockedBalance: 0, availableBalance: 115, totalIn: 120, totalOut: 5, status: 'active');

  @override
  Future<WalletTransactionsPage> transactions({int page = 1, int perPage = 20, String? type}) async {
    asked.add(type);
    final rows = type == null ? _all : _all.where((t) => t.type == type).toList();
    return WalletTransactionsPage(items: rows, hasMore: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('the wallet opens on «الكل» and each tab asks the server for that kind of movement', (tester) async {
    final api = _FakeWalletApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [walletApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          home: const WalletScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // الكل is the first tab and shows every movement
    final tabs = tester.widgetList<Tab>(find.byType(Tab)).toList();
    expect(tabs.first.text, 'الكل');
    expect(tabs.length, walletTransactionTypes.length + 1);
    expect(find.byType(ListTile), findsNWidgets(3));

    await tester.tap(find.widgetWithText(Tab, 'استرداد'));
    await tester.pumpAndSettle();

    expect(api.asked.last, 'refund');
    expect(find.byType(ListTile), findsOneWidget);

    // the strip scrolled to the chosen tab — bring «الكل» back into view
    await tester.ensureVisible(find.widgetWithText(Tab, 'الكل'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'الكل'));
    await tester.pumpAndSettle();

    expect(api.asked.last, isNull);
    expect(find.byType(ListTile), findsNWidgets(3));
  });
}
