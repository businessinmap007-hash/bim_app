import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/screens/all_categories_screen.dart';
import '../../../discovery/presentation/screens/search_screen.dart';
import '../../../profile/presentation/screens/my_profile_screen.dart';
import 'customer_home_screen.dart';

/// The customer's persistent bottom-nav shell — Home / Categories / Search /
/// My Profile, each a primary destination reachable from anywhere with one
/// tap. Settings and logout stay in AppDrawer (each tab keeps its own drawer)
/// since those are account-level actions, not destinations you jump between.
///
/// An [IndexedStack] keeps all four tabs mounted so switching tabs never
/// re-fetches — the tradeoff is that all four start loading as soon as the
/// shell mounts, which is fine at this scale (a handful of lightweight
/// requests, not a heavy screen).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    CustomerHomeScreen(),
    AllCategoriesScreen(),
    SearchScreen(),
    MyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.2),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: l10n.homeCustomerTitle),
          NavigationDestination(icon: const Icon(Icons.category_outlined), selectedIcon: const Icon(Icons.category_rounded), label: l10n.navCategories),
          NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: const Icon(Icons.search_rounded), label: l10n.navSearch),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person_rounded), label: l10n.navProfile),
        ],
      ),
    );
  }
}
