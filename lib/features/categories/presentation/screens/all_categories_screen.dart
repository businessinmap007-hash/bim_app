import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/categories_providers.dart';
import '../../data/models/category_root.dart';
import '../../data/models/specialty.dart';
import '../category_icon_mapping.dart';

/// A bottom-nav destination for reaching a specialty directly, without the
/// home grid's tap-a-root-then-see-its-specialties two-step. Every root
/// expands in place to its specialties; a root's specialties are only
/// fetched once it's actually expanded, not all ~21 at once.
class AllCategoriesScreen extends ConsumerStatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  ConsumerState<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends ConsumerState<AllCategoriesScreen> {
  final _expandedRootIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rootsAsync = ref.watch(categoryRootsProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCategories)),
      drawer: const AppDrawer(),
      body: AsyncValueView<List<CategoryRoot>>(
        value: rootsAsync,
        onRetry: () => ref.invalidate(categoryRootsProvider),
        builder: (context, roots) {
          if (roots.isEmpty) return Center(child: Text(l10n.categoriesEmpty));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: roots.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final root = roots[index];
              final expanded = _expandedRootIds.contains(root.id);

              return ExpansionTile(
                key: PageStorageKey('root-${root.id}'),
                leading: Icon(iconForCategory(root.nameAr)),
                title: Text(root.localizedName(languageCode)),
                onExpansionChanged: (value) => setState(() {
                  if (value) {
                    _expandedRootIds.add(root.id);
                  } else {
                    _expandedRootIds.remove(root.id);
                  }
                }),
                children: expanded ? [_SpecialtiesList(rootId: root.id)] : const [],
              );
            },
          );
        },
      ),
    );
  }
}

class _SpecialtiesList extends ConsumerWidget {
  final int rootId;
  const _SpecialtiesList({required this.rootId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final specialtiesAsync = ref.watch(specialtiesProvider(rootId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return AsyncValueView<List<Specialty>>(
      value: specialtiesAsync,
      onRetry: () => ref.invalidate(specialtiesProvider(rootId)),
      builder: (context, specialties) {
        if (specialties.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(l10n.specialtiesEmpty, style: Theme.of(context).textTheme.bodySmall),
          );
        }

        return Column(
          children: specialties
              .map(
                (specialty) => ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: 32, end: 16),
                  title: Text(specialty.localizedName(languageCode)),
                  trailing: Text('${specialty.businessCount}', style: Theme.of(context).textTheme.bodySmall),
                  onTap: () => context.push(
                    '/discovery',
                    extra: {'childId': specialty.id, 'title': specialty.localizedName(languageCode)},
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
