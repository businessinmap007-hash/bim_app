import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/guarantee_badge/guarantee_badge_info.dart';
import 'package:bim_app/core/guarantee_badge/guarantee_badge_loader.dart';
import 'package:bim_app/core/guarantee_badge/guarantee_badge_providers.dart';
import 'package:bim_app/core/guarantee_badge/widgets/account_name.dart';
import 'package:bim_app/core/guarantee_badge/widgets/bim_coin.dart';
import 'package:bim_app/core/guarantee_badge/widgets/guarantee_badge.dart';
import 'package:bim_app/l10n/app_localizations.dart';

Widget _host(Widget child, {List<Override> overrides = const []}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('the guarantee level beside an account\'s name', () {
    test('reads the level, both names and what it covers up to', () {
      final b = GuaranteeBadgeInfo.fromJsonOrNull({
        'code': 'silver',
        'name_ar': 'فضي',
        'name_en': 'Silver',
        'covers_up_to': 1500,
        'target_type': 'business',
      })!;

      expect(b.code, 'silver');
      expect(b.name(true), 'فضي');
      expect(b.name(false), 'Silver');
      expect(b.coversUpTo, 1500);
      expect(b.targetType, 'business');
      expect(GuaranteeBadgeInfo.fromJsonOrNull(null), isNull);
      expect(GuaranteeBadgeInfo.fromJsonOrNull({'name_ar': 'x'}), isNull);
    });

    test('everything asked within a moment rides ONE request, and an answer is kept', () async {
      var calls = 0;
      final loader = GuaranteeBadgeLoader((path, {query}) async {
        calls++;
        expect(path, '/guarantee-badges');
        expect(query!['ids'], '1,2,3');

        return {
          'badges': {
            '1': {'code': 'gold', 'name_ar': 'ذهبي', 'name_en': 'Gold', 'covers_up_to': 3000},
            '2': null,
          },
        };
      });

      final results = await Future.wait([loader.load(1), loader.load(2), loader.load(3)]);

      expect(calls, 1);
      expect(results[0]!.code, 'gold');
      expect(results[1], isNull);
      expect(results[2], isNull);

      // asked again: from memory
      expect((await loader.load(1))!.code, 'gold');
      expect(calls, 1);
    });

    test('a failed call leaves the accounts with no badge instead of failing the screen', () async {
      final loader = GuaranteeBadgeLoader((path, {query}) async => throw Exception('offline'));

      expect(await loader.load(9), isNull);
    });

    testWidgets('every level draws its coin without error, at list size and at sheet size', (tester) async {
      const codes = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'elite', 'royal', 'unknown'];

      await tester.pumpWidget(
        _host(
          Wrap(
            children: [
              for (final c in codes) ...[BimCoin(code: c, size: 20), BimCoin(code: c, size: 84)],
            ],
          ),
        ),
      );

      expect(find.byType(BimCoin), findsNWidgets(codes.length * 2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a name with a badge says the level and the coverage, and a tap opens it larger', (tester) async {
      const info = GuaranteeBadgeInfo(code: 'silver', nameAr: 'فضي', nameEn: 'Silver', coversUpTo: 1500);

      await tester.pumpWidget(
        _host(
          ProviderScope(
            overrides: [guaranteeBadgeProvider(7).overrideWith((ref) async => info)],
            child: const AccountName(text: 'فندق الأندلس', userId: 7),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('فندق الأندلس'), findsOneWidget);
      expect(find.byType(GuaranteeBadgeCoin), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);

      await tester.tap(find.byType(GuaranteeBadgeCoin));
      await tester.pumpAndSettle();

      expect(find.textContaining('فضي'), findsWidgets);
      expect(find.textContaining('1,500'), findsWidgets);
    });

    testWidgets('an account with no guarantee, or no id, shows only its name', (tester) async {
      await tester.pumpWidget(
        _host(
          ProviderScope(
            overrides: [guaranteeBadgeProvider(8).overrideWith((ref) async => null)],
            child: const Column(
              children: [
                AccountName(text: 'بلا ضمان', userId: 8),
                AccountName(text: 'بلا رقم', userId: null),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('بلا ضمان'), findsOneWidget);
      expect(find.text('بلا رقم'), findsOneWidget);
      expect(find.byType(GuaranteeBadgeCoin), findsNothing);
    });
  });
}
