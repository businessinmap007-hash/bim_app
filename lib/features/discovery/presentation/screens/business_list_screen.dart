import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/application/location_providers.dart';
import '../../../location/data/models/location_models.dart';
import '../../application/discovery_providers.dart';
import '../widgets/business_card.dart';

/// Egypt's id in the countries table — the location filter skips the
/// country step entirely (unlike [LocationPickerField], built for a user's
/// own address anywhere in the world) since every business on the platform
/// is Egyptian today.
const _kEgyptCountryId = 1;

class BusinessListScreen extends ConsumerStatefulWidget {
  final int childId;
  final String title;

  const BusinessListScreen({
    super.key,
    required this.childId,
    required this.title,
  });

  @override
  ConsumerState<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends ConsumerState<BusinessListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(businessListControllerProvider(widget.childId).notifier)
          .loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(businessListControllerProvider(widget.childId).notifier)
          .search(value);
    });
  }

  Future<void> _openLocationPicker(BuildContext context) async {
    final result = await showModalBottomSheet<_LocationFilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _LocationFilterSheet(),
    );
    if (result == null || !mounted) return;
    ref
        .read(businessListControllerProvider(widget.childId).notifier)
        .setLocation(governorateId: result.governorateId, cityId: result.cityId, label: result.label);
  }

  Future<void> _openAttributesFilter(BuildContext context, Set<int> current) async {
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AttributesFilterSheet(childId: widget.childId, initial: current),
    );
    if (result == null || !mounted) return;
    ref.read(businessListControllerProvider(widget.childId).notifier).setOptions(result);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(businessListControllerProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.businessSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InputChip(
                    avatar: const Icon(Icons.place_outlined, size: 18),
                    label: Text(state.locationLabel ?? l10n.businessFilterByLocation),
                    onPressed: () => _openLocationPicker(context),
                    onDeleted: state.locationLabel != null
                        ? () => ref.read(businessListControllerProvider(widget.childId).notifier).clearLocation()
                        : null,
                  ),
                  InputChip(
                    avatar: const Icon(Icons.tune, size: 18),
                    label: Text(
                      state.optionIds.isEmpty
                          ? l10n.businessFilterByAttributes
                          : l10n.businessFilterAttributesCount(state.optionIds.length),
                    ),
                    onPressed: () => _openAttributesFilter(context, state.optionIds),
                    onDeleted: state.optionIds.isNotEmpty
                        ? () => ref.read(businessListControllerProvider(widget.childId).notifier).setOptions({})
                        : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.commonSomethingWentWrong),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => ref
                                .read(
                                  businessListControllerProvider(
                                    widget.childId,
                                  ).notifier,
                                )
                                .load(),
                            child: Text(l10n.commonRetry),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.items.isEmpty) {
                    return Center(child: Text(l10n.businessListEmpty));
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(
                          businessListControllerProvider(
                            widget.childId,
                          ).notifier,
                        )
                        .load(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount:
                          state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final business = state.items[index];
                        return BusinessCard(
                          business: business,
                          onTap: () => context.push('/business/${business.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _LocationFilterResult = ({int governorateId, int? cityId, String label});

/// Governorate → city, city optional (governorate alone still filters).
/// Simpler than [LocationPickerField] on purpose — a search filter, not an
/// address, so it skips the country step.
class _LocationFilterSheet extends ConsumerStatefulWidget {
  const _LocationFilterSheet();

  @override
  ConsumerState<_LocationFilterSheet> createState() => _LocationFilterSheetState();
}

class _LocationFilterSheetState extends ConsumerState<_LocationFilterSheet> {
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
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: governorate == null
                    ? _GovernorateFilterList(
                        scrollController: scrollController,
                        onSelected: (g) => setState(() => _governorate = g),
                      )
                    : _CityFilterList(
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

class _GovernorateFilterList extends ConsumerWidget {
  final ScrollController scrollController;
  final ValueChanged<LocationGovernorate> onSelected;

  const _GovernorateFilterList({required this.scrollController, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final governorates = ref.watch(governoratesProvider(_kEgyptCountryId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return governorates.when(
      data: (items) => ListView.separated(
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
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.commonSomethingWentWrong)),
    );
  }
}

class _CityFilterList extends ConsumerWidget {
  final ScrollController scrollController;
  final LocationGovernorate governorate;
  final String languageCode;

  const _CityFilterList({required this.scrollController, required this.governorate, required this.languageCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cities = ref.watch(citiesProvider(governorate.id));
    final governorateName = governorate.localizedName(languageCode);

    return cities.when(
      data: (items) => ListView.separated(
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
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.commonSomethingWentWrong)),
    );
  }
}

/// Options grouped exactly as the backend groups them (line → modifier →
/// descriptive, then alphabetical) — only options a real business under this
/// child actually carries ever reach this list at all.
class _AttributesFilterSheet extends ConsumerStatefulWidget {
  final int childId;
  final Set<int> initial;
  const _AttributesFilterSheet({required this.childId, required this.initial});

  @override
  ConsumerState<_AttributesFilterSheet> createState() => _AttributesFilterSheetState();
}

class _AttributesFilterSheetState extends ConsumerState<_AttributesFilterSheet> {
  late Set<int> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupsAsync = ref.watch(attributeGroupsProvider(widget.childId));

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
                    const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        l10n.businessFilterByAttributes,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: groupsAsync.when(
                  data: (groups) {
                    if (groups.isEmpty) {
                      return Center(child: Text(l10n.businessFilterAttributesEmpty));
                    }
                    return ListView(
                      controller: scrollController,
                      children: [
                        for (final group in groups) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              group.name,
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          for (final option in group.options)
                            CheckboxListTile(
                              value: _selected.contains(option.id),
                              onChanged: (checked) => setState(() {
                                if (checked ?? false) {
                                  _selected.add(option.id);
                                } else {
                                  _selected.remove(option.id);
                                }
                              }),
                              title: Text(option.name),
                              subtitle: Text(l10n.businessFilterAttributeBusinessCount(option.businesses)),
                            ),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text(l10n.commonSomethingWentWrong)),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_selected.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _selected = {}),
                        child: Text(l10n.businessFilterAttributesClear),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      child: Text(l10n.businessFilterAttributesApply),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
