import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../hotel_rooms/presentation/screens/hotel_rooms_screen.dart';
import '../../../owner_listings/presentation/screens/owner_listings_screen.dart';
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
    // the hotels root also offers the rooms of every hotel by class, place and price
    final isHotels = ref
            .watch(categoryRootsProvider)
            .valueOrNull
            ?.any((r) => r.id == categoryId && r.slug == 'tourist-hotels') ??
        false;

    // the cars and the property roots also open what ordinary people list there «من المالك»
    final slug = ref.watch(categoryRootsProvider).valueOrNull?.where((r) => r.id == categoryId).firstOrNull?.slug;
    final ownerCategory = switch (slug) {
      'cars' => 'car',
      'property-and-land' => 'property',
      _ => null,
    };
    final extras = (isHotels ? 1 : 0) + (ownerCategory != null ? 1 : 0);

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
                itemCount: items.length + extras,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (ownerCategory != null && index == 0) {
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(Icons.sell_outlined),
                        title: Text(l10n.olTitle),
                        subtitle: Text(ownerCategory == 'car' ? l10n.olCarsEntry : l10n.olPropertyEntry),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => OwnerListingsScreen(initialCategory: ownerCategory)),
                        ),
                      ),
                    );
                  }
                  if (isHotels && index == 0) {
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(Icons.hotel_outlined),
                        title: Text(l10n.hotelRoomsTitle),
                        subtitle: Text(l10n.hotelRoomsSearchEntry),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HotelRoomsScreen()),
                        ),
                      ),
                    );
                  }
                  final specialty = items[index - extras];
                  final displayName = specialty.localizedName(
                    Localizations.localeOf(context).languageCode,
                  );
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(iconForCategoryChild(specialty.nameAr)),
                      // The list's own title size (the theme's ListTile style) — it was matched to the bottom
                      // bar's tiny labels once and read as too small on the phone.
                      title: Text(displayName),
                      trailing: Text(
                        l10n.businessCount(specialty.businessCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => context.push(
                        '/discovery',
                        extra: {'childId': specialty.id, 'categoryId': categoryId, 'title': displayName},
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
