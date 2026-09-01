import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../categories/presentation/widgets/category_roots_grid.dart';

/// The customer's landing screen: root categories, per
/// business-in-map-roadmap.md's own priority order (accounts first, then
/// the category/discovery directory). Tapping a category drills into its
/// specialties, then into the business list for that specialty.
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeCustomerTitle)),
      drawer: const AppDrawer(),
      body: const CategoryRootsGrid(),
    );
  }
}
