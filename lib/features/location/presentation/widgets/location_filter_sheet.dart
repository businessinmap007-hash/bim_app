import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/location_providers.dart';
import '../../data/models/location_models.dart';

/// Egypt, the only country the app works in for now.
const kEgyptCountryId = 1;

typedef LocationFilterResult = ({int governorateId, int? cityId, String label});

/// Governorate → city, city optional (governorate alone still filters).
/// Shared by the business list and the owner listings. Simpler than [LocationPickerField] on purpose — a search filter, not an
/// address, so it skips the country step.
class LocationFilterSheet extends ConsumerStatefulWidget {
  const LocationFilterSheet({super.key});

  @override
  ConsumerState<LocationFilterSheet> createState() =>
      LocationFilterSheetState();
}

class LocationFilterSheetState extends ConsumerState<LocationFilterSheet> {
  LocationGovernorate? _governorate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final governorate = _governorate;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    if (governorate != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => _governorate = null),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        governorate != null
                            ? governorate.localizedName(languageCode)
                            : l10n.businessFilterChooseGovernorate,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: governorate == null
                    ? GovernorateFilterList(
                        scrollController: scrollController,
                        onSelected: (g) => setState(() => _governorate = g),
                      )
                    : CityFilterList(
                        scrollController: scrollController,
                        governorate: governorate,
                        languageCode: languageCode,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GovernorateFilterList extends ConsumerWidget {
  final ScrollController scrollController;
  final ValueChanged<LocationGovernorate> onSelected;

  const GovernorateFilterList({
    super.key,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final governorates = ref.watch(governoratesProvider(kEgyptCountryId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return governorates.when(
      data: (raw) {
        final items = sortedGovernorates(raw, languageCode);
        return ListView.separated(
          controller: scrollController,
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final governorate = items[index];
            return ListTile(
              title: Text(governorate.localizedName(languageCode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelected(governorate),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text(l10n.commonSomethingWentWrong)),
    );
  }
}

class CityFilterList extends ConsumerWidget {
  final ScrollController scrollController;
  final LocationGovernorate governorate;
  final String languageCode;

  const CityFilterList({
    super.key,
    required this.scrollController,
    required this.governorate,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cities = ref.watch(citiesProvider(governorate.id));
    final governorateName = governorate.localizedName(languageCode);

    return cities.when(
      data: (raw) {
        final items = sortedCities(raw, languageCode);
        return ListView.separated(
          controller: scrollController,
          itemCount: items.length + 1,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                title: Text(l10n.businessFilterAnyCity),
                onTap: () => Navigator.of(context).pop((
                  governorateId: governorate.id,
                  cityId: null,
                  label: governorateName,
                )),
              );
            }
            final city = items[index - 1];
            return ListTile(
              title: Text(city.localizedName(languageCode)),
              onTap: () => Navigator.of(context).pop((
                governorateId: governorate.id,
                cityId: city.id,
                label: '$governorateName — ${city.localizedName(languageCode)}',
              )),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text(l10n.commonSomethingWentWrong)),
    );
  }
}
