import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../discovery/application/discovery_providers.dart';
import '../category_roots_grid.dart';
import '../recommended_businesses_list.dart';
import '../service_type_chips_row.dart';

/// Layout أ (Fiverr-inspired): the compact category icon row, the
/// service-type chip row (see د's discovery-level "what kind of service?"
/// gateway), plus a rating-ranked "recommended for you" list underneath —
/// see [[bim-web-layout-options]]. The default of the 3 selectable
/// Categories layouts (`CategoriesLayoutStyle.iconRow`).
class IconRowCategoriesLayout extends ConsumerWidget {
  const IconRowCategoriesLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serviceId = ref.watch(selectedServiceTypeProvider);

    return Column(
      children: [
        const SizedBox(height: 96, child: CategoryRootsGrid()),
        const SizedBox(height: 8),
        const ServiceTypeChipsRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.categoriesRecommendedTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Expanded(child: RecommendedBusinessesList(serviceId: serviceId)),
      ],
    );
  }
}
