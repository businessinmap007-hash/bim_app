import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../widgets/category_roots_grid.dart';

/// A bottom-nav destination for reaching categories directly regardless of
/// what the Home tab ends up showing later (a dashboard/feed, per the
/// roadmap) — today it's the identical root-category grid Home already has,
/// since Home has nothing else yet. Kept as the SAME [CategoryRootsGrid]
/// Home uses (not a second, differently-styled browser) after the first
/// version here — a separate expandable list — read as "the nice card grid
/// got replaced" rather than as a new, additional screen.
class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCategories)),
      drawer: const AppDrawer(),
      body: const CategoryRootsGrid(),
    );
  }
}
