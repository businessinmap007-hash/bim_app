import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../storage/layout_style_storage.dart';
import '../storage/locale_storage.dart';
import '../storage/theme_mode_storage.dart';
import '../storage/token_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});

/// Bumped by LocaleController.setLocale() — `ApiClient.languageCode` is a
/// plain mutable field, so changing it doesn't itself notify anything.
/// Server-resolved bilingual data (a business's own display name, its menu
/// vocabulary, catalog unit labels...) was fetched once under the OLD
/// Accept-Language and stayed stale until a provider happened to refetch on
/// its own. Any provider that carries such data should `ref.watch` this —
/// a `FutureProvider` recomputes and a `StateNotifierProvider` rebuilds its
/// notifier (re-running its constructor's own initial load) the moment the
/// language actually changes.
final localeEpochProvider = StateProvider<int>((ref) => 0);

final localeStorageProvider = Provider<LocaleStorage>((ref) {
  return LocaleStorage();
});

final themeModeStorageProvider = Provider<ThemeModeStorage>((ref) {
  return ThemeModeStorage();
});

final layoutStyleStorageProvider = Provider<LayoutStyleStorage>((ref) {
  return LayoutStyleStorage();
});
