import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../business/presentation/screens/business_detail_screen.dart';
import '../../cart/presentation/screens/tech_product_detail_screen.dart';
import '../application/menu_search_providers.dart';
import '../data/models/menu_search.dart';

/// A search or comparison result opens the PRODUCT PAGE of that very unit —
/// price, photos, what it is, add to cart — not its shop's front door; the page
/// names the shop and links to it. المالك، 2026-10-02.
Future<void> openSearchItem(BuildContext context, WidgetRef ref, SearchItem result) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final failed = AppLocalizations.of(context)!.commonRetry;
  try {
    final item = await ref.read(menuSearchApiProvider).item(result.id);
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => TechProductDetailScreen(
          item: item,
          shopName: result.shop.name,
          onOpenShop: () => navigator.push(
            MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: result.shop.id)),
          ),
        ),
      ),
    );
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}
