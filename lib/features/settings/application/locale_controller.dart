import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Drives the app's active [Locale] and keeps [ApiClient.languageCode] (and
/// so the backend's `Accept-Language`) in sync with it — one switch changes
/// both the UI strings and the language the server replies in.
class LocaleController extends StateNotifier<Locale> {
  final Ref _ref;
  // Only until the user explicitly picks a language: once true, the device's
  // own OS-language changes no longer touch state (setLocale's choice always
  // wins from then on, same as before this got the live-tracking below).
  bool _hasExplicitChoice = false;

  LocaleController(this._ref) : super(const Locale('ar')) {
    _restore();
    // The device's language can change while the app stays open (Settings
    // app on Android/iOS doesn't kill background apps) — without this,
    // that change was only ever picked up on the NEXT cold start.
    PlatformDispatcher.instance.onLocaleChanged = _onDeviceLocaleChanged;
  }

  void _onDeviceLocaleChanged() {
    if (_hasExplicitChoice) return;
    final deviceCode = PlatformDispatcher.instance.locale.languageCode;
    if (deviceCode == state.languageCode) return;
    if (AppLocalizations.supportedLocales.any((l) => l.languageCode == deviceCode)) {
      state = Locale(deviceCode);
      _ref.read(apiClientProvider).languageCode = state.languageCode;
    }
  }

  Future<void> _restore() async {
    try {
      final saved = await _ref.read(localeStorageProvider).read();
      if (saved != null &&
          AppLocalizations.supportedLocales.any(
            (l) => l.languageCode == saved,
          )) {
        state = Locale(saved);
        _hasExplicitChoice = true;
      } else {
        // No explicit choice saved yet — follow the device's own language
        // instead of always defaulting to Arabic, same as any well-behaved
        // app, and keep following it live (see _onDeviceLocaleChanged) until
        // the user picks a language explicitly in Settings.
        final deviceCode = PlatformDispatcher.instance.locale.languageCode;
        if (AppLocalizations.supportedLocales.any((l) => l.languageCode == deviceCode)) {
          state = Locale(deviceCode);
        }
      }
    } catch (_) {
      // Keep the 'ar' default — storage being unavailable shouldn't crash launch.
    }
    _ref.read(apiClientProvider).languageCode = state.languageCode;
  }

  Future<void> setLocale(Locale locale) async {
    _hasExplicitChoice = true;
    state = locale;
    _ref.read(apiClientProvider).languageCode = locale.languageCode;
    try {
      await _ref.read(localeStorageProvider).write(locale.languageCode);
    } catch (_) {
      // Best-effort persistence; the in-memory switch already took effect.
    }
  }

  @override
  void dispose() {
    PlatformDispatcher.instance.onLocaleChanged = null;
    super.dispose();
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
      return LocaleController(ref);
    });
