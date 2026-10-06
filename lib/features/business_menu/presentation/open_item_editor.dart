import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/business_menu_providers.dart';
import '../data/models/menu_item.dart';
import 'screens/menu_item_edit_screen.dart';
import 'screens/tech_pricing_screen.dart';

/// «صفحة تعديل الصنف على صفحتي تختلف عن صفحة التسعير والتفاصيل، وصفحة التسعير والتفاصيل هي الأصح» — المالك،
/// 2026-10-06. ONE decision for «open this item to edit it», used by every door (the menu tab on the owner's page,
/// the management screen): an item sold under a DETAILED branch is edited on «التسعير والتفاصيل» — the page that knows
/// its real product, its specs, its describing choices — and any other item on the full form.
Future<void> openMenuItemEditor(BuildContext context, WidgetRef ref, BusinessMenuItem item) async {
  final branch = item.lineOption;
  var detailed = false;

  if (branch != null) {
    try {
      final vocabulary = await ref.read(menuVocabularyProvider.future);
      detailed = vocabulary.lines.any((g) => g.detailed && g.options.any((o) => o.id == branch.id));
    } catch (_) {
      // the vocabulary could not be read: the full form still edits the item
    }
  }
  if (!context.mounted) return;

  await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => detailed ? TechPricingScreen(lineOption: branch!, existingItem: item) : MenuItemEditScreen(itemId: item.id),
    ),
  );
  ref.read(menuItemsControllerProvider.notifier).load();
}
