import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/location_providers.dart';
import '../../data/models/location_models.dart';

/// A picked administrative location — country/governorate/city ids plus a
/// display label ("مصر — القاهرة — مدينة نصر"), the same shape
/// [CategoryPickerField] uses for a taxonomy pick.
class LocationSelection {
  final int countryId;
  final int governorateId;
  final int cityId;
  final String label;

  const LocationSelection({
    required this.countryId,
    required this.governorateId,
    required this.cityId,
    required this.label,
  });
}

/// A tap-to-pick field for country -> governorate -> city, mirroring
/// CategoryPickerField's drill-down sheet so the two taxonomy-shaped pickers
/// in this app behave the same way.
class LocationPickerField extends StatelessWidget {
  final LocationSelection? value;
  final ValueChanged<LocationSelection> onChanged;
  final String? errorText;

  const LocationPickerField({super.key, required this.value, required this.onChanged, this.errorText});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final selection = await showModalBottomSheet<LocationSelection>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const _LocationPickerSheet(),
        );
        if (selection != null) onChanged(selection);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.locationFieldLabel,
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value?.label ?? l10n.locationChooseHint,
          style: value == null ? TextStyle(color: Theme.of(context).hintColor) : null,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Country -> governorate -> city, EXCEPT the country step is never actually
/// shown: the app only operates in Egypt for now (the backend pins
/// country_id to it too, see ProfileController::update()), so this resolves
/// Egypt from [countriesProvider] itself (by iso2, matching how the
/// countries list is already filterable server-side) and starts the picker
/// straight at governorates. A single wrong tap used to be able to land the
/// picker on some other country's now-forever-empty governorate list.
class _LocationPickerSheet extends ConsumerStatefulWidget {
  const _LocationPickerSheet();

  @override
  ConsumerState<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  LocationGovernorate? _selectedGovernorate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final countriesAsync = ref.watch(countriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return countriesAsync.when(
          loading: () => const SafeArea(child: Center(child: CircularProgressIndicator())),
          error: (error, stack) => SafeArea(child: Center(child: Text(l10n.commonSomethingWentWrong))),
          data: (countries) {
            final egypt = countries.firstWhere(
              (c) => c.iso2 == 'EG',
              orElse: () => countries.isNotEmpty
                  ? countries.first
                  : const LocationCountry(id: 1, nameAr: 'مصر', nameEn: 'Egypt', iso2: 'EG'),
            );
            final governorate = _selectedGovernorate;

            final title = governorate != null ? governorate.localizedName(languageCode) : l10n.locationChooseGovernorate;

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
                            onPressed: () => setState(() => _selectedGovernorate = null),
                          )
                        else
                          const SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: governorate == null
                        ? _GovernorateList(
                            scrollController: scrollController,
                            countryId: egypt.id,
                            onSelected: (g) => setState(() => _selectedGovernorate = g),
                          )
                        : _CityList(
                            scrollController: scrollController,
                            governorateId: governorate.id,
                            onSelected: (city) => Navigator.of(context).pop(
                              LocationSelection(
                                countryId: egypt.id,
                                governorateId: governorate.id,
                                cityId: city.id,
                                label:
                                    '${governorate.localizedName(languageCode)} — '
                                    '${city.localizedName(languageCode)}',
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GovernorateList extends ConsumerWidget {
  final ScrollController scrollController;
  final int countryId;
  final ValueChanged<LocationGovernorate> onSelected;

  const _GovernorateList({required this.scrollController, required this.countryId, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final governorates = ref.watch(governoratesProvider(countryId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return governorates.when(
      data: (items) {
        if (items.isEmpty) return Center(child: Text(l10n.locationEmpty));
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
      error: (error, stack) => Center(child: Text(l10n.commonSomethingWentWrong)),
    );
  }
}

class _CityList extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final int governorateId;
  final ValueChanged<LocationCity> onSelected;

  const _CityList({required this.scrollController, required this.governorateId, required this.onSelected});

  @override
  ConsumerState<_CityList> createState() => _CityListState();
}

class _CityListState extends ConsumerState<_CityList> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cities = ref.watch(citiesProvider(widget.governorateId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: _onChanged,
            decoration: InputDecoration(hintText: l10n.locationSearchCity, prefixIcon: const Icon(Icons.search)),
          ),
        ),
        Expanded(
          child: cities.when(
            data: (items) {
              final filtered = _query.isEmpty
                  ? items
                  : items.where((c) => c.localizedName(languageCode).toLowerCase().contains(_query)).toList();
              if (filtered.isEmpty) return Center(child: Text(l10n.locationEmpty));
              return ListView.separated(
                controller: widget.scrollController,
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final city = filtered[index];
                  return ListTile(
                    title: Text(city.localizedName(languageCode)),
                    onTap: () => widget.onSelected(city),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(l10n.commonSomethingWentWrong)),
          ),
        ),
      ],
    );
  }
}
