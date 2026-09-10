import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../discovery/application/discovery_providers.dart';
import '../../application/categories_providers.dart';

/// A SECOND chip row shown once a service is picked (see
/// [ServiceTypeChipsRow]) — the seller's own root category (e.g. "Factories"
/// vs "Shops"). General across every service, not retail-only: a "Retail"
/// feed mixing a greengrocer and a furniture factory is exactly as hard to
/// browse as any other service would be if it mixed unrelated trades.
/// Selection lives in [selectedCategoryRootIdProvider], which resets
/// whenever the service choice itself changes.
class CategoryRootChipsRow extends ConsumerWidget {
  const CategoryRootChipsRow({super.key});

  static const double _rowHeight = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serviceId = ref.watch(selectedServiceTypeProvider);
    if (serviceId == null) return const SizedBox.shrink();

    final rootsAsync = ref.watch(categoryRootsProvider);
    final selected = ref.watch(selectedCategoryRootIdProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    return rootsAsync.when(
      loading: () => const SizedBox(height: _rowHeight),
      error: (_, _) => const SizedBox.shrink(),
      data: (roots) {
        if (roots.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: _rowHeight,
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: roots.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ChoiceChip(
                    label: Text(l10n.categoriesServiceTypeAll),
                    selected: selected == null,
                    onSelected: (_) => ref.read(selectedCategoryRootIdProvider.notifier).state = null,
                  );
                }
                final root = roots[index - 1];
                final isSelected = selected == root.id;
                return ChoiceChip(
                  label: Text(root.localizedName(languageCode)),
                  selected: isSelected,
                  onSelected: (_) => ref.read(selectedCategoryRootIdProvider.notifier).state =
                      isSelected ? null : root.id,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
