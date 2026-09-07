import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/categories_providers.dart';
import '../../data/models/specialty.dart';
import '../category_icon_mapping.dart';

class SpecialtiesScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;

  const SpecialtiesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final specialties = ref.watch(specialtiesProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: AsyncValueView<List<Specialty>>(
        value: specialties,
        onRetry: () => ref.invalidate(specialtiesProvider(categoryId)),
        builder: (context, items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.specialtiesEmpty));
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(specialtiesProvider(categoryId)),
            child: ResponsiveCenter(
              maxWidth: 800,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final specialty = items[index];
                  final displayName = specialty.localizedName(
                    Localizations.localeOf(context).languageCode,
                  );
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(iconForCategoryChild(specialty.nameAr)),
                      // Same size/weight as the bottom nav bar's labels
                      // (NavigationBar has no style override, so it reads
                      // straight off textTheme.labelMedium too) — matched
                      // on request rather than the list-row default.
                      title: Text(
                        displayName,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      trailing: Text(
                        l10n.businessCount(specialty.businessCount),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      onTap: () => context.push(
                        '/discovery',
                        extra: {'childId': specialty.id, 'title': displayName},
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
