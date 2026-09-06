import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';

/// The 3 researched Categories-screen directions (see
/// [[bim-web-layout-options]]) — every one fully built, not a mockup:
/// - [iconRow]: a single horizontally-scrolling strip of icon+label
///   (Fiverr-inspired), the default.
/// - [tabsAndRows]: root categories as tabs; the active tab's top-rated
///   businesses show as a horizontally-scrolling row underneath
///   (Airbnb-inspired).
/// - [barAndMenu]: root categories as a persistent bar; tapping one opens
///   its specialties in a dropdown/panel instead of navigating away
///   (Yelp-inspired).
enum CategoriesLayoutStyle { iconRow, tabsAndRows, barAndMenu }

/// Drives which of the 3 layouts the Categories screen renders — defaults
/// to [CategoriesLayoutStyle.iconRow], but the user can pick and persist
/// any of the 3 from Settings.
class LayoutStyleController extends StateNotifier<CategoriesLayoutStyle> {
  final Ref _ref;

  LayoutStyleController(this._ref) : super(CategoriesLayoutStyle.iconRow) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _ref.read(layoutStyleStorageProvider).read();
      state = CategoriesLayoutStyle.values.firstWhere(
        (s) => s.name == saved,
        orElse: () => CategoriesLayoutStyle.iconRow,
      );
    } catch (_) {
      // Keep the default — storage being unavailable shouldn't crash launch.
    }
  }

  Future<void> setStyle(CategoriesLayoutStyle style) async {
    state = style;
    try {
      await _ref.read(layoutStyleStorageProvider).write(style.name);
    } catch (_) {
      // Best-effort persistence; the in-memory switch already took effect.
    }
  }
}

final layoutStyleControllerProvider =
    StateNotifierProvider<LayoutStyleController, CategoriesLayoutStyle>((ref) {
      return LayoutStyleController(ref);
    });
