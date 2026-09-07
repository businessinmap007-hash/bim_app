import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../discovery/application/discovery_providers.dart';

/// The "what kind of service?" chip row — booking/menu/delivery/retail/…
/// (see PlatformService), letting the customer narrow
/// [RecommendedBusinessesList] before ever picking a category child (see the
/// د discussion: this is the discovery-screen-level gateway, not a per-
/// business one). Selection lives in [selectedServiceTypeProvider], shared
/// across all 3 Categories layouts so switching the layout style mid-session
/// doesn't reset it. Fails quiet (collapses to nothing) rather than showing
/// an error block — this is a secondary filter, not the screen's own content.
class ServiceTypeChipsRow extends ConsumerWidget {
  const ServiceTypeChipsRow({super.key});

  static const double _rowHeight = 44;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final servicesAsync = ref.watch(serviceTypesProvider);
    final selected = ref.watch(selectedServiceTypeProvider);

    return servicesAsync.when(
      loading: () => const SizedBox(height: _rowHeight),
      error: (_, _) => const SizedBox.shrink(),
      data: (services) {
        if (services.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: _rowHeight,
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: services.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ChoiceChip(
                    label: Text(l10n.categoriesServiceTypeAll),
                    selected: selected == null,
                    onSelected: (_) => ref.read(selectedServiceTypeProvider.notifier).state = null,
                  );
                }
                final service = services[index - 1];
                final isSelected = selected == service.id;
                return ChoiceChip(
                  label: Text(service.name),
                  selected: isSelected,
                  // Tapping the already-selected chip clears back to "all",
                  // same toggle behaviour as re-tapping an active tab.
                  onSelected: (_) => ref.read(selectedServiceTypeProvider.notifier).state =
                      isSelected ? null : service.id,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
