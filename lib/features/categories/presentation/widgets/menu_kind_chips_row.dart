import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../discovery/application/discovery_providers.dart';

/// A THIRD chip row, shown only under the «menu» service chip — «مطاعم» vs
/// «ماركت». See [selectedMenuKindProvider] and [[three-catalog-shapes]].
class MenuKindChipsRow extends ConsumerWidget {
  const MenuKindChipsRow({super.key});

  static const double _rowHeight = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final services = ref.watch(serviceTypesProvider).valueOrNull ?? const [];
    final serviceId = ref.watch(selectedServiceTypeProvider);
    final isMenu = serviceId != null && services.any((s) => s.id == serviceId && s.key == 'menu');
    if (!isMenu) return const SizedBox.shrink();

    final selected = ref.watch(selectedMenuKindProvider);
    final kinds = [
      (key: 'menu_food', label: l10n.categoriesMenuKindFood),
      (key: 'menu_market', label: l10n.categoriesMenuKindMarket),
    ];

    return SizedBox(
      height: _rowHeight,
      child: MouseWheelHorizontalScroll(
        builder: (context, controller) => ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: kinds.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ChoiceChip(
                label: Text(l10n.categoriesServiceTypeAll),
                selected: selected == null,
                onSelected: (_) => ref.read(selectedMenuKindProvider.notifier).state = null,
              );
            }
            final kind = kinds[index - 1];
            final isSelected = selected == kind.key;
            return ChoiceChip(
              label: Text(kind.label),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(selectedMenuKindProvider.notifier).state = isSelected ? null : kind.key,
            );
          },
        ),
      ),
    );
  }
}
