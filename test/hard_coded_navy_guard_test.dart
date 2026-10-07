import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A fixed navy (`AppColors.primaryNavy`) vanishes on the dark background. Every use left in
/// the app was reviewed and is safe — navy ink on a GOLD surface (badges, selected chips,
/// "mine" chat bubbles), the splash, the drawer's cover, or an avatar's own light
/// placeholder. Anything else uses the theme's colours (colorScheme.primary / onSurface /
/// AppColors.heroSurface / photoPlaceholder…). A new use anywhere else fails here: review it
/// for dark mode, then add the file to [reviewed].
void main() {
  /// file (under lib/) → how many `AppColors.primaryNavy` uses were reviewed in it.
  const reviewed = {
    // navy ink on the gold selected chip and the gold «مفضّل» badge
    'features/booking_settings/presentation/screens/booking_terms_screen.dart': 2,
    'features/business/presentation/widgets/menu_card_stepper.dart': 1,
    'features/business/presentation/widgets/menu_item_grid_card.dart': 1,
    'features/business/presentation/widgets/menu_item_tile.dart': 1,
    // navy ink on the gold «صورة الكارت» badge
    'features/business_menu/presentation/screens/menu_item_edit_screen.dart': 1,
    'features/business_menu/presentation/screens/tech_pricing_screen.dart': 3,
    // the product page's own navy-to-navy hero gradient (a dark block in both themes)
    'features/cart/presentation/screens/tech_product_detail_screen.dart': 1,
    'features/disputes/presentation/screens/dispute_room_screen.dart': 1,
    'features/home/presentation/screens/home_shell.dart': 1,
    'features/media/presentation/screens/image_cropper_screen.dart': 1,
    'features/media/presentation/widgets/watermark_repeat_selector.dart': 1,
    'features/profile/presentation/widgets/profile_avatar_picker.dart': 2,
    'features/splash/presentation/screens/splash_screen.dart': 1,
    'features/training/presentation/screens/training_chat_screen.dart': 1,
    'shared/widgets/app_drawer.dart': 2,
    'shared/widgets/profile_cover_header.dart': 3,
  };

  test('no unreviewed fixed navy in the app code', () {
    final found = <String, int>{};
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll('\\', '/').replaceFirst('lib/', '');
      if (path.startsWith('app/theme/')) continue; // the theme itself defines the brand colours
      final count = RegExp(r'AppColors\.primaryNavy\b(?!Light)').allMatches(entity.readAsStringSync()).length;
      if (count > 0) found[path] = count;
    }

    expect(found, reviewed, reason: 'a fixed navy is invisible in dark mode — see this test\'s doc');
  });

  test('no explicit navy/white on a floating action button or a checkbox (the theme owns them)', () {
    final offenders = <String>[];
    for (final entity in Directory('lib/features').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      if (RegExp(r'FloatingActionButton[\s\S]{0,200}backgroundColor:\s*AppColors\.primaryNavy').hasMatch(source) ||
          source.contains('activeColor: AppColors.primaryNavy')) {
        offenders.add(entity.path);
      }
    }

    expect(offenders, isEmpty);
  });
}
