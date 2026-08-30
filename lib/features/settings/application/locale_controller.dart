import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Drives the app's active [Locale] and keeps [ApiClient.languageCode] (and
/// so the backend's `Accept-Language`) in sync with it — one switch changes
/// both the UI strings and the language the server replies in.
class LocaleController extends StateNotifier<Locale> {
  final Ref _ref;

  LocaleController(this._ref) : super(const Locale('ar')) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _ref.read(localeStorageProvider).read();
      if (saved != null &&
          AppLocalizations.supportedLocales.any(
            (l) => l.languageCode == saved,
          )) {
        state = Locale(saved);
      }
    } catch (_) {
      // Keep the 'ar' default — storage being unavailable shouldn't crash launch.
    }
    _ref.read(apiClientProvider).languageCode = state.languageCode;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    _ref.read(apiClientProvider).languageCode = locale.languageCode;
    try {
      await _ref.read(localeStorageProvider).write(locale.languageCode);
    } catch (_) {
      // Best-effort persistence; the in-memory switch already took effect.
    }
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
      return LocaleController(ref);
    });
