import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../categories/presentation/screens/all_categories_screen.dart';
import '../../../discovery/presentation/screens/search_screen.dart';
import '../../../profile/presentation/screens/my_profile_screen.dart';
import 'business_home_screen.dart';
import 'customer_home_screen.dart';

/// The persistent bottom-nav shell for every signed-in account — Home /
/// Categories / Search / My Profile, each a primary destination reachable
/// from anywhere with one tap. Only the Home tab's content differs by
/// account type (the business dashboard vs the category grid); Categories,
/// Search and My Profile are the same screens for both, since browsing other
/// businesses and editing your own account info aren't business-vs-customer
/// concerns. Settings and logout stay in AppDrawer (every tab keeps its own
/// drawer) since those are account-level actions, not destinations you jump
/// between.
///
/// An [IndexedStack] keeps all four tabs mounted so switching tabs never
/// re-fetches — the tradeoff is that all four start loading as soon as the
/// shell mounts, which is fine at this scale (a handful of lightweight
/// requests, not a heavy screen).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;

    final tabs = [
      isBusiness ? const BusinessHomeScreen() : const CustomerHomeScreen(),
      const AllCategoriesScreen(),
      const SearchScreen(),
      const MyProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.2),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: isBusiness ? l10n.homeBusinessTitle : l10n.homeCustomerTitle,
          ),
          NavigationDestination(icon: const Icon(Icons.category_outlined), selectedIcon: const Icon(Icons.category_rounded), label: l10n.navCategories),
          NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: const Icon(Icons.search_rounded), label: l10n.navSearch),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person_rounded), label: l10n.navProfile),
        ],
      ),
    );
  }
}
